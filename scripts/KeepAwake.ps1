param(
    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 59
)

# Sends Shift+F16 to foreground app until stopped with Ctrl+C.
$shell = New-Object -ComObject WScript.Shell

Write-Host "Sending Shift+F16 every $IntervalSeconds seconds. Press Ctrl+C to stop."

try {
    while ($true) {
        $shell.SendKeys('+{F16}')
        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
}
