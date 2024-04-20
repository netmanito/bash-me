docker build -t bash-me:latest . &&
docker run -v ${PWD}:/root/bash_me -it bash-me:latest
