FROM python:3.8.0-slim AS builder



ENV INFRASTRUCTURE="aws"
ENV PREFECT_AGENT_NAME="AGENT"
ENV PREFECT_AGENT_TYPE="local"
ENV PREFECT_CLOUD_TOKEN=""
ENV PREFECT_AGENT_LABELS=""


RUN apt-get update -y \
    && apt-get install tini \
    && if [ "$EXTRA_APT_PACKAGES" ]; then \
        apt-get install -y $EXTRA_APT_PACKAGES; \
        fi; \
    if [ "$EXTRA_PIP_PACKAGES" ]; then \
        pip install --no-cache $EXTRA_PIP_PACKAGES; \
        fi




FROM builder as agent


# install required software
RUN pip install --no-cache-dir \
    "prefect[aws,github]==0.14.16" \
    "PyGithub" \
    "distributed==2021.2.0" \
    "dask[complete]==2021.2.0" \
    "dask-cloudprovider[aws]" \
    "s3fs" \
    "pyarrow==3.0.0" \
    && prefect backend server
    # && if [ "$PREFECT_AGENT_NAME" ]; then \
    #     echo "creating agent $PREFECT_AGENT_NAME"; \
    # else \
    #     echo "creating agent $PREFECT_AGENT_NAME" export PREFECT_AGENT_NAME=agent; \
    # fi


# ENTRYPOINT / RUN
ENTRYPOINT tini -s -g -- prefect agent ${PREFECT_AGENT_TYPE} start --name ${PREFECT_AGENT_NAME} --token ${PREFECT_CLOUD_TOKEN} ${LABELS}
