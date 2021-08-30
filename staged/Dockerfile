FROM python:3.8.0-slim AS base

# install required software
RUN apt-get update \
    && apt-get install tini \
    && pip install --no-cache-dir \
    "prefect[aws,github]==0.14.16" \
    "PyGithub" \
    "distributed==2021.2.0" \
    "dask[complete]==2021.2.0" \
    "dask-cloudprovider[aws]" \
    "s3fs" \
    "pyarrow==3.0.0" \
    "tini" 

ENV INFRASTRUCTURE=aws



FROM base as agent

# Harden Image and Start Agent script
COPY setup.sh /bin/agent_setup.sh
RUN chmod +x /bin/setup.sh


# ENTRYPOINT / RUN
ENTRYPOINT ["/usr/bin/tini", "-s", "-g", "--", "/bin/setup.sh"]