FROM ubuntu:latest
WORKDIR /
COPY . /install-runtime
RUN /install-runtime/install.sh
CMD /bin/bash