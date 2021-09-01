#!/bin/sh

set -x

# We start by adding extra apt packages, since pip modules may required library
if [ "$EXTRA_APT_PACKAGES" ]; then
    echo "EXTRA_APT_PACKAGES environment variable found.  Installing."
    apt-get update -y
    apt-get install -y $EXTRA_APT_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing."
    pip install --no-cache $EXTRA_PIP_PACKAGES
fi

if [ "$PREFECT_AGENT_NAME" ]; then
    echo "PREFECT_AGENT_NAME environment variable found."
else
    echo "No PREFECT_AGENT_NAME environment variable found.  Setting default: container-agent."
    export PREFECT_AGENT_NAME=container-agent
fi

if [ "$PREFECT_BACKEND" ]; then
    echo "PREFECT_BACKEND environment variable found.  Setting backend."
    prefect backend $PREFECT_BACKEND
else
    echo "No PREFECT_BACKEND environment variable found.  Running server backend."
    prefect backend server
fi

if [ "$PREFECT_AGENT" ] && [ "$PREFECT_CLOUD_TOKEN" ]; then
    echo "PREFECT_AGENT environment variable found.  Starting Agent on PID1."
    prefect agent $PREFECT_AGENT start \
        --name $PREFECT_AGENT_NAME \
        --token $PREFECT_CLOUD_TOKEN \
        $LABELS
else
    echo "PREFECT_AGENT  environment variable found but no cloud token.  Running additional diagnostics."

    if [ "$PREFECT_AGENT" ]; then
        echo "PREFECT_AGENT environment variable found.  Starting Agent on PID1." 
        prefect agent $PREFECT_AGENT start \
            --name container-agent \
            $LABELS
    else
        echo "No PREFECT_AGENT  environment variable found.  Assuming Local -> starting local"
        prefect backend server
        prefect agent local start \
            --name local-container-agent
    fi

    echo "Environment variables are not set correctly."
fi