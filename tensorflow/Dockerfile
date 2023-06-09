FROM ubuntu:22.04 as base

ENV USERNAME=app
RUN addgroup --system --gid 1001 app \
    && adduser --system --ingroup app --uid 1001 ${USERNAME} \
    && echo "${USERNAME}:password" | chpasswd
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}
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
    bash miniconda.sh -b -p /opt/conda -f && \
    rm miniconda.sh
    
ENV PATH=/opt/conda/bin:$PATH
ARG PATH=/opt/conda/bin:$PATH

RUN conda config --append channels r && \
    mamba install -c conda-forge -y \
    python=3.10 \
    r-base r-remotes r-units \
    ipython rpy2 r-irkernel\
    jupyterlab ipython-sql \
    && mamba clean -atfy
    

RUN echo 'options(repos = c(REPO_NAME = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' >> /opt/conda/lib/R/etc/Rprofile.site && \
    /opt/conda/bin/Rscript -e 'remotes::install_github("Enchufa2/rspm")' && \
    /opt/conda/bin/Rscript -e 'rspm::enable();rspm::install_sysreqs()' && \
    rm -rf /tmp/*

RUN /opt/conda/bin/Rscript -e "IRkernel::installspec(user=F)" --no-save && \
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
    r-hmisc \
    r-rms \
    r-mice \
    r-geepack \
    r-arsenal \
    r-patchwork \
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
RUN /opt/conda/bin/Rscript -e "rspm::enable(); \
    install.packages(c(\
     'survminer', \
     'languageserver'\
     )\
    ,repos = 'https://packagemanager.rstudio.com/cran/__linux__/jammy/2023-01-02+Ln8SRL1B' \
    )" --no-save && \
    rm -rf /tmp/*

ENV RETICULATE_PYTHON=/opt/conda/bin/python

FROM base-r as test-r
RUN which jupyter && jupyter-lab --version
RUN which python && python --version
RUN Rscript -e "library(Hmisc);library(tidyverse);library(reticulate);library(caret);library(ranger);library(rms);library(survminer)"

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
# RUN chown app:app -R /home/${USERNAME}
# USER app
RUN ipython -c "import tensorflow as tf; print(tf.__version__);\
    import pandas as pd;import scipy.stats as stats;import numpy as np;\
    import matplotlib.pyplot as plt;import seaborn as sns;\
    import sklearn;import keras;import sqlalchemy"
RUN ipython -c "%load_ext rpy2.ipython"
RUN which python && python --version
RUN which jupyter && jupyter lab --version


FROM base-r-python as core
COPY ./install_visual.sh ./install_visual.sh
COPY ./vscode-binder ./vscode-binder
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /home/${USERNAME}
EXPOSE 8888
CMD ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''", "--NotebookApp.password=''"]


FROM core as visual
WORKDIR /home/${USERNAME}
ENV RSTUDIO_WHICH_R=/opt/conda/bin/R
ENV SHELL=/bin/bash
RUN /bin/bash ./install_visual.sh

FROM visual as test-visual
WORKDIR /home/${USERNAME}
RUN which jupyter && jupyter lab --version
RUN which rstudio-server && rstudio-server verify-installation
RUN which code-server && code-server --version
RUN code-server --list-extensions
RUN which quarto && quarto check
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]


FROM visual as dev
USER root
WORKDIR /home/${USERNAME}
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/${USERNAME}/.cache
EXPOSE 8080 8787 8888
CMD ["/usr/bin/supervisord"]

FROM visual as app
RUN apt-get clean && \
    mamba clean -atfy && \
    rm -rf /tmp/* && \
    rm -rf /home/${USERNAME}/.cache
RUN chmod 777 -R /home/${USERNAME} && \
    chmod 777 -R /opt/conda
WORKDIR /home/${USERNAME}
USER ${USERNAME}
EXPOSE 8888 8787 8080
CMD ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''", "--NotebookApp.password=''"]


