#!/bin/bash
set -e
set -u
set -o pipefail

mamba install -c conda-forge -y \
    jupyterlab notebook \
    jupytext \
    jupyter-rsession-proxy && \
    mamba clean -atfy && \
    jupyter labextension enable jupyterlab-jupytext && \
    jupyter serverextension enable jupytext

# mamba install -c conda-forge -y jupyter-vscode-proxy
cd ./vscode-binder && \
python ./setup.py install && \
cd .. 

echo 'c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"' >> /home/$USERNAME/.jupyter/jupyter_notebook_config.py &&\
    wget "https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json" -q -P  /home/$USERNAME/.jupyter/labconfig/

## Install quarto
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.336/quarto-1.3.336-linux-amd64.deb" -q && \
    apt-get install -y ./quarto*.deb && \
    rm quarto*.deb

## Install Rstudio
apt-get update && \
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.03.0-386-amd64.deb -q &&\
    apt-get install -y ./rstudio-server-2023.03.0-386-amd64.deb && \
    apt-get install -y \
    lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev \
    libclang-common-14-dev libclang-dev libclang1-14 libgc1 \
    libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev psmisc sudo &&\
    rm rstudio*.deb && \
    rm -rf /tmp/* && \
    apt-get clean
echo "auth-required-user-group=root,app,1001" >> /etc/rstudio/rserver.conf
echo "auth-minimum-user-id=100" >> /etc/rstudio/rserver.conf

## Install code-server
mamba install -c conda-forge -y \
    code-server \
    && mamba clean -atfy
# echo "CODE_USERDATADIR=${HOME}/.vscode-server" >> /etc/environment
# echo "CODE_EXTENSIONSDIR=${HOME}/.vscode-server/extensions" >> /etc/environment
code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension REditorSupport.r && \
    code-server --install-extension quarto.quarto
mkdir -p ${HOME}/.vscode-server/extensions
cp -r /opt/conda/share/code-server/extensions ${HOME}/.vscode-server/extensions
# echo "export SHELL=/bin/bash" >> /etc/environment