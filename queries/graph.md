# Useful Microsoft Graph Queries

## list all public IP addresses

`Resources
| where type contains 'publicIPAddresses' and isnotempty(properties.ipAddress)
| project properties.ipAddress
| limit 100`

``` Powershell
Search-AzGraph -Query "Resources | where type contains 'publicIPAddresses' and isnotempty(properties.ipAddress) | project properties.ipAddress | limit 100"
```

## list resources with tag value Environment=POC

``` Powershell
Search-AzGraph -Query "Resources | where tags.Environment=~'POC' | project name"
```

## list virtual machine scale sets capacity and size

``` Powershell
Search-AzGraph -Query "Resources | where type=~ 'microsoft.compute/virtualmachinescalesets' | project subscriptionId, name, location, resourceGroup, Capacity = toint(sku.capacity), Tier = sku.name | order by Capacity desc"
```

## view recent Azure Monitor alerts

``` Powershell
Search-AzGraph -Query "alertsmanagementresources | where properties.essentials.startDateTime > ago(12h) | project   alertId = id,   name,   monitorCondition = tostring(properties.essentials.monitorCondition),   severity = tostring(properties.essentials.severity),   monitorService = tostring(properties.essentials.monitorService),   alertState = tostring(properties.essentials.alertState),   targetResourceType = tostring(properties.essentials.targetResourceType),   targetResource = tostring(properties.essentials.targetResource),   subscriptionId,   startDateTime = todatetime(properties.essentials.startDateTime),   lastModifiedDateTime = todatetime(properties.essentials.lastModifiedDateTime),   dimensions = properties.context.context.condition.allOf[0].dimensions, properties"
```

## get the most recent changes

``` Powershell
# Run Azure Resource Graph query with 'order by'
Search-AzGraph -Query 'resourcechanges | extend changeTime=todatetime(properties.changeAttributes.timestamp) | project changeTime, properties.changeType, properties.targetResourceId, properties.targetResourceType, properties.changes | order by changeTime desc | limit 5'
```

## all changes in the last 24 hours

``` Powershell
Search-AzGraph -Query 'resourcechanges
| extend changeTime = todatetime(properties.changeAttributes.timestamp), targetResourceId = tostring(properties.targetResourceId),
changeType = tostring(properties.changeType), correlationId = properties.changeAttributes.correlationId, 
changedProperties = properties.changes, changeCount = properties.changeAttributes.changesCount
| where changeTime > ago(1d)
| order by changeTime desc
| project changeTime, targetResourceId, changeType, correlationId, changeCount, changedProperties'
```

