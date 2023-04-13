# syntax=docker/dockerfile:1

FROM satijalab/seurat:develop AS seurat
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update &&\
    apt-get install -y gdebi-core \
    curl &&\
    rm -rf /var/lib/apt/lists/* &&\
    curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb &&\
    gdebi quarto-linux-amd64.deb &&\
    rm quarto-linux-amd64.deb

# Install R environment 
RUN Rscript -e "install.packages(c('Hmisc',\
    'reticulate',\
    'remotes',\
    'IRkernel' \
    'languageserver',\
    ),repos = 'http://cran.us.r-project.org')" \
    -e "remotes::install_github('satijalab/seurat-data')"\
    -e "SeuratData::InstallData('stxBrain')"\
    --no-save &&\
    rm -rf /tmp/R*

# Install Python Environment
RUN pip install --no-cache-dir \
    jupyterlab \
    jupyterlab_sos \
    sos-rmarkdown \
    tensorflow \
    && Rscript -e "IRkernel::installspec(user = FALSE)"

# Set user and group
ARG user=appuser
ARG group=appuser
ARG uid=1000
ARG gid=1000
RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/sh -m ${user} # <--- the '-m' create a user home directory

# Switch to user
USER ${uid}:${gid}
#CMD jupyter lab --ip 0.0.0.0 --port 8888 --no-browser
CMD bash
