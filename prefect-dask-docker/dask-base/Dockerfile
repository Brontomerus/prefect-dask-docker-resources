FROM continuumio/miniconda3:4.8.2

RUN conda install --yes \
    -c conda-forge \
    python==3.8 \
    python-blosc \
    cytoolz \
    dask==2021.4.1 \
    lz4 \
    nomkl \
    numpy==1.18.1 \
    pandas==1.0.1 \
    tini==0.18.0 \
    && conda clean -tipsy \
    && find /opt/conda/ -type f,l -name '*.a' -delete \
    && find /opt/conda/ -type f,l -name '*.pyc' -delete \
    && find /opt/conda/ -type f,l -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete \
    && rm -rf /opt/conda/pkgs

COPY prepare.sh /usr/bin/prepare.sh

RUN chmod +xr /usr/bin/prepare.sh \
    && mkdir /opt/app     

# ENTRYPOINT ["tini", "-g", "--", "/usr/bin/prepare.sh"]


# docker build . -t dask-test:latest
# docker run -i -t -e EXTRA_CONDA_PACKAGES="conda install --yes -c s3fs prefect[aws,github]==0.14.16 pyarrow==3.0.0" dask-test bash

 	


# RUN conda install --yes \
#     -c conda-forge \
#     python==3.8 \
#     python-blosc \
#     cytoolz \
#     dask==2021.3.0 \
#     lz4 \
#     nomkl \
#     numpy==1.18.1 \
#     pandas==1.0.1 \
#     s3fs==0.5.2 \
#     pyarrow==3.0.0 \
#     tini==0.18.0 \
#     && conda clean -tipsy \
#     && find /opt/conda/ -type f,l -name '*.a' -delete \
#     && find /opt/conda/ -type f,l -name '*.pyc' -delete \
#     && find /opt/conda/ -type f,l -name '*.js.map' -delete \
#     && find /opt/conda/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete \
#     && rm -rf /opt/conda/pkgs

# COPY setup.sh /bin/setup.sh

# RUN chmod +xr /bin/setup.sh \
#     && mkdir /opt/app 
    


# ENTRYPOINT ["tini", "-g", "--", "/bin/setup.sh"]