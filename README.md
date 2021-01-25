# Prefect & Dask Docker Resources

This repository contains docker image build resources for use with [Prefect](https://docs.prefect.io/core/) as well as [Dask](https://dask.org/). The images in this repository are also meant for cloud orchastration, and are primarily meant to help individuals make the jump from local conceptualization to cloud infrastructure - which I'll admit wasn't as smooth as I expected. Currently, there are 2 main directories that separate what the images are logically built for: prefect-agent-docker and prefect-dask-docker, which each respectfully have their own registry on DockerHub. There is [another "bonus" directory](./orchestration-examples/README.md) containing example flows and resources to assist your planning for using Dask and Prefect to address your data processing needs.

These containerized environments are meant to be as production-ready as possible and are to help other open-source collaborators get their code working in very particular ways that suits them best. To correctly understand the environment needed for Prefect and Dask orchastration, review the general structure of your [Prefect Flow](https://docs.prefect.io/orchestration/flow_config/overview.html). This is defined by three main components:

1. Your [Storage](https://docs.prefect.io/orchestration/flow_config/storage.html#local)
2. Your [Run Config](https://docs.prefect.io/orchestration/flow_config/run_configs.html)
3. Your [Executor](https://docs.prefect.io/orchestration/flow_config/executors.html)


# Prefect - Dask

The [prefect-dask-docker](./prefect-dask-docker/README.md) is for Dask Execution architectures, defined in a Prefect Flow as a [DaskExecutor() object](https://docs.prefect.io/orchestration/flow_config/executors.html#daskexecutor). Currently, the repository has focused primarily around deployment via AWS ECS+Fargate Clusters using [Dask-CloudProvider](https://github.com/dask/dask-cloudprovider), although the use case will be broadly similar across the board here.



# Prefect - Agent

The [prefect-agent-docker](./prefect-agent-docker/README.md) is for running Prefect Agents as a server within your cloud infrastructure. The image is based on Alpine Linux, and is hardened for production deployment. This docker image encapsulates the [Prefect Agent](https://docs.prefect.io/orchestration/agents/overview.html#agent-types), which is essentially an API server with one-way communication following the Hybrid-Execution Model procured by Prefect. Currently, the Agent simply runs on an event loop, but from my experience, is susceptible to falling into disrepair, so I built a mini-server to build and host these agents on whatever infrastructure desired. 



This Repository is still currently under construction, so any questions/concerns will be gladly recieved before getting too deep. Thanks for your interest!
