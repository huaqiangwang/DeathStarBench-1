# socialNetwork Performance Tuning

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
  ./measure.sh baseline
```
