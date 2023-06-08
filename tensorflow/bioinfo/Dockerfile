FROM jeffreyliang1995/tensorflow:dev as base

USER root

COPY ./r-packages.R /home/liang/

FROM base as base-bioinfo
RUN conda config --append channels bioconda && \
    echo 'options(BioC_mirror = "https://packagemanager.posit.co/bioconductor")' \
    > /home/liang/conda/lib/R/etc/Rprofile.site && \
    echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' \
    >> /home/liang/conda/lib/R/etc/Rprofile.site

RUN mamba install -y \
    r-seurat \
    r-nmf \
    && mamba clean -atfy && \
    Rscript /home/liang/r-packages.R --no-save \
    && rm -rf /tmp/*

FROM base-bioinfo as test-bioinfo
RUN  Rscript -e "library(Seurat);library(RGCCA);library(omicade4);library(MOFA2);library(MSFA)" --no-save

FROM base-bioinfo as dev
USER root
WORKDIR /home/liang
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]

FROM base-bioinfo as app
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/liang/.cache
RUN chown app:app -R /home/liang
WORKDIR /home/liang
EXPOSE 8080 8787 8888
CMD ["/home/liang/conda/bin/code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]

