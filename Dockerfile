FROM gcc:15@sha256:27be068a2580bed7c32ccf2349352e29f86e0a5c8cda8c9c98c6b59e4ad98d53

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install git ca-certificates make -y --no-install-recommends && \
    update-ca-certificates

WORKDIR /tmp

ENV COMP_OPTIONS "no-comp no-deprecated no-tls-deprecated-ec no-gost no-legacy enable-pie no-psk no-shared no-ssl no-tls1 no-tls1_1 no-dtls1"

# Use latest LTS version for OpenSSL
RUN git clone --branch openssl-3.5.4 --depth 1 https://github.com/openssl/openssl.git /tmp/openssl && \
    cd /tmp/openssl && \
    ./Configure LIST && \
    ./Configure ${ COMP_OPTIONS } && \
    make -j$(( $(nproc) + 1 )) && \
    make tests