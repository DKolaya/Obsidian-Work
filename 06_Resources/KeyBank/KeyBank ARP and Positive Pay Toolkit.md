---
title: KeyBank ARP and Positive Pay Toolkit
created: 2026-08-06
type: resource
source: "[[06_Resources/KeyBank/ARP.POSPAY Toolkit.pdf]]"
tags:
  - resource/vendor
  - project/orda-positive-pay
---

# KeyBank ARP and Positive Pay Toolkit

Distilled from KeyBank's "Account Reconcilement Plans (ARP) and Positive Pay Transmission Toolkit" (rev 10/17), copied from Downloads into the vault for reference. Full original: [[06_Resources/KeyBank/ARP.POSPAY Toolkit.pdf]]. This is the bank file spec for [[04_Projects/Active/ORDA Positive Pay]] — Drew got it directly rather than waiting on Nathan's distillation.

## What matters for ORDA

Our job is the **export**: pull checks from Intacct, build a **check issue file** with Payee Name Verification and upload it manually to KeyNavigator before the checks go out. That's the "Check Issue Input File — with PNV" format below, in ASCII. The plain "no PNV" format and the whole "Output Files" section (KeyBank → us) don't apply — ORDA is Positive Pay Only, no reconciliation file coming back. Kept below for reference only.

**Resolved via the "FW: ORDA - Positive Pay" email thread** (Ron Graham/ORDA ↔ CDH Intacct Support, Jan–Feb 2026, forwarded by Patrick 2026-07-21 — same PDF attached there, confirms this is the right doc):
- **Payee Name Verification (PNV) is in scope** — Ron Graham explicitly said "the input format is from page 6 and 7," which is the PNV format (not the plain page 4-5 one). Treat PNV as decided, not open.
- **Account scoped to Key Bank Disbursement (GL 1000)** — ORDA has three Key Bank accounts (1000 Disbursement, 1004 Classic Capital, 1023 New Capital), but Positive Pay is specifically against 1000; CDH's existing Intacct Positive Pay Report is likewise scoped only to that account.
- Check template may need updating to "JP Morgan Business" layout for payee-line spacing (CDH's Chelsea Medeiros flagged this back in Feb 2026, to satisfy the ≥0.050in payee-line separation in the PNV formatting rules below) — verify whether this was ever actually done before assuming it's handled.
- Note: a **separate JPMorgan check-format request** exists in the same thread history — unrelated to this KeyBank project, don't conflate.

**Confirmed by Nathan/ORDA 2026-08-06 — all decided, none of this is open anymore:**
- **Positive Pay Only** — no Full Reconciliation. The "Output Files" section above doesn't apply; only the Check Issue Input File (with PNV) matters.
- **ASCII** transmission (KeyBank converts to EBCDIC on their end).
- **Manual upload** via KeyNavigator — no direct/automated transmission. Still need ORDA's mailbox ID and account number for the actual KeyNavigator setup.

**Scope reality check:** `Core_PositivePay` (shared core) has *zero* file-format abstraction — no fixed-width helper, no bank-layout system. Every bit of CSAC's file-building is bank-specific code in their own project, and it's a loose unspecced CSV for M&T, not a strict fixed-width spec like KeyBank's PNV format. Building a KeyBank-compliant fixed-width ASCII writer is new capability for this toolkit, not reuse — worth resetting Nathan/Patrick's "last 10-20%" framing against this if it changes the estimate.

## Check Issue Input File — no PNV (reference only, not what ORDA builds)

Used for Full Reconciliation with Positive Pay, or Positive Pay Only.

- Record Format: EBCDIC or ASCII (ASCII gets converted to EBCDIC on receipt; no report-type formats)
- Block Size: 8000
- Record Length: 80

| Field # | Col Begin | Col End | Description | Format |
|---|---|---|---|---|
| 1 | 1 | 2 | Region Code (unused) | Blank or "00" |
| 2 | 3 | 17 | Account Number | Numeric, zero-filled, right justified |
| 3 | 18 | 27 | Check Number | Numeric, zero-filled, right justified |
| 4 | 28 | 35 | Date | YYYYMMDD |
| 5 | 36 | 45 | Amount | Numeric, zero-filled, right justified, no decimal point |
| 6 | 46 | 46 | Void Character | "C" if void item, otherwise blank |
| 7 | 47 | 61 | Additional Data (optional) | Alpha/numeric, client-specific (shows on ARP reports — mind confidentiality) |
| 8 | 62 | 80 | Not used | |

Example rows (00 = unused region code):
```
00 000000001234567 1000023476 20160614 0000168812    Invoice 2345
00 000000001234567 1000023477 20160614 0006895624 C
00 000000001234567 1000023478 20160615 0000069500
```
A cancel/void (Void Character = "C") is for checks still in physical possession. If already released to payee, issue a stop payment instead of a void.

## Check Issue Input File — with Payee Name Verification (PNV)

Same fields 1–7 as above, plus:

| Field # | Col Begin | Col End | Description | Format |
|---|---|---|---|---|
| 8 | 62 | 136 | Payee Line 1 | CAPITALIZED, exact match to check printing, left justified |
| 9 | 137 | 211 | Payee Line 2 | CAPITALIZED, exact match if check wraps to 2nd line; space-filled if unused. **No address here** — name/identifying info only |
| 10 | 212 | 220 | Filler | Spaces |

Record length becomes 220 total when PNV is used. Payee name on the file must match the printed check **exactly**, character by character (except address, which never goes in the issue file).

### PNV formatting requirements (for check stock/printing)

- Fonts: Times New Roman, Courier, Verdana, Univers, Tahoma, Albertus, Bookman, Zurick
- Font size: 10–24 pt
- Upper-case only, no bold/italic, no decorative/script tags, no leading/trailing asterisks, no dot matrix printer
- Min separation between payee lines: 0.050 in
- Min print contrast signal: 0.60; check background under payee name/address must be white or ≤0.30 contrast, clear for ≥0.25 in around the printing
- Up to 2 lines, 75 chars/line
- One set of recognition coordinates per account — payee name location/font can't vary per routing/account combo

## Output Files (KeyBank → us, reference only — doesn't apply, ORDA is Positive Pay Only)

**Paid Items Only** — EBCDIC, block size 9990, record length 90, full or partial reconciliation, daily or monthly:

| Field # | Col Begin | Col End | Description | Format |
|---|---|---|---|---|
| 1 | 1 | 15 | Account Number | Numeric, zero-filled |
| 2 | 16 | 25 | Check Number | Numeric, zero-filled |
| 3 | 26 | 35 | Amount | Numeric, zero-filled, no decimal |
| 4 | 36 | 41 | Date (paid) | MMDDYY |
| 5 | 42 | 61 | Not used | |
| 6 | 62 | 67 | Issue Date (optional) | MMDDYY, from our issue file |
| 7 | 68 | 75 | Sequence Number (optional) | Numeric |
| 8 | 76 | 90 | Additional Data (optional) | Alpha, echoes what we supplied on issue |

**Complete File** — EBCDIC, block size 9990, record length 90, full reconciliation, based on statement cycle cut:

| Field # | Col Begin | Col End | Description | Format |
|---|---|---|---|---|
| 1 | 1 | 15 | Account Number | Numeric, zero-filled |
| 2 | 16 | 25 | Check Number | Numeric, zero-filled |
| 3 | 26 | 35 | Amount | Numeric, zero-filled, no decimal |
| 4 | 36 | 41 | Paid Date | MMDDYY |
| 5 | 42 | 61 | Not used | |
| 6 | 62 | 67 | Issue Date | MMDDYY |
| 7 | 68 | 84 | Not used | |
| 8 | 85 | 85 | Item Indicator | Alpha: C=Cancel, S=Stop, P=Paid No Issue (paid but no matching issue record), R=Reconciled (paid + matched), O=Outstanding |
| 9 | 86 | 90 | Not used | |

## Operational rules

- Submit the issue file **before** checks go out — by 11:00 PM ET the day *prior* to distribution (including manually-issued checks). Late/missing issue data → "Paid No Issue" exceptions; client is responsible for validating those.
- Manual issue/cancel entry alternative: KeyNavigator → Payables → Account Reconciliation → Check Issue Maintenance.
- **Daily Audit Listing Report** (KeyNavigator, auto-granted, live ~9 AM ET next day) shows prior day's issues/cancels — use it to confirm a file actually processed. A KeyNavigator upload confirmation only proves connectivity, not that the content was valid/loaded.
- Sent a bad file? Don't just resend — email **ARP_Transmissions@KeyBank.com**, subject "Need File Assistance," include name + phone. Resending without backing out first causes the 2nd file to reject (duplicate check numbers).
- Test file + matching test checks (or scanned images) required before going live — 7 business-day turnaround; failures get a call + follow-up email with required corrections.
- New/changed check stock needs MICR line testing first — submit 10+ test checks via Payment Advisor.
- Converting Standard Positive Pay → PNV: no need to resend outstanding issue data (bank already has it); only checks issued after the implementation date go through payee-name recognition.
- Service start date (coincides with DDA statement cycle) vs. implementation date (when testing completes and file goes live) are different things — don't confuse them.
- PNI (Paid No Issue) fees typically waived during testing and briefly after go-live; can apply if testing drags on.

## Links

- [[04_Projects/Active/ORDA Positive Pay]]
- [[06_Resources/KeyBank/ARP.POSPAY Toolkit.pdf]]
