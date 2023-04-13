FROM jupyter/datascience-notebook:latest as base

RUN pip install --no-cache-dir \
    ipython \
    ipython-sql \
    jupyterlab

FROM base as base-r
# Install R
RUN /opt/conda/bin/Rscript -e "install.packages(c(\
     'Hmisc',\
     'BiocManager', \
     'reticulate', \
     'rms', \
     'mice', \
     'geepack', \
     'janitor', \
     'caret', \
     'survminer', \
     'ggfortify', \
     'ggridges', \
     'gridExtra', \
     'kableExtra', \
     'languageserver'), \
     repos = 'http://cran.us.r-project.org')"\
      --no-save && \
    rm -rf /tmp/R*

FROM base-r as test-r
RUN Rscript -e "library(Hmisc);library(tidyverse);library(reticulate)"

FROM base-r as base-r-python

RUN pip install --no-cacahe-dir \
    tensorflow-cpu

FROM base-r-python as test-r-python
RUN ipython -c "import tensorflow as tf; print(tf.__version__);import pandas as pd"
RUN ipython -c "%load_ext rpy2.ipython"


FROM base-r-python as app
CMD /bin/bash