# syntax=docker/dockerfile:1

FROM julia:latest

COPY ./install_kernal.jl ./install_kernal.jl

RUN apt-get update &&\
    apt-get install -y gdebi-core \
    curl \
    r-base-core \
    python3 \
    python3-pip &&\
    rm -rf /var/lib/apt/lists/* 

RUN pip install --no-cache-dir \
    jupyterlab \
    ipython \
    julia 
    

RUN julia install_kernal.jl
