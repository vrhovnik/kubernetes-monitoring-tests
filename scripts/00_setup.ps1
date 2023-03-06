### SETUP script to setup the environment to be able to send data to the data collection endpoint
param(
    [Parameter(HelpMessage = "Provide the name of the file")]    
    $EnvFileToReadFrom = ""
)

if ("" -ne $EnvFileToReadFrom) {

    #read the env file and set the environment variables    
    Get-Content $EnvFileToReadFrom | ForEach-Object {
        $name, $value = $_.split('=')
        Set-Content env:\$name $value
    }
    return;
}
else {

    Write-Information "Manual setup of environment variables"
    $tenantId = Read-Host "Enter tenant ID in which data collection rule was created"

    if ("" -eq $tenantId) {
        Write-Error "Tenant ID is required"
        exit
    }

    $env:MonitoringTenantId = $tenantId

    $appId = Read-Host "Enter application ID to have access log ingestion API"

    if ("" -eq $appId) {
        Write-Error "Application ID is required"
        exit
    }

    $env:MonitoringAppId = $appId

    $appSecret = Read-Host "Enter application secret associated with the application ID"
    if ("" -eq $appSecret) {
        Write-Error "Application secret is required"
        exit
    }

    $env:MonitoringAppSecret = $appSecret        
}
Add-Type -AssemblyName System.Web
Write-Output "Environment variables are set, you can now run the script to send data to the data collection endpoint"