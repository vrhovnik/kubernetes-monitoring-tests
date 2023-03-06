$file_data = Get-Content "../sample-data/sample_access.log"
foreach ($line in $file_data) {
    $log_entry = @{
        # Define the structure of log entry, as it will be sent
        Time = Get-Date ([datetime]::UtcNow) -Format O
        Application = "LogGenerator"
        RawData = $line
    }
    Write-Output $log_entry
}