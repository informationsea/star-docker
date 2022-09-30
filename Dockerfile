FROM debian:11-slim AS donwload-samtools
ARG SAMTOOLS_VERSION=1.16.1
RUN apt-get update && apt-get install -y curl bzip2 && rm -rf /var/lib/apt/lists/*
RUN curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
RUN tar xjf samtools-${SAMTOOLS_VERSION}.tar.bz2

FROM debian:11-slim AS samtools-build
ARG SAMTOOLS_VERSION=1.16.1
RUN apt-get update && apt-get install -y libssl-dev libncurses-dev build-essential zlib1g-dev liblzma-dev libbz2-dev curl libcurl4-openssl-dev
COPY --from=donwload-samtools /samtools-${SAMTOOLS_VERSION} /build
WORKDIR /build
RUN ./configure && make -j4 && make install

FROM debian:11-slim AS download
RUN apt-get update && apt-get install -y curl
WORKDIR /download
ARG STAR_VERSION=2.7.10a
RUN curl -OL https://github.com/alexdobin/STAR/archive/${STAR_VERSION}.tar.gz
RUN tar xzf ${STAR_VERSION}.tar.gz

FROM debian:11-slim
RUN apt-get update && \
    apt-get install -y ncurses-base zlib1g liblzma5 libbz2-1.0 curl libcurl4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=samtools-build /usr/local /usr/local
ARG STAR_VERSION=2.7.10a
COPY --from=download /download/STAR-${STAR_VERSION} /opt/STAR-${STAR_VERSION}
ENV PATH=/opt/STAR-${STAR_VERSION}/bin/Linux_x86_64_static:${PATH}
ADD run.sh /
ENTRYPOINT [ "/bin/bash", "/run.sh" ]
