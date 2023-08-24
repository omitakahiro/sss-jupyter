#!/bin/bash

set -e

port="8888"

while getopts p: OPT; do
    case $OPT in
        p) port=${OPTARG} ;;
    esac
done


if ! ls ~/.jupyterkey > /dev/null 2>&1; then
    echo "generate ssh key in ~/.jupyterkey..."
    mkdir ~/.jupyterkey
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/.jupyterkey/mykey.key -out ~/.jupyterkey/mycert.pem -subj "/C=JA" > /dev/null 2>&1
fi

token=$(cat /dev/urandom | tr -dc '0-9a-f' | fold -w 100 | head -n 1)

nohup python3 -m jupyterlab \
    --ip=0.0.0.0 \
    --port=${port} \
    --certfile="~/.jupyterkey/mycert.pem" \
    --keyfile="~/.jupyterkey/mykey.key" \
    --IdentityProvider.token="${token}" \
    > ~/.jupyterlog 2>&1 &

external_ip=$(curl -s ifconfig.me)
echo https://${external_ip}:${port}/?token=${token}
