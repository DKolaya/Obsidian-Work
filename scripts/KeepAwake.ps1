param(
    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 59
)

# Sends Shift+F15 to foreground app until stopped with Ctrl+C.
$shell = New-Object -ComObject WScript.Shell

Write-Host "Sending Shift+F15 every $IntervalSeconds seconds. Press Ctrl+C to stop."

try {
    while ($true) {
        $shell.SendKeys('+{F15}')
        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
}
