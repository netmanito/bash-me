FROM ubuntu:focal
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install curl less vim git


WORKDIR /root
ADD .  ./bash_me

ENTRYPOINT ["/bin/bash"]
