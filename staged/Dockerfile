FROM python:3.8.0-slim AS builder



# Copy bash scripts to trigger a given service
COPY setup_hard.sh /bin/setup_hard.sh
COPY setup_agent.sh /bin/setup_agent.sh

RUN apt-get update \
    && apt-get install tini \
    && pip install --no-cache-dir \
    "prefect[aws,github]==0.14.16" \
    "PyGithub" \
    "distributed==2021.2.0" \
    "dask[complete]==2021.2.0" \
    "dask-cloudprovider[aws]" \
    "s3fs" \
    "pyarrow==3.0.0"


FROM builder as agent
COPY --from=builder /bin/setup_agent.sh /bin/setup_agent.sh

RUN chmod +x /bin/setup_agent.sh

ENTRYPOINT ["/usr/bin/tini", "-s", "-g", "--", "/bin/setup_agent.sh"]
# docker build --target agent -t brontomerus/prefect-agent:latest .
# docker push brontomerus/prefect-agent:latest

FROM builder as hardened
COPY --from=builder /bin/setup_hard.sh /bin/setup_hard.sh

RUN chmod +x /bin/setup_hard.sh

ENTRYPOINT ["/usr/bin/tini", "-s", "-g", "--", "/bin/setup_hard.sh"]
# docker build --target hardened -t brontomerus/prefect-hardened-server:latest .
# docker push brontomerus/prefect-hardened-server:latest