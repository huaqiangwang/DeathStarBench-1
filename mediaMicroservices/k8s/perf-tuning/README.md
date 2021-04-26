# mediaMicroservices Performance Tuning

This folder contains the documents, scripts as well as the
performance tuning results in an attempt to speed-up the
system performance.

The 'deploy.sh' script is used to deploy a system from scratch, with following tasks:

- Apply patch fixes located in the 'patches' folder.
- Create container images with local files.
- Destroy existing system deployed on k8s if it existed.
- Deploy a new system on k8s.
- Initialize necessary database.

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

### single-instance

This is the scenario that each uService has only one instance.

### baseline

'baseline' is used as a scenario with no general performance
optimization changes, which defines the software and hardware
configuration baseline for later optimization scenario.

### cpu-pinning
'cpu-pinning' is the scenario that let the containers use
host CPU exclusively. Performance difference will be observed
under this scenario.

