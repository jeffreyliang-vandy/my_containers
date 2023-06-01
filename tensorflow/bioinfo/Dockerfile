FROM jeffreyliang1995/tensorflow:latest as base

COPY ./r-packages.R /home/liang/
COPY ./scikit-fusion /home/liang/scikit-fusion

FROM base as base-bioinfo
RUN conda config --append channels bioconda\
    && mamba install -y \
    r-seurat \
    r-rgcca \
    bioconductor-omicade4 \
    bioconductor-mofadata \
    mofapy \
    && mamba clean -afy

RUN Rscript /home/liang/r-packages.R --no-save && \
    rm -rf /tmp/R*

FROM base-bioinfo as test-bioinfo
RUN  ipython -c "import mofapy; import scikit-fusion"
RUN  Rscript -e "library(Seurat);library(rgCCA);library(omicade4);library(mofadata)" --no-save

FROM base-bioinfo as app-bioinfo
RUN chown app:app -R /home/liang
USER app
WORKDIR /home/liang
EXPOSE 8888
CMD jupyterlab --ip=0.0.0.0 --port=8888 --no-browser 
