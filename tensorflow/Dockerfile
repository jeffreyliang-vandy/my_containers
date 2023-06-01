FROM ubuntu:22.04 as base

WORKDIR /home/liang
RUN addgroup --system app && adduser --system --ingroup app app
ENV HOME=/home/liang
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get remove python* -y &&\
    apt-get install -y \
    curl gdebi-core build-essential \
    openssh-client openssh-server apt-file \
    tzdata gcc g++ make \
    libssl-dev libcurl4-openssl-dev \
    libxml2-dev libgit2-dev \
    libstdc++6 git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"  -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda -f && \
    rm miniconda.sh
    
ENV PATH=/opt/conda/bin:$PATH
ARG PATH=/opt/conda/bin:$PATH

RUN conda config --append channels r && \
    mamba install -c conda-forge -y r-base=4.2.3 r-remotes && \
    mamba install -c conda-forge -y ipython rpy2 r-irkernel\
    jupyterlab ipython-sql
    
RUN pip install --no-cache-dir \
    jupytext \
    jupyter-rsession-proxy && \
    jupyter nbextension install --py jupytext --user && \
    jupyter nbextension enable --py jupytext --user && \
    jupyter serverextension enable jupytext --user 
    
RUN echo 'options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/cran/__linux__/jammy/latest"))' >> /opt/conda/lib/R/etc/Rprofile.site && \
    /opt/conda/bin/Rscript -e 'remotes::install_github("Enchufa2/rspm")' && \
    echo 'rspm::disable()' >> /opt/conda/lib/R/etc/Rprofile.site && \
    /opt/conda/bin/Rscript -e 'rspm::enable();rspm::install_sysreqs()' 

RUN /opt/conda/bin/Rscript -e "IRkernel::installspec(user=F)" --no-save

RUN echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> ~/.jupyter/jupyter_notebook_config.py &&\
    wget https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json -P  ~/.jupyter/labconfig/


# RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.336/quarto-1.3.336-linux-amd64.deb && \
#     apt-get install -y ./quarto*.deb && \
#     rm quarto*.deb

# RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.03.0-386-amd64.deb &&\
#     apt-get install -y ./rstudio-server-2023.03.0-386-amd64.deb && \
#     apt-get update && \
#     apt-get install -y \
#     lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev \
#     libclang-common-14-dev libclang-dev libclang1-14 libgc1 \
#     libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev psmisc sudo &&\
#     rm rstudio*.deb && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

RUN mamba install -c conda-forge -y quarto && \
    mamba install -c r -y rstudio

ENV RSTUDIO_WHICH_R=/opt/conda/bin/R

FROM base as test-base
RUN chown app:app -R /home/liang
RUN chown app:app -R /opt/conda
USER app
RUN  mamba list
RUN  quarto check
RUN  Rscript -e "IRkernel::installspec()"
CMD /bin/bash


FROM base as base-r

RUN apt-get update && \
    apt-get install -y zlib1g-dev libicu-dev make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install from RSPM
RUN /opt/conda/bin/Rscript -e "rspm::enable(); \
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
    Rscript -e 'library(Hmisc)' --no-save && \
    rm -rf /tmp/R*

ENV RETICULATE_PYTHON=/opt/conda/bin/python

RUN mamba install -y \
    r-tidyverse \
    r-foreach \
    r-doParallel \
    r-essentials \
    r-ranger

FROM base-r as test-r
RUN chown app:app -R /home/liang
RUN chown app:app -R /opt/conda
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

FROM base-r-python as app-base
RUN chown app:app -R /home/liang
# RUN chown app:app -R /opt/conda
USER app
WORKDIR /home/liang
EXPOSE 8888
CMD jupyterlab --ip=0.0.0.0 --port=8888 --no-browser


