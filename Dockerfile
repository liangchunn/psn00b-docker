FROM ubuntu:latest
WORKDIR /
COPY . /install-runtime
ENV GCC_VERSION=7.4.0
ENV BINUTILS_VERSION=2.31.1
ENV INSTALL_RUNTIME_DIR=/install-runtime
ENV MAKE_THREADS=4
RUN /install-runtime/install.sh
CMD /bin/bash