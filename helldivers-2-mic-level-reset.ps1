# SETTINGS
$processName = "helldivers2"          # Process name (without .exe)
$minVolume   = 95                     # Minimum mic volume (0 - 100)
$interval    = 1                      # Seconds between checks

Import-Module AudioDeviceCmdlets -ErrorAction Stop

Write-Host "Starting Helldivers 2 mic volume monitor..."
Write-Host "Minimum mic volume: $minVolume%"
Write-Host "Checking every $interval seconds."

$numOfRetryAttempts = 3
$retryAttempts = $numOfRetryAttempts

while ($retryAttempts -ne 0) {
    # Check if Helldivers 2 is running
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        # Game is running — monitor mic volume
        $currentVolume = Get-AudioDevice -RecordingVolume

        if ($currentVolume -ge 0 -and $currentVolume -lt $minVolume) {
            Write-Host "Mic volume is $currentVolume. Restoring to $minVolume%..."
            Set-AudioDevice -RecordingVolume $minVolume
        } else {
            Write-Host "Mic volume OK: $currentVolume"
        }
    } else {
        Write-Host "Helldivers 2 not running. Waiting..."
        $retryAttempts--
    }

    Start-Sleep -Seconds $interval
}

Write-Host "Max number of retries ($numOfRetryAttempts) reached. Stopping process."
