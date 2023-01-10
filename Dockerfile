FROM ubuntu:22.04 as build

ARG DAR_VER=2.7.8
ARG THREADAR_VER=1.4.0
ENV DEBIAN_FRONTEND=noninteractive

ADD https://sourceforge.net/projects/dar/files/dar/${DAR_VER}/dar-${DAR_VER}.tar.gz/download /usr/local/src/dar-${DAR_VER}.tar.gz
ADD https://sourceforge.net/projects/libthreadar/files/${THREADAR_VER}/libthreadar-${THREADAR_VER}.tar.gz/download /usr/local/src/libthreadar-${THREADAR_VER}.tar.gz

RUN apt-get -q update && \
  apt-get install -qy build-essential zlib1g-dev libz3-dev libbz2-dev liblzo2-dev liblzma-dev liblz4-dev libzstd-dev libgcrypt20-dev libgpgme-dev libext2fs-dev librsync-dev libcurl4-openssl-dev libargon2-dev gnupg-agent par2 upx

RUN cd /usr/local/src && \
  mkdir /tmp/root &&\
  tar xzf libthreadar-${THREADAR_VER}.tar.gz && \
  cd libthreadar-${THREADAR_VER} && \
  ./configure && \
  make -j 6 && \
  make install-strip && \
  ldconfig &&\
  ./configure --prefix=/tmp/root && \
  make -j 2 && \
  make install-strip

RUN cd /usr/local/src && \
  tar xzf dar-${DAR_VER}.tar.gz && \
  cd dar-${DAR_VER} && \
  ./configure --disable-dar-static --prefix=/tmp/root && \
  make -j 2 && \
  make install-strip

FROM ubuntu:22.04

COPY --from=build /tmp/root/ /usr/

RUN apt-get -q update && \
  apt-get install -qy zlib1g libz3-4 bzip2 liblzo2-2 liblzma5 liblz4-1 libzstd1 libgcrypt20 libgpgme11 librsync2 libcurl4 libargon2-1 gnupg-agent par2 && \
  ldconfig && \
  dar --version && \
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* &&\
  rm -rf /tmp/*
