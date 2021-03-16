#!/bin/bash

# copied this from dask's base image here: https://github.com/dask/dask-docker/blob/main/base/prepare.sh
# wanted to emulate their process but have my own container to guard against sudden changes. Made some minor updates in this.
set -x

# We start by adding extra apt packages, since pip modules may required library
if [ "$EXTRA_APT_PACKAGES" ]; then
    echo "EXTRA_APT_PACKAGES environment variable found.  Installing."
    apt update -y
    apt install -y $EXTRA_APT_PACKAGES
fi

if [ -e "/opt/app/environment.yml" ]; then
    echo "environment.yml found. Installing packages"
    /opt/conda/bin/conda env update -f /opt/app/environment.yml
else
    echo "no environment.yml"
fi

if [ "$EXTRA_CONDA_PACKAGES" ]; then
    echo "EXTRA_CONDA_PACKAGES environment variable found.  Installing."
    /opt/conda/bin/conda install -y $EXTRA_CONDA_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing".
    echo "installing the following packages: " 
    python -m pip install -U pip
    /opt/conda/bin/pip install --no-cache $EXTRA_PIP_PACKAGES
fi

# Run extra commands
exec "$@"