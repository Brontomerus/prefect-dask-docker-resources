FROM python:3.8.0-slim AS base

RUN apt-get update \
    && apt-get install tini \
    && if [ "$EXTRA_APT_PACKAGES" ]; then \
    echo "EXTRA_APT_PACKAGES environment variable found.  Installing." \
    apt-get update -y \
    apt-get install -y $EXTRA_APT_PACKAGES \
    fi \
    && if [ "$EXTRA_PIP_PACKAGES" ]; then \
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing." \
    pip install --no-cache $EXTRA_PIP_PACKAGES \
    fi


FROM base as agent

# install required software
RUN pip install --no-cache-dir \
    "prefect[aws,github]==0.14.16" \
    "PyGithub" \
    "distributed==2021.2.0" \
    "dask[complete]==2021.2.0" \
    "dask-cloudprovider[aws]" \
    "s3fs" \
    "pyarrow==3.0.0" \
    "tini" 

ENV INFRASTRUCTURE=aws


# ENTRYPOINT / RUN
ENTRYPOINT ["/usr/bin/tini", "-s", "-g", "--", "prefect agent start"]
