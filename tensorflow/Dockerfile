FROM ubuntu:22.04 as base

WORKDIR /home/liang
RUN addgroup --system --gid 1001 app \
    && adduser --system --ingroup app --uid 1001 app \
    && echo "app:password" | chpasswd
ENV HOME=/home/liang
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get install -y \
    curl gdebi-core build-essential \
    openssh-client openssh-server apt-file \
    tzdata gcc g++ make \
    libssl-dev libcurl4-openssl-dev \
    libxml2-dev libgit2-dev \
    libstdc++6 git \
    bash supervisor \
    && apt-get clean

RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"  -O miniconda.sh && \
    bash miniconda.sh -b -p /home/liang/conda -f && \
    rm miniconda.sh
    
ENV PATH=/home/liang/conda/bin:$PATH
ARG PATH=/home/liang/conda/bin:$PATH

RUN conda config --append channels r && \
    #conda config --append channels anaconda && \
    mamba install -c conda-forge -y \
    python=3.10 \
    r-base r-remotes r-units \
    ipython rpy2 r-irkernel\
    jupyterlab ipython-sql \
    && mamba clean -atfy
    

RUN echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' >> /home/liang/conda/lib/R/etc/Rprofile.site && \
    /home/liang/conda/bin/Rscript -e 'remotes::install_github("Enchufa2/rspm")' && \
    /home/liang/conda/bin/Rscript -e 'rspm::enable();rspm::install_sysreqs()' && \
    rm -rf /tmp/*

RUN /home/liang/conda/bin/Rscript -e "IRkernel::installspec(user=F)" --no-save && \
    rm -rf /tmp/*


FROM base as test-base
RUN  mamba list
RUN  jupyter-lab --version
RUN  Rscript -e "IRkernel::installspec()"
CMD /bin/bash


FROM base as base-r

RUN apt-get update && \
    apt-get install -y zlib1g-dev libicu-dev make && \
    apt-get clean

RUN mamba install -c conda-forge -y \
    r-tidyverse \
    r-foreach \
    r-doParallel \
    r-essentials \
    r-biocmanager \
    r-reticulate \
    r-rms \
    r-mice \
    r-geepack \
    r-janitor \
    r-caret \
    r-zoo \
    r-ggfortify \
    r-ggridges \
    r-ggthemes \
    r-gridextra \
    r-kableextra \
    r-ranger \
    && mamba clean -atfy

# install from RSPM
RUN /home/liang/conda/bin/Rscript -e "rspm::enable(); \
    install.packages(c(\
     'Hmisc',\
     'survminer', \
     'languageserver'\
     )\
    ,repos = 'https://packagemanager.rstudio.com/cran/__linux__/jammy/2023-01-02+Ln8SRL1B' \
    )" --no-save && \
    rm -rf /tmp/*

ENV RETICULATE_PYTHON=/home/liang/conda/bin/python

FROM base-r as test-r
RUN which jupyter && jupyter-lab --version
RUN which python && python --version
RUN Rscript -e "library(Hmisc);library(tidyverse);library(reticulate);library(caret);library(ranger)"

FROM base-r as base-r-python

RUN mamba install -c conda-forge -y \
    tensorflow \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scipy \
    keras \
    scikit-learn \
    sqlalchemy \
    && mamba clean -afy

FROM base-r-python as test-r-python
# RUN chown app:app -R /home/liang
# USER app
RUN ipython -c "import tensorflow as tf; print(tf.__version__);\
    import pandas as pd;import scipy.stats as stats;import numpy as np;\
    import matplotlib.pyplot as plt;import seaborn as sns;\
    import sklearn;import keras;import sqlalchemy"
RUN ipython -c "%load_ext rpy2.ipython"
RUN which python && python --version
RUN which jupyter && jupyter lab --version


FROM base-r-python as visual-r-python
## Install jupyterlab
RUN mamba install -c conda-forge -y \
    jupyterlab notebook \
    jupytext \
    jupyter-rsession-proxy && \
    mamba clean -atfy && \
    jupyter labextension enable jupyterlab-jupytext && \
    jupyter serverextension enable jupytext

RUN echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> /home/liang/.jupyter/jupyter_notebook_config.py &&\
    wget "https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json" -P  /home/liang/.jupyter/labconfig/

## Install quarto
RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.336/quarto-1.3.336-linux-amd64.deb" && \
    apt-get install -y ./quarto*.deb && \
    rm quarto*.deb

## Install Rstudio
RUN apt-get update && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.03.0-386-amd64.deb &&\
    apt-get install -y ./rstudio-server-2023.03.0-386-amd64.deb && \
    apt-get install -y \
    lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev \
    libclang-common-14-dev libclang-dev libclang1-14 libgc1 \
    libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev psmisc sudo &&\
    rm rstudio*.deb && \
    rm -rf /tmp/* && \
    apt-get clean
RUN echo "auth-required-user-group=root,app" >> /etc/rstudio/rserver.conf
ENV RSTUDIO_WHICH_R=/home/liang/conda/bin/R

## Install code-server
RUN mamba install -c conda-forge -y \
    code-server \
    && mamba clean -atfy
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension REditorSupport.r && \
    code-server --install-extension Github.copilotvs && \
    code-server --install-extension quarto.quarto
ENV SHELL /bin/bash

FROM visual-r-python as test-visual
WORKDIR /home/liang
COPY ./supervisord_test.conf /etc/supervisor/conf.d/supervisord.conf
RUN which jupyter && jupyter lab --version
RUN which rstudio-server && rstudio-server verify-installation
RUN which code-server && code-server --version
RUN which quarto && quarto check
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]


FROM visual-r-python as dev
USER root
WORKDIR /home/liang
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/liang/.cache
COPY ./supervisord_test.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]

FROM visual-r-python as app
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/liang/.cache
RUN chown app:app -R /home/liang
WORKDIR /home/liang
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080 8787 8888
CMD ["/home/liang/conda/bin/code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]


