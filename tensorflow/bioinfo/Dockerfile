FROM jeffreyliang1995/tensorflow:dev as base

USER root

COPY ./r-packages.R /home/liang/

FROM base as base-bioinfo
RUN conda config --append channels bioconda && \
    echo 'options(BioC_mirror = "https://packagemanager.posit.co/bioconductor")' \
    > /opt/conda/lib/R/etc/Rprofile.site && \
    echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' \
    >> /opt/conda/lib/R/etc/Rprofile.site

RUN mamba install -y \
    r-seurat \
    r-nmf

RUN Rscript /home/liang/r-packages.R --no-save && \
    rm -rf /tmp/R*

FROM base-bioinfo as test-bioinfo
RUN  Rscript -e "library(Seurat);library(RGCCA);library(omicade4);library(MOFA2);library(MSFA)" --no-save

FROM base-bioinfo as dev
USER root
WORKDIR /home/liang
EXPOSE 8080
EXPOSE 8787
CMD jupyter lab --ip=0.0.0.0 --port=8080 --no-browser --allow-root

FROM base-bioinfo as app
RUN chown app:app -R /home/liang && \
    chown app:app -R /opt/conda
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy
USER app
WORKDIR /home/liang
EXPOSE 8080
EXPOSE 8787
CMD jupyter lab --ip=0.0.0.0 --port=8080 --no-browser 
