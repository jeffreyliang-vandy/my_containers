FROM jeffreyliang1995/tensorflow:latest as base


FROM base as base-r-python-mne
RUN mamba install -c conda-forge -y \
    mne \
    mat73 \
     && mamba clean -afy

FROM base-r-python-mne as app-mne
RUN chown app:app -R /home/liang
# RUN chown app:app -R /opt/conda
USER app
WORKDIR /home/liang
EXPOSE 8888
CMD jupyterlab --ip=0.0.0.0 --port=8888 --no-browser