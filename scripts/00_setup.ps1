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
    Write-Information "Data has been read from the file $EnvFileToReadFrom and environment variables have been set"    
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
    
    $dataCollId = Read-Host "Enter DCR immutable ID"
    if ("" -eq $dataCollId) {
        Write-Error "DCR immutable IDrequired"
        exit
    }

    $env:DataCollectionId = $dataCollId 

    $dataCollUrl = Read-Host "Enter Data collection endpoint URI"
    if ("" -eq $dataCollUrl) {
        Write-Error "Data collection endpoint URI is required"
        exit
    }

    $env:DataCollectionUrl = $dataCollUrl 
}

# Import the System.Web assembly to be able to use the HttpUtility class
Add-Type -AssemblyName System.Web

Write-Output "Environment variables are set (data below), you can now run the script to send data to the data collection endpoint"
Write-Output "----------------------------------------------------------------------------------------------------------------"
Write-Output "Tenant ID: $env:MonitoringTenantId"
Write-Output "App ID: $env:MonitoringAppId"
Write-Output "Secret ID: $env:MonitoringAppSecret"
Write-Output "DCR immutable ID: $env:DataCollectionId"
Write-Output "Data collection endpoint URI: $env:DataCollectionUrl"
Write-Output "----------------------------------------------------------------------------------------------------------------"