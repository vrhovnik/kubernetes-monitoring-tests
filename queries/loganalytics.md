# Log analytics queries

Log analytics specific queries

## get the information when daily quota is exceeded
    
`_LogOperation | where Category =~ "Ingestion" | where Detail contains "OverQuota"`

## data volumes between daily cap resets

`
let DailyCapResetHour=14; # data is reset at 2pm UTC - define your own value
Usage
| where DataType !in ("SecurityAlert", "SecurityBaseline", "SecurityBaselineSummary", "SecurityDetection", "SecurityEvent", "WindowsFirewall", "MaliciousIPCommunication", "LinuxAuditLog", "SysmonEvent", "ProtectionStatus", "WindowsEvent")
| where TimeGenerated > ago(32d)
| extend StartTime=datetime_add("hour",-1*DailyCapResetHour,StartTime)
| where StartTime > startofday(ago(31d))
| where IsBillable
| summarize IngestedGbBetweenDailyCapResets=sum(Quantity)/1000. by day=bin(StartTime , 1d) // Quantity in units of MB
| render areachart`

## manage log alert rules with PowerShell

``` Powershell

# create scheduled query rule
$subscriptionId=(Get-AzContext).Subscription.Id
$dimension = New-AzScheduledQueryRuleDimensionObject -Name Computer -Operator Include -Value *
$condition=New-AzScheduledQueryRuleConditionObject -Dimension $dimension -Query "Perf | where ObjectName == `"Processor`" and CounterName == `"% Processor Time`" | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer" -TimeAggregation "Average" -MetricMeasureColumn "AggregatedValue" -Operator "GreaterThan" -Threshold "70" -FailingPeriodNumberOfEvaluationPeriod 1 -FailingPeriodMinFailingPeriodsToAlert 1
New-AzScheduledQueryRule -Name test-rule -ResourceGroupName test-group -Location eastus -DisplayName test-rule -Scope "/subscriptions/$subscriptionId/resourceGroups/test-group/providers/Microsoft.Compute/virtualMachines/test-vm" -Severity 4 -WindowSize ([System.TimeSpan]::New(0,10,0)) -EvaluationFrequency ([System.TimeSpan]::New(0,5,0)) -CriterionAllOf $condition
```

## Billed ContainerLog volume by LogEntrySource (stdout, stderr, etc.)

`ContainerLog
| where TimeGenerated > ago(1h)
| where _IsBillable == true
| summarize BillableDataMBytes = sum(_BilledSize)/ (1000. * 1000.) by LogEntrySource
| render piechart`

## Which Kubernetes namespaces are generating the most data?

`let startTime = ago(24h);
let containerLogs = ContainerLog
| where TimeGenerated > startTime
| where _IsBillable == true
| summarize BillableDataMBytes = sum(_BilledSize)/ (1000. * 1000.) by LogEntrySource, ContainerID;
let kpi = KubePodInventory
| where TimeGenerated > startTime
| distinct ContainerID, Namespace;
containerLogs
| join kpi on $left.ContainerID == $right.ContainerID
| extend sourceNamespace = strcat(LogEntrySource, "/", Namespace)
| summarize MB=sum(BillableDataMBytes) by sourceNamespace
| render piechart`

## size of all environment variables in MB collected by the agent

`ContainerInventory
| where TimeGenerated > ago(1h)
| summarize envvarsMB = sum(string_size(EnvironmentVar)) / (1000. * 1000.)`

## Completed jobs in the last 24 hours

`
let startTime = ago(1h);
let kpi = KubePodInventory
| where TimeGenerated > startTime
| where _IsBillable == true
| where PodStatus in ("Succeeded", "Failed")
| where ControllerKind == "Job";
let containerInventory = ContainerInventory
| where TimeGenerated > startTime
| where _IsBillable == true
| summarize BillableDataMBytes = sum(_BilledSize)/ (1000. * 1000.) by ContainerID;
let containerInventoryMB = containerInventory
| join kpi on $left.ContainerID == $right.ContainerID
| summarize MB=sum(BillableDataMBytes);
let kpiMB = kpi
| summarize MB = sum(_BilledSize)/ (1000. * 1000.);
union
(containerInventoryMB),(kpiMB)
| summarize doneJobsInventoryMB=sum(MB)`

