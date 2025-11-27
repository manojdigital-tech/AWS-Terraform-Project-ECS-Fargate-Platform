# SLIs, SLOs, Error Budgets

## SLIs (Service Level Indicators)
1. **Availability (HTTP success rate)**  
   - Source: ALB TargetResponseCode counts.  
   - Measurement: % of HTTP 2xx/3xx responses for `/health` over 1-minute intervals.

2. **Latency (p95)**  
   - Source: ALB TargetResponseTime metric.  
   - Measurement: 95th percentile request latency over 5-minute intervals.

3. **Error Rate**  
   - Source: ALB 5xx count.  
   - Measurement: 5xx responses as a percentage of all responses over 5-minute intervals.

## SLOs (Service Level Objectives)
- **Availability:** ≥ 99.95% over 30 days.  
- **Latency p95:** ≤ 300 ms over 30 days.  
- **Error Rate:** ≤ 0.5% over 30 days.

## Error Budgets
- Availability error budget monthly = 0.05% downtime (~22 minutes).  
- Breach consumes budget rapidly; SRE must throttle releases or freeze changes.

## Alert Policies
- **High Burn Rate (fast):**  
  - Condition: 99.95% SLO breached at 2× burn over 1 hour.  
  - Action: Page on-call via SNS → PagerDuty/Slack.

- **Sustained Degradation (slow):**  
  - Condition: error_rate > 0.5% for 15 minutes.  
  - Action: Notify SRE channel for investigation.

- **Latency (p95):**  
  - Condition: p95 > 300ms for 10 minutes.  
  - Action: Notify SRE.

## Monitoring Sources
- CloudWatch Metrics: ALB, ECS service CPU/memory, EC2 metrics.  
- CloudWatch Logs: application logs and DB logs.  
- Dashboards: latency, error rate, CPU/memory, connections, container restarts.

## Ownership & Escalation
- **SLO Owner:** SRE Owner - Aashish  
- **Incident Commander:** SRE / On-Call rotation.  
- **Infra Owner:** Aashish  
- **Security Owner:** Aashish  

## Reporting
- Weekly SLO report generated manually from CloudWatch metrics.
- Monthly error budget review required; incidents documented and linked to SLO breaches.

