# Notes for Kubernetes Monitoring Tests

Testing different options for Monitoring the Azure infrastructure on which Kubernetes is running and how to apply different options to apply monitoring to requirements.

## Container insights: Azure Monitor and Log Analytics

Metrics are sent to [metrics database in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-platform-metrics). Log data is sent to [your Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview).

### Data structure and overview

![Container insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/media/container-insights-overview/azmon-containers-architecture-01.png#lightbox)

Data structure in Log Analytics:

![log analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/media/data-platform-logs/logs-structure.png#lightbox)

Supported links in documentation:

1. [Azure Monitor Ingestion Library](https://devblogs.microsoft.com/azure-sdk/out-with-the-rest-azure-monitor-ingestion-libraries-appear/)
2. [Query Logs from Container Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query)
3. [Syslog events](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/syslog)

## Azure Monitor managed service for Prometheus

Exposing the Prometheus metrics endpoint on the Kubernetes cluster and sending the data to Azure Monitor managed service for Prometheus.

![Prometheus metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/media/container-insights-prometheus/monitoring-kubernetes-architecture.png#lightbox)

Supported links in documentation:

1. [Prometheus Operator](https://prometheus-operator.dev/docs/user-guides/getting-started/)
2. [How to find resource inefficiencies with Kubernetes Monitoring](https://grafana.com/blog/2023/03/03/how-to-optimize-resource-utilization-with-kubernetes-monitoring-for-grafana-cloud/?utm_source=grafana_news&utm_medium=rss)
3. [Send data to Azure Monitor managed service for Prometheus](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-prometheus?tabs=cluster-wide#send-data-to-azure-monitor-managed-service-for-prometheus)
