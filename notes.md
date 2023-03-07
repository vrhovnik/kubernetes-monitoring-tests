# Notes for Kubernetes Monitoring Tests

Testing different options for Monitoring the Azure infrastructure on which Kubernetes is running and how to apply different options to apply monitoring to requirements.

Data collection settings is set to scrape data in 60s. This is the default value. It can be changed in the configmap.

## Change analysis

To see different options, configure [ChangeAnalysis](https://learn.microsoft.com/en-us/azure/azure-monitor/change/change-analysis) if not enabled:

``` Powershell
Register-AzResourceProvider -ProviderNamespace "Microsoft.ChangeAnalysis"
```

## Container insights: Azure Monitor and Log Analytics

Metrics are sent to [metrics database in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-platform-metrics). Log data is sent to [your Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview).

Azure monitor for containers collect environment variables periodically from every container it monitors. They are stored in ContainerInventory table.

Azure Monitor for Containers support exclusion & inclusion lists by metric name. For example if you are scraping say, kubedns metrics in your cluster, there might be hundreds of them that gets scraped by default, but you are most probably using only a handful. Please ensure that you specify a list of metrics to scrape (or exclude others except a few) to save on data ingestion volume. Its very easy to enable scraping and not look into many of those metrics, which will cost in log analytics.

### Data structure and overview

![Container insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/media/container-insights-overview/azmon-containers-architecture-01.png#lightbox)

Data structure in Log Analytics:

![log analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/media/data-platform-logs/logs-structure.png#lightbox)

### Cost optimizations

1. Disable **std-out** logs across the cluster (meaning across all namespaces in the cluster)

`
[log_collection_settings]       
   [log_collection_settings.stdout]          
      enabled = false
`

2. Disable collecting **std-err** logs from ‘dev/test’ namespaces

`	
[log_collection_settings.stderr]          
   enabled = true          
   exclude_namespaces = ["kube-system", "dev-test"]
`

3. Disable environment variable collection across the cluster (applicable to all containers in all k8s namespaces) - check settings [here](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-agent-config#data-collection-settings)

`
[log_collection_settings.env_var]
   enabled = false
`

4. Auto cleanup completed jobs (by specifying cleanup policy in the job definition) - set the ttlSecondsAfterFinished to some time to trigger the cleanup (or 0 to disable it). Check [here](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/)
`
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-with-ttl
spec:
  ttlSecondsAfterFinished: 100
  `
 
### Supported links in documentation

1. [Azure Monitor Ingestion Library](https://devblogs.microsoft.com/azure-sdk/out-with-the-rest-azure-monitor-ingestion-libraries-appear/)
2. [Query Logs from Container Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query)
3. [Syslog events](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/syslog)

## Azure Monitor managed service for Prometheus

Exposing the Prometheus metrics endpoint on the Kubernetes cluster and sending the data to Azure Monitor managed service for Prometheus.

Check, if deamon was deployed successfuly on AKS:

`kubectl get ds ama-metrics-node --namespace=kube-system`

Default **scrape** frequency is 30 seconds. To change it, edit the `prometheus-config` config map in the `kube-system` namespace. Check default configuration [here](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-default).

![Prometheus metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/media/container-insights-prometheus/monitoring-kubernetes-architecture.png#lightbox)

When scraping through pod annotations, ensure you are filtering by namespace, so that you don’t end up scraping pod metrics from in-significant namespaces that you don’t use (ex;- dev-test namespace). This will save on data ingestion volume.

### Azure Network Policy Manager integration

Azure NPM implementation works with the Azure CNI that provides VNet integration for containers. Azure NPM includes informative Prometheus metrics that allow you to monitor and better understand your configurations. It provides built-in visualizations in either the Azure portal or Grafana Labs. You can start collecting these metrics using either Azure Monitor or a Prometheus Server.

Overall, the metrics provide:

1. counts of policies, ACL rules, ipsets, ipset entries, and entries in any given ipset
2. execution times for individual OS calls and for handling kubernetes resource events (median, 90th percentile, and 99th percentile)
3. failure info for handling kubernetes resource events (these will fail when an OS call fails)

`
integrations: |-
    [integrations.azure_network_policy_manager]
        collect_basic_metrics = false
        collect_advanced_metrics = true`

### Supported links in documentation

1. [Prometheus collectors dashboards](https://github.com/Azure/prometheus-collector/tree/main/mixins)
2. [Prometheus Operator](https://prometheus-operator.dev/docs/user-guides/getting-started/)
3. [How to find resource inefficiencies with Kubernetes Monitoring](https://grafana.com/blog/2023/03/03/how-to-optimize-resource-utilization-with-kubernetes-monitoring-for-grafana-cloud/?utm_source=grafana_news&utm_medium=rss)
4. [Send data to Azure Monitor managed service for Prometheus](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-prometheus?tabs=cluster-wide#send-data-to-azure-monitor-managed-service-for-prometheus)
5. [Custom configuration file for Prometheus metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-validate)
