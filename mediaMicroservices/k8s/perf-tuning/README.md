# mediaMicroservices Performance Tunning Cases on XEON-6230n

This folder contains the performance tunning scripts and
attempts to speed-up for DSB/mediaMicroservices.

## Hardware Platform

- CPU: Intel XEON6230n

## Scenario
This section defines the scenarios and investigates the
system prformance.

To deploy a system with this scenario, run

```shell
  cd mediaMicroservices/k8s/perf-tuning
  ./deploy.sh <scenario name>

  e.g.
  ./deploy.sh baseline
```

To run wrk test with default http workload pressure, run

```shell
  cd mediaMicroservices/k8s/perf-tuning
  ./measure.sh <scenario name>

  e.g.
  ./measure.sh baseline

```

### baseline

'baseline' is used as a scenario with no general performance
optimization changes, which defines the software and hardware
configuration baseline for later optimization scenario.

### cpu-pinning
'cpu-pinning' is the scenario that let the containers use
host CPU exclusively. Performance difference will be observed
under this scenario.

