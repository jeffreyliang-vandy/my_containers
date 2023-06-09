FROM jeffreyliang1995/tensorflow:core as base

USER root

COPY ./r-packages.R /home/$USERNAME/

FROM base as base-bioinfo
RUN conda config --append channels bioconda && \
    echo 'options(BioC_mirror = "https://packagemanager.posit.co/bioconductor")' \
    > /opt/conda/lib/R/etc/Rprofile.site && \
    echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' \
    >> /opt/conda/lib/R/etc/Rprofile.site

RUN mamba install -y \
    r-seurat \
    r-nmf \
    bioconductor-iclusterplus \
    bioconductor-omicade4 \
    bioconductor-mofa2 
RUN mamba clean -atfy && \
    Rscript /home/$USERNAME/r-packages.R --no-save \
    && rm -rf /tmp/*

FROM base-bioinfo as test-bioinfo
RUN  Rscript -e "library(Seurat);library(RGCCA);library(omicade4);library(MOFA2);library(MSFA);library(iclusterplus)" --no-save

FROM base-bioinfo as core
WORKDIR /home/$USERNAME
EXPOSE 8888
CMD ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''", "--NotebookApp.password=''"]


FROM core as visual
## Install jupyterlab
RUN /bin/bash /home/$USERNAME/install_visual.sh

FROM visual as test-visual
WORKDIR /home/$USERNAME
COPY ./supervisord_test.conf /etc/supervisor/conf.d/supervisord.conf
RUN which jupyter && jupyter lab --version
RUN which rstudio-server && rstudio-server verify-installation
RUN which code-server && code-server --version
RUN which quarto && quarto check
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]


FROM visual as dev
USER root
WORKDIR /home/$USERNAME
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/$USERNAME/.cache
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]

FROM visual as app
RUN apt-get clean && \
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/$USERNAME/.cache
RUN chown $USERNAME -R /home/$USERNAME && \
    chown $USERNAME -R /opt/conda/share
WORKDIR /home/$USERNAME
USER $USERNAME
EXPOSE 8080 8787 8888
CMD ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''", "--NotebookApp.password=''"]