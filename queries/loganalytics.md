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