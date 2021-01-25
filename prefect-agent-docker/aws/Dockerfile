FROM python:3.9-alpine

# install some stuff
RUN apk update \
    && apk add --no-cache linux-headers build-base tini \
    && pip install --no-cache-dir prefect[aws] PyGithub tini


# Harden Image and Start Agent script
COPY setup.sh /bin/setup.sh
RUN chmod +x /bin/setup.sh


# ENTRYPOINT / RUN
ENTRYPOINT ["/sbin/tini", "-s", "-g", "--", "/bin/setup.sh"]
