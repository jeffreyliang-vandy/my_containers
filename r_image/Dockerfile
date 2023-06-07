FROM ubuntu:22.04
LABEL version="0.1"
LABEL description="This is the image that have all R packages that I use"
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND=noninteractive 
COPY ./R_package.R /R_package.R
RUN apt update -y && apt install -y \
    g++ \
    r-base \
    r-base-dev \
    python3 \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/* && \
    Rscript /R_package.R --no-save && \
    rm -rf /tmp/R*
RUN pip install jupyterlab && \
    Rscript -e "install.packages('IRkernel')" -e "IRkernel::installspec(user = FALSE)"