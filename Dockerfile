FROM debian:10-slim AS donwload-samtools
RUN apt-get update && apt-get install -y curl bzip2 && rm -rf /var/lib/apt/lists/*
RUN curl -OL https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
RUN tar xjf samtools-1.10.tar.bz2

FROM debian:10-slim AS samtools-build
RUN apt-get update && apt-get install -y libssl-dev libncurses-dev build-essential zlib1g-dev liblzma-dev libbz2-dev curl libcurl4-openssl-dev
COPY --from=donwload-samtools /samtools-1.10 /build
WORKDIR /build
RUN ./configure && make -j4 && make install

FROM debian:10-slim AS download
RUN apt-get update && apt-get install -y curl
WORKDIR /download
RUN curl -OL https://github.com/alexdobin/STAR/archive/2.7.3a.tar.gz
RUN tar xzf 2.7.3a.tar.gz

FROM debian:10-slim
COPY --from=samtools-build /usr/local /usr/local
COPY --from=download /download/STAR-2.7.3a /opt/STAR-2.7.3a
ENV PATH=/opt/STAR-2.7.3a/bin/Linux_x86_64_static:${PATH}
ADD run.sh /
ENTRYPOINT [ "/bin/bash", "/run.sh" ]
