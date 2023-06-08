#!/bin/bash

mamba install -c conda-forge -y \
    jupyterlab notebook \
    jupytext \
    jupyter-vscode-proxy \
    jupyter-rsession-proxy && \
    mamba clean -atfy && \
    jupyter labextension enable jupyterlab-jupytext && \
    jupyter serverextension enable jupytext

ln -s $(which jupyter) /usr/bin/jupyter

echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py &&\
    wget "https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json" -P  /home/$USERNAME/.jupyter/labconfig/

## Install quarto
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.336/quarto-1.3.336-linux-amd64.deb" && \
    apt-get install -y ./quarto*.deb && \
    rm quarto*.deb

## Install Rstudio
apt-get update && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.03.0-386-amd64.deb &&\
    apt-get install -y ./rstudio-server-2023.03.0-386-amd64.deb && \
    apt-get install -y \
    lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev \
    libclang-common-14-dev libclang-dev libclang1-14 libgc1 \
    libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev psmisc sudo &&\
    rm rstudio*.deb && \
    rm -rf /tmp/* && \
    apt-get clean
echo "auth-required-user-group=root,app" >> /etc/rstudio/rserver.conf
echo "export RSTUDIO_WHICH_R=/home/$USERNAME/conda/bin/R" >> /etc/environment

## Install code-server
mamba install -c conda-forge -y \
    code-server \
    && mamba clean -atfy
ln -s $(which code-server) /usr/bin/code-server
code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension REditorSupport.r && \
    code-server --install-extension quarto.quarto
echo "export SHELL=/bin/bash" >> /etc/environment