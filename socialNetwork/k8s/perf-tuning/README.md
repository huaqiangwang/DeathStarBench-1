# socialNetwork Performance Tunning Cases on XEON-6230n

This folder contains the performance tunning scripts and
attempts to speed-up for DSB/socialNetwork.

## Hardware Platform

- CPU: Intel XEON6230n

## Scenario

### baseline

'baseline' is used as a scenario with no general performance
optimization changes, which defines the software and hardware
configuration baseline for later optimization scenario.

To deploy a system with this scenario, run

```shell
  cd socialNetwork/k8s/perf-tuning
  ./deploy.sh baseline
```

To run wrk test with default http workload pressure, run

```shell
  cd socialNetwork/k8s/perf-tuning
  ./measure.sh
```
