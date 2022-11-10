FROM ubuntu:focal
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install curl


WORKDIR /bash_me
ADD ./bash-me.sh  ./bash-me.sh

ENTRYPOINT ["/bin/bash"]
