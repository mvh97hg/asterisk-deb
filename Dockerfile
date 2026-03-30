FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf-archive \
    binutils-dev \
    bison \
    build-essential \
    ca-certificates \
    curl \
    debhelper \
    devscripts \
    dh-make \
    doxygen \
    fakeroot \
    flex \
    freetds-dev \
    git \
    graphviz \
    libasound2-dev \
    libbluetooth-dev \
    libc-client2007e-dev \
    libcap-dev \
    libcfg-dev \
    libcodec2-dev \
    libcorosync-common-dev \
    libcpg-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libfftw3-dev \
    libgmime-3.0-dev \
    libgsm1-dev \
    libical-dev \
    libiksemel-dev \
    libjack-jackd2-dev \
    libjansson-dev \
    libldap-dev \
    libldap2-dev \
    liblua5.2-dev \
    libmysqlclient-dev \
    libneon27-dev \
    libnewt-dev \
    libogg-dev \
    libpopt-dev \
    libpq-dev \
    libradcli-dev \
    libresample1-dev \
    libsndfile1-dev \
    libsnmp-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite3-dev \
    libsrtp2-dev \
    libssl-dev \
    libunbound-dev \
    liburiparser-dev \
    libvorbis-dev \
    libxml2-dev \
    libxslt1-dev \
    lintian \
    patch \
    pkg-config \
    portaudio19-dev \
    quilt \
    subversion \
    sudo \
    unixodbc-dev \
    uuid-dev \
    wget \
    xmlstarlet \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY build-deb.sh /workspace/build-deb.sh
COPY debian /workspace/debian
COPY docker-entrypoint-build-deb.sh /usr/local/bin/docker-build-deb

RUN chmod +x /workspace/build-deb.sh /usr/local/bin/docker-build-deb

VOLUME ["/out"]

ENTRYPOINT ["/usr/local/bin/docker-build-deb"]
