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

