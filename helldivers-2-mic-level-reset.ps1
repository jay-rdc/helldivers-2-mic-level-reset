# SETTINGS
$processName = "helldivers2"          # Process name (without .exe)
$minVolume   = 95                     # Minimum mic volume (0 - 100)
$interval    = 1                      # Seconds between checks

Import-Module AudioDeviceCmdlets -ErrorAction Stop

Write-Host "Starting Helldivers 2 mic volume monitor..."
Write-Host "Minimum mic volume: $minVolume%"
Write-Host "Checking every $interval second(s)."

$numOfRetryAttempts = 3
$retryAttempts = $numOfRetryAttempts

# Timestamp is instantiated here so it can be referenced outside of the while loop
$timestamp = "[$(Get-Date -Format 'HH:mm:ss')]"
while ($retryAttempts -ne 0) {
    $processIsRunning = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($processIsRunning) {
        $currentVolume = Get-AudioDevice -RecordingVolume

        if ($currentVolume -ge 0 -and $currentVolume -lt $minVolume) {
            Write-Host "$timestamp Mic volume is $currentVolume. Restoring to $minVolume%..." -ForegroundColor Yellow
            Set-AudioDevice -RecordingVolume $minVolume
        } else {
            Write-Host "$timestamp Mic volume OK: $currentVolume" -ForegroundColor Green
        }
    } else {
        Write-Host "$timestamp Helldivers 2 not running. Waiting..."
        $retryAttempts--
    }

    # Force garbage collection each loop to avoid memory leaks
    [System.GC]::Collect()

    Start-Sleep -Seconds $interval

    # Update timestamp after interval
    $timestamp = "[$(Get-Date -Format 'HH:mm:ss')]"
}

Write-Host "$timestamp Max number of retries ($numOfRetryAttempts) reached. Stopping process." -ForegroundColor Red
[System.GC]::Collect()
Exit
