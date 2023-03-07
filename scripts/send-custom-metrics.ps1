### Send custom metrics to Azure Monitor via REST API
### https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-store-custom-rest-api

####
####curl -X POST 'https://<location>.monitoring.azure.com/<resourceId>/metrics' \
####-H 'Content-Type: application/json' \
####-H 'Authorization: Bearer <accessToken>' \
####-d @custommetric.json