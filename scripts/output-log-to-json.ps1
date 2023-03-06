##### Description: This script will output the sample_access.log file to a json file
param (
    [Parameter(HelpMessage="filename for json to be stored to")] 
    [string]$fileName="sample_access.json"
)
# Get the current directory
Set-Location "../sample-data"
# Get the content of the file
$file_data = Get-Content "sample_access.log"
$json = @()
# Loop through the file and create a json object
foreach ($line in $file_data) {
    $log_entry = @{        
        Time        = Get-Date ([datetime]::UtcNow) -Format O
        Application = "LogGenerator"
        RawData     = $line
    }
    $json += $log_entry
}
# convert the json object to json string
$json = ConvertTo-Json $json
Write-Information $json
$json | Out-File $fileName -Force
Write-Output "Json has been successfully written to $fileName"