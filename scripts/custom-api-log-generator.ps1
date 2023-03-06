################
##### Description: This script sends logs to Log Analytics via the data collection 
##### More info at: https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal
################
################
##### Usage
################
# LogGenerator.ps1
#   -Log <String>              - Log file to be forwarded
#   [-DcrImmutableId <string>] - DCR immutable ID
#   [-DceURI]                  - Data collection endpoint URI
#   [-Table]                   - The name of the custom log table, including "_CL" suffix

param (
    [Parameter(HelpMessage = "Log file to be forwarded")] 
    [ValidateNotNullOrEmpty()]
    [string]$Log, 
    [Parameter(HelpMessage = "DCR immutable ID")]
    [ValidateNotNullOrEmpty()]
    [string]$DcrImmutableId, 
    [Parameter(HelpMessage = "Data collection endpoint URI")]
    [ValidateNotNullOrEmpty()]
    [string]$DceURI,
    [Parameter(HelpMessage = "The name of the custom log table, including "_CL" suffix")]
    [ValidateNotNullOrEmpty()]
    [string]$Table
)

# Information needed to authenticate to Azure Active Directory and obtain a bearer token
$tenantId = $env:MonitoringTenantId
$appId = $env:MonitoringAppId
$appSecret = $env:MonitoringAppSecret = $appSecret

$file_data = Get-Content $Log
Write-Information $file_data
## Obtain a bearer token used to authenticate against the data collection endpoint
$scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type" = "application/x-www-form-urlencoded" };
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token

## Generate and send some data
foreach ($line in $file_data) {
    # We are going to send log entries one by one with a small delay
    $log_entry = @{
        # Define the structure of log entry, as it will be sent
        Time        = Get-Date ([datetime]::UtcNow) -Format O
        Application = "LogGenerator"
        RawData     = $line
    }
    # Sending the data to Log Analytics via the DCR!
    $body = $log_entry | ConvertTo-Json -AsArray;
    $headers = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" };
    $uri = "$DceURI/dataCollectionRules/$DcrImmutableId/streams/Custom-$Table" + "?api-version=2021-11-01-preview";
    $uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers;

    # Let's see how the response looks
    Write-Output $uploadResponse
    Write-Output "---------------------"

    # Pausing for 1 second before processing the next entry
    Start-Sleep -Seconds 1
}

Write-Output "Writing logs from $Log has finished!"