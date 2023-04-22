FROM jupyter/datascience-notebook:latest as base

USER root
WORKDIR /home/jovyan

RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    apt-get update && \
    apt-get install -y gdebi-core && \
    gdebi quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

RUN pip install --no-cache-dir \
    ipython \
    ipython-sql \
    jupyterlab \
    jupytext && \
    jupyter nbextension install --py jupytext --user && \
    jupyter nbextension enable --py jupytext --user && \
    jupyter serverextension enable jupytext --user 

RUN echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> .jupyter/jupyter_notebook_config.py &&\
    wget https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json -P  ~/.jupyter/labconfig/


FROM base as base-r
# add Rstudio Repo
RUN apt-get update && \
    apt-get install -y apt-file

RUN echo 'options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/cran/__linux__/jammy/latest"))' >> /opt/conda/lib/R/etc/Rprofile.site && \
    /opt/conda/bin/Rscript -e 'remotes::install_github("Enchufa2/rspm")' && \
    echo 'rspm::enable()' >> /opt/conda/lib/R/etc/Rprofile.site && \
    /opt/conda/bin/Rscript -e 'rspm::enable();rspm::install_sysreqs()'

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
     'gridExtra', \
     'kableExtra', \
     'languageserver'\
     ))"\
      --no-save && \
    rm -rf /tmp/R*

FROM base-r as test-r
RUN Rscript -e "library(Hmisc);library(tidyverse);library(reticulate);library(caret)"

FROM base-r as base-r-python

RUN pip install --no-cache-dir \
    tensorflow-cpu

FROM base-r-python as test-r-python
RUN ipython -c "import tensorflow as tf; print(tf.__version__);import pandas as pd"
RUN ipython -c "%load_ext rpy2.ipython"


FROM base-r-python as app
## add user named app
RUN useradd -m -s /bin/bash app
USER app
CMD /bin/bash