# DOCX Import Disconnect Handoff

## Current Symptom

Selecting/uploading a DOCX in `/editor` kills the Blazor Server connection. Browser console shows `_blazor` WebSocket disconnects, then repeated negotiation failures:

- `WebSocket closed with status code: 1006`
- `Cannot send data if the connection is not in the 'Connected' State`
- `Failed to complete negotiation with the server: TypeError: NetworkError when attempting to fetch resource`

User confirmed `HandleDocxSelectedAsync` was not hit when testing earlier. Later evidence showed the server process exits:

- `The program '[17992] CDH_EL.exe' has exited with code 4294967295 (0xffffffff).`

VS Output did not show a managed exception or stack trace. It showed the process loading `System.IO.Compression.dll` shortly before exit, which strongly suggests failure during DOCX ZIP/GemBox import path rather than ordinary Blazor event handling.

## Evidence Gathered

- Browser log attachment path:
  - `C:\Users\dkolaya\.codex\attachments\7295059d-04bf-4472-b0b2-339ddcc50fef\pasted-text.txt`
- VS Output attachment path:
  - `C:\Users\dkolaya\.codex\attachments\e00685af-9fe1-48a3-b51a-5b17cf974e7e\pasted-text.txt`
- App could start and serve `/editor` over HTTP locally without immediate exception.
- Build and DOCX import unit tests pass.
- User reported failing DOCX is about `96 KB`, so original “file too large for SignalR” hypothesis is unlikely.
- Repo sample DOCX files include body tables:
  - `CDH_FPA\Web\wwwroot\templates\LetterTemplate.docx` has 6 body `<w:tbl>` nodes.
  - `Claude Design\_source\Engagement_Letter_Workflow_Architecture.docx` has 54 body `<w:tbl>` nodes.

## Changes Already Made

### 1. Guarded Blazor file event handler

File: `CDH_EL\Components\Pages\Editor.razor`

Initial fix guarded `InputFileChangeEventArgs.FileCount` before reading `args.File`, because HAVIT `ResetAsync()` dispatches a zero-file `change` event. This avoids unhandled `args.File` access when no file exists.

Result: build/tests passed, but user said handler still was not hit.

### 2. Recreated file input per modal open

File: `CDH_EL\Components\Pages\Editor.razor`

Added `@key="importDocxInputKey"` and incremented the key when opening modal. Removed pre-show `ResetAsync()`. This was meant to avoid browser not firing `change` when the same file is selected twice.

Result: build/tests passed, but user still saw Blazor disconnects.

### 3. Moved upload off Blazor SignalR circuit

Files:

- `CDH_EL\Endpoints\EditorImportEndpoints.cs`
- `CDH_EL\Program.cs`
- `CDH_EL\Components\Pages\Editor.razor`

Added endpoint:

- `POST /editor/import-docx`
- Requires auth.
- Disables antiforgery for HAVIT XHR upload.
- Reads multipart form file named `file`.
- Calls `IElDocxImportService.ImportDocx(...)`.
- Returns JSON `ElDocxImportResult`.

Changed editor input to use HAVIT HTTP upload:

- `UploadUrl="editor/import-docx"`
- `OnChange="StartDocxUploadAsync"`
- `OnFileUploaded="HandleDocxUploadedAsync"`

This avoids `IBrowserFile.OpenReadStream(...)` over Blazor Server circuit.

Result: build/tests passed, but user said still did not work.

### 4. Added DOCX ZIP preflight before GemBox

File: `Lib\Services\Editor\ElDocxImportService.cs`

Added `TryBlockUnsupportedDocxBeforeGemBox(...)`:

- Opens DOCX as `ZipArchive`.
- Reads `word/document.xml`.
- If body XML contains `<w:tbl`, returns a normal blocked `ElDocxImportResult` with finding:
  - severity: `Error`
  - code: `body_table`
  - message: `The document body contains one or more tables. Tables are not supported in engagement-letter body content; remove them and re-import.`
- This runs before `DocumentModel.Load(...)`.

Also wrapped `DocumentModel.Load(...)` in `try/catch` so managed GemBox load exceptions return a `docx_load_failed` import finding.

Reason: VS output showed process death around compression/DOCX load path. If the failing DOCX has body tables, there is no reason to call GemBox at all because tables are blocked anyway.

Result: build/tests passed. User has not yet reported whether this latest preflight change fixes the process death.

## Current Verification Status

Last verification commands passed:

```powershell
dotnet test Lib.Tests\Lib.Tests.csproj --no-restore --filter ElDocxImportServiceTests -v:minimal
dotnet build CDH_EL\CDH_EL.csproj --no-restore -v:minimal -p:OutDir=..\artifacts\verify-build\
```

Latest results:

- `ElDocxImportServiceTests`: 18/18 passed.
- `CDH_EL` build succeeded.
- Existing warnings:
  - `Lib\Services\Editor\ElGemBoxTiptapBodyImporter.cs(236,40)`: `Field.ResultInlines` obsolete.
  - `CDH_EL\Program_Helpers.cs(26,30)` and `(44,30)`: unused variable `ex`.

## Important Files

- Editor UI/upload:
  - `CDH_EL\Components\Pages\Editor.razor`
- Upload endpoint:
  - `CDH_EL\Endpoints\EditorImportEndpoints.cs`
- Endpoint registration:
  - `CDH_EL\Program.cs`
- Import service:
  - `Lib\Services\Editor\ElDocxImportService.cs`
- Direct GemBox body mapper:
  - `Lib\Services\Editor\ElGemBoxTiptapBodyImporter.cs`
- Result types:
  - `Lib\Services\Editor\ElTiptapSchemaResults.cs`
- Tests:
  - `Lib.Tests\Services\Editor\ElDocxImportServiceTests.cs`

## Best Remaining Hypotheses

1. **GemBox hard-crashes on the user's DOCX.**
   - The process exits with `0xffffffff`, no managed exception.
   - Output shows `System.IO.Compression.dll` load near failure.
   - If preflight now prevents GemBox from seeing table DOCX, it may fix table-heavy files.

2. **The DOCX has unsupported content not caught by table preflight.**
   - Add more preflight checks before GemBox:
     - malformed ZIP
     - encrypted document markers
     - large embedded media
     - external relationships
     - content controls
     - altChunk
   - Return import findings before `DocumentModel.Load(...)`.

3. **HAVIT upload endpoint still reaches GemBox and process dies before response.**
   - Verify by adding temporary logging to `EditorImportEndpoints` before/after:
     - form read
     - file copied
     - `ImportDocx` entered
     - preflight result returned
     - `DocumentModel.Load` entered/exited
   - Use `Console.WriteLine` or `ILogger`.

4. **Need to abandon GemBox for import.**
   - If process still exits after preflight, safest route is a pure OpenXML importer:
     - read `word/document.xml` with `ZipArchive` + XML parser
     - map paragraphs/headings/runs/DOCVARIABLE-like fields
     - block tables before mapping
     - skip headers/footers/furniture
   - Keep GemBox for PDF/export only.

## Suggested Next Steps

1. Have user retest latest preflight build.
2. If it still exits, ask for failing DOCX or reproduce with same file locally.
3. Add temporary endpoint/import trace logs around every boundary listed above.
4. If logs stop at `DocumentModel.Load`, stop using GemBox for import and implement minimal OpenXML body importer.
5. Keep current HTTP upload endpoint. Do not go back to Blazor circuit file streaming.

## Notes For Next Agent

- Do not rely on browser console alone. It only shows circuit loss after server dies.
- Need server-side logs or a reproducible file.
- User has been hitting process/port conflicts because app processes stayed alive during testing. Check and stop:

```powershell
Get-Process CDH_EL -ErrorAction SilentlyContinue
netstat -ano | Select-String ':5159|:7145'
Stop-Process -Id <pid>
```

- Current app ports:
  - HTTP: `5159`
  - HTTPS: `7145`
- Existing repo pattern prefers HAVIT for Blazor UI and avoids browser testing in routine verification, but this is a browser/circuit bug, so browser/server logs are relevant.
