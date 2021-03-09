FROM centos:centos8 AS builder


# install required yum dependencies and then python
RUN dnf upgrade \
    && dnf install python3.8 \
    && pip3 install --update --no-cache \
    && dask \
    && lz4 \
    && nomkl \
    && numpy==1.18.1 \
    && pandas==1.0.1 \
    && tini==0.18.0



# harden
RUN dnf upgrade --security \
    && rm -rf media \
    && rm -rf lost+found \
    && 



COPY prepare.sh /usr/bin/prepare.sh

# ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]