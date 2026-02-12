# Scan LAN hosts with nmap, output as JSON-like lines
function scanlan() {
    local net_range="$1"
    if [ -z "$net_range" ]; then
        read -p "Enter network range (e.g. 192.168.1.0/24): " net_range
    fi
    exec 2>&1
    while true; do
        if [ "$USER" = "root" ]; then
            nmap_cmd="nmap -sn $net_range"
        else
            nmap_cmd="sudo nmap -sn $net_range"
        fi
        eval "$nmap_cmd" | \
            grep report | \
            awk '{print "hostname: "$5",address:" $6}' | \
            sed 's/(/ /g' | \
            sed 's/)//g' | \
            sed -r 's/[^,]+/"&"/g' | \
            sed 's/:/":"/g' | \
            tr -d "[:blank:]" | \
            sed 's/^/{/;s/$/},/g'
        sleep 5
    done
}
# Bash Functions

# History fancy way
function hist() { history |grep "$@"; }

# Virtualbox
function startvm() { VBoxManage startvm "$@" --type=headless; }
function stopvm() { VBoxManage controlvm "$@" savestate; }

# Docker
function drm() { docker rm "$@"; }
function dstop() { docker stop "$@"; }

# docker build
# Update to buildx!!
function db() { docker build --rm -t="$1" .; }

# Purge unidentified images
function dnone() {
    for i in `docker images |grep none | awk {'print $3'}`; do docker rmi -f $i; done
}

# enter into container
function dent { docker exec -i -t "$@" /bin/sh; }
complete -F _docker_exec dent

# run bash for any image
function dbash { docker run --rm -i -t -e TERM=xterm --entrypoint /bin/bash "$@"; }
complete -F _docker_images dbash

# check container network
function docknet() { docker inspect "$@" -f '{{json .NetworkSettings.Networks }}'; }

# check host
function rhost() {
    for i in $(host "$1"|grep "has address"|awk '{print $4}')
        do
            host "$i"|grep pointer|awk '{print "'$i'\t"$5}'
        done
}

# fancy sort
function dusort() {
    du -s "$1"/* | sort -n | cut -f 2- | while read a; do du -sh "$a" ; done
}

# remove ssh known_hosts entry
function del-ssh() {
   sed -i -e "$1"d ~/.ssh/known_hosts
}

# macos battery status
function batt() {
    # macos battery command line status
    ioreg -n AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%.2f%%"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}'
}

# function do as user in remote host
function do() {
    # Script executes commands on all ssh servers define on a list file
    if [ $# -gt 0 ]; then
        for i in `cat ~/severs`; do ssh -tt admin@$i "echo '===============';hostname ;echo '===============';$1";done
    else
        echo  "Introduce a command to run"
    fi
}

# docker logs stream
function dlogs() {
    LOG="$(which log)"
    if [ -z "$LOG" ]; then
    	for i in `docker ps |grep '"' |awk {'print $1'}`; do docker logs -f $i;done
    else
	    log stream --predicate 'eventMessage contains "docker"'
    fi
}

# proxy_socks ssh
function proxy_socks() {
    echo  -n We\'re better, 
    ssh -D 8081 -fN "$@"
    echo connected
}

# youtube downloader
alias yt-dl='docker run \
                  --rm -i \
                  -e PGID=$(id -g) \
                  -e PUID=$(id -u) \
                  -v "$(pwd)":/workdir:rw \
                  ghcr.io/mikenye/docker-youtube-dl:latest'

## End

