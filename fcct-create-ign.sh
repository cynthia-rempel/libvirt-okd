#!/bin/bash
# creates a public-private key-pair
# installs the public key into the ignition/*.yaml files
# converts the ignition/*.yaml files into .ign
podman --version || { echo 'podman  --version failed' ; exit 1; }

echo "installing the public keys"

ssh-keygen -b 2048 -t rsa -f ssh.key -q -N "" || { echo 'ssh-keygen  failed' ; exit 1; }
# put the key into the yaml files
PUB_KEY=$(cat ssh.key.pub)
sed -e s"|ssh-rsa\ veryLongRSAPublicKey|$PUB_KEY|" -i ignition/lb.yaml
mkdir -p okd/install
sed -e s"|ssh-rsa\ veryLongRSAPublicKey|$PUB_KEY|" okd/install-config.yaml > okd/install/install-config.yaml

echo "creating the infrastructure ignition configs"

podman pull quay.io/coreos/fcct:release
podman run --rm -v ./ignition/lb.yaml:/config.fcc:z quay.io/coreos/fcct:release --pretty --strict /config.fcc > ignition/lb.ign

echo "creating the openshift ignition configs"

cd okd
wget https://github.com/openshift/okd/releases/download/4.5.0-0.okd-2020-07-12-134038-rc/openshift-install-linux-4.5.0-0.okd-2020-07-12-134038-rc.tar.gz
tar -xf openshift-install-linux-4.5.0-0.okd-2020-07-12-134038-rc.tar.gz
chmod +x openshift-install
./openshift-install --dir=install create manifests
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' install/manifests/cluster-scheduler-02-config.yml
./openshift-install --dir=install create ignition-configs
cd ..
cp okd/install/bootstrap.ign ignition
cp okd/install/master.ign ignition
cp okd/install/worker.ign ignition


