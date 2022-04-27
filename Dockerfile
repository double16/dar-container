FROM ubuntu:20.04 as build

ARG DAR_VER=2.6.14
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && \
  apt-get install -qy build-essential zlib1g-dev libz3-dev libbz2-dev liblzo2-dev liblzma-dev libgcrypt20-dev libgpgme-dev libext2fs-dev librsync-dev libcurl4-openssl-dev software-properties-common apt-transport-https ca-certificates curl gnupg-agent par2 upx && \
  cd /usr/local/src && \
  curl -L -o dar-${DAR_VER}.tar.gz https://sourceforge.net/projects/dar/files/dar/${DAR_VER}/dar-${DAR_VER}.tar.gz/download && \
  tar xzf dar-${DAR_VER}.tar.gz && \
  cd dar-${DAR_VER} && \
  mkdir /tmp/root &&\
  ./configure --prefix=/tmp/root && \
  make -j 2 && \
  make install-strip

FROM ubuntu:20.04

COPY --from=build /tmp/root/ /usr/

RUN apt-get -q update && \
  apt-get install -qy zlib1g libz3-4 bzip2 liblzo2-2 liblzma5 libgcrypt20 libgpgme11 librsync2 libcurl4 gnupg-agent par2 upx && \
  ldconfig && \
  dar --version && \
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* &&\
  rm -rf /tmp/*
