FROM ubuntu:21.04
ENV DEBIAN_FRONTEND=noninteractive

ARG DOCKER_NAME
ARG IMAGE_NAME
ARG DOCKER_REGISTRY
ARG SPDK_VERSION
ARG LIBURING_VERSION
ARG FIO_VERSION
ARG ARCH

WORKDIR /app

RUN apt-get update && apt-get install -y apt-utils sudo lcov && \
    ###
    apt-get install -y git git-lfs build-essential python3-dev python3-pip fio && \
    ###
    apt-get install -y libjson-c-dev libcmocka-dev libssl-dev pkg-config && \
    ###
    apt-get install -y librados-dev librbd-dev && \
    ###
    git clone https://github.com/axboe/liburing && \
    ###
    git clone https://github.com/axboe/fio && \
    ###
    git clone https://github.com/spdk/spdk && \
    ###
    cd /app/spdk && git checkout tags/v${SPDK_VERSION} && \
    ###
    cd /app/fio && git checkout tags/fio-${FIO_VERSION} && \
    ###
    cd /app/liburing && git checkout tags/liburing-${LIBURING_VERSION}

RUN cd /app/liburing/ && ./configure && make && make install && \
    ###
    cd /app/fio/ && ./configure && make && make install && \
    ###
    cd /app/spdk && git submodule update --init && /app/spdk/scripts/pkgdep.sh --all && \
    ###
    ./configure --enable-coverage \
    --with-isal --with-rdma --with-iscsi-initiator \
    --with-reduce --with-ocf --with-rbd --with-raid5 \
    --with-uring --with-fio=/app/fio/ \
    --target-arch=${ARCH} && \
    ###
    make
