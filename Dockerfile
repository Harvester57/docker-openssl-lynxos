FROM gcc:15@sha256:27be068a2580bed7c32ccf2349352e29f86e0a5c8cda8c9c98c6b59e4ad98d53

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install git ca-certificates make -y --no-install-recommends && \
    update-ca-certificates

WORKDIR /tmp

ENV SHELL="/bin/bash"
ENV CROSS_PREFIX="i386-lynxos178-elf-"
ENV CONFIGURE_OPTIONS="-DOPENSSL_SYS_LYNX -D_POSIX_THREADS -D_REENTRANT"
ENV COMP_OPTIONS="no-comp no-deprecated no-tls-deprecated-ec no-gost no-legacy enable-pie no-psk no-shared no-dso no-engine no-async no-ssl no-tls1 no-tls1_1 no-dtls1"
ENV GCC_HARDENING="-fstack-protector-strong \
                -D_FORTIFY_SOURCE=3 \
                -ftrivial-auto-var-init=zero \
                -Wformat -Werror=format-security \
                -Wl,-z,relro,-z,now \
                -fstack-clash-protection \
                -fzero-call-used-regs=used-gpr"

# Use latest LTS version for OpenSSL
RUN git clone --branch openssl-3.5.4 --depth 1 https://github.com/openssl/openssl.git /tmp/openssl && \
    cd /tmp/openssl && \
    ./Configure generic32 --cross-compile-prefix=$CROSS_PREFIX $CONFIGURE_OPTIONS $COMP_OPTIONS $GCC_HARDENING && \
    make -j$(( $(nproc) + 1 ))