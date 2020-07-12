#!/bin/bash
# creates a public-private key-pair
# installs the public key into the ignition/*.yaml files
# converts the ignition/*.yaml files into .ign
podman --version || { echo 'podman  --version failed' ; exit 1; }
ssh-keygen -b 2048 -t rsa -f ssh.key -q -N "" || { echo 'ssh-keygen  failed' ; exit 1; }
# put the key into the yaml files
PUB_KEY=$(cat ssh.key.pub)
sed -e s"|ssh-rsa\ veryLongRSAPublicKey|$PUB_KEY|" -i ignition/lb.yaml

podman pull quay.io/coreos/fcct:release
podman run --rm -v ./ignition/lb.yaml:/config.fcc:z quay.io/coreos/fcct:release --pretty --strict /config.fcc > ignition/lb.ign

