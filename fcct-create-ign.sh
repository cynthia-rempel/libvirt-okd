#!/bin/bash
# creates a public-private key-pair
# installs the public key into the ignition/*.yaml files
# converts the ignition/*.yaml files into .ign
podman --version || { echo 'podman  --version failed' ; exit 1; }
ssh-keygen -b 2048 -t rsa -f ssh.key -q -N "" || { echo 'ssh-keygen  failed' ; exit 1; }

# put the public key in the yaml
exit 1
podman pull quay.io/coreos/fcct:release
podman run --rm -v ./ignition/lb.yaml:/config.fcc:z quay.io/coreos/fcct:release --pretty --strict /config.fcc > ignition/lb.ign
