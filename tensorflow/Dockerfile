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
    libstdc++6 git

RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"  -O miniconda.sh && \
    bash miniconda.sh -b -p /home/liang/conda -f && \
    rm miniconda.sh
    
ENV PATH=/home/liang/conda/bin:$PATH
ARG PATH=/home/liang/conda/bin:$PATH

RUN conda config --append channels r && \
    #conda config --append channels anaconda && \
    mamba install -c conda-forge -y r-base r-remotes r-units &&\
    mamba install -c conda-forge -y ipython rpy2 r-irkernel\
    jupyterlab notebook ipython-sql

    
RUN mamba install -c conda-forge -y \
    jupytext \
    jupyter-rsession-proxy && \
    jupyter labextension enable jupyterlab-jupytext && \
    jupyter serverextension enable jupytext

RUN echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' >> /home/liang/conda/lib/R/etc/Rprofile.site && \
    /home/liang/conda/bin/Rscript -e 'remotes::install_github("Enchufa2/rspm")' && \
    /home/liang/conda/bin/Rscript -e 'rspm::enable();rspm::install_sysreqs()' 

RUN /home/liang/conda/bin/Rscript -e "IRkernel::installspec(user=F)" --no-save

RUN echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> /home/liang/.jupyter/jupyter_notebook_config.py &&\
    wget "https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json" -P  /home/liang/.jupyter/labconfig/


RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.336/quarto-1.3.336-linux-amd64.deb" && \
    apt-get install -y ./quarto*.deb && \
    rm quarto*.deb

# RUN mamba install -c conda-forge -y quarto 

RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.03.0-386-amd64.deb &&\
    apt-get install -y ./rstudio-server-2023.03.0-386-amd64.deb && \
    apt-get update && \
    apt-get install -y \
    lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev \
    libclang-common-14-dev libclang-dev libclang1-14 libgc1 \
    libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev psmisc sudo &&\
    rm rstudio*.deb

RUN echo "auth-required-user-group=root,app" >> /etc/rstudio/rserver.conf

ENV RSTUDIO_WHICH_R=/home/liang/conda/bin/R

FROM base as test-base
RUN chown app:app -R /home/liang
#RUN chown app:app -R /home/liang/conda
RUN rstudio-server stop && rstudio-server verify-installation
USER app
RUN  mamba list
RUN  jupyter-lab --version
RUN  quarto check
RUN  Rscript -e "IRkernel::installspec()"
CMD /bin/bash


FROM base as base-r

RUN apt-get update && \
    apt-get install -y zlib1g-dev libicu-dev make

RUN mamba install -y \
    r-tidyverse \
    r-foreach \
    r-doParallel \
    r-essentials \
    r-ranger

# install from RSPM
RUN /home/liang/conda/bin/Rscript -e "rspm::enable(); \
    install.packages(c(\
     'Hmisc',\
     'BiocManager', \
     'reticulate', \
     'rms', \
     'mice', \
     'geepack', \
     'janitor', \
     'caret', \
     'survminer', \
     'zoo', \
     'ggfortify', \
     'ggridges', \
     'ggthemes', \
     'gridExtra', \
     'kableExtra', \
     'languageserver'\
     )\
    ,repos = 'https://packagemanager.rstudio.com/cran/__linux__/jammy/2023-01-02+Ln8SRL1B' \
    )" --no-save && \
    rm -rf /tmp/*

ENV RETICULATE_PYTHON=/home/liang/conda/bin/python

FROM base-r as test-r
RUN chown app:app -R /home/liang
USER app
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
    autoviz \
    && mamba clean -afy

FROM base-r-python as test-r-python
RUN chown app:app -R /home/liang
USER app
RUN ipython -c "import tensorflow as tf; print(tf.__version__);\
    import pandas as pd;import scipy.stats as stats;import numpy as np;\
    import matplotlib.pyplot as plt;import seaborn as sns;\
    import sklearn;import keras;import sqlalchemy;\
    import autoviz;"
RUN ipython -c "%load_ext rpy2.ipython"

FROM base-r-python as dev
USER root
WORKDIR /home/liang
EXPOSE 8080
EXPOSE 8787
CMD jupyter lab --ip=0.0.0.0 --port=8080 --no-browser --allow-root

FROM base-r-python as app
RUN chown app:app -R /home/liang
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy
USER app
WORKDIR /home/liang
EXPOSE 8080
EXPOSE 8787
CMD jupyter lab --ip=0.0.0.0 --port=8080 --no-browser --allow-root


