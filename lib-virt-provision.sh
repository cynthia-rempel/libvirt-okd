#!/bin/bash

virsh --version        || { echo 'virsh --version failed' ; exit 1; }
unxz --version         || { echo 'unxz  --version failed' ; exit 1; }
wget --version         || { echo 'wget  --version failed' ; exit 1; }

export BASE_IMAGE_PATH=$PWD/images/base
export FCOS_VERSION=32.20200601.3.0
export BASE_IMAGE_NAME=fedora-coreos-$FCOS_VERSION-qemu.x86_64.qcow2

# Don't download again if it's already downloaded
wget --no-clobber https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz

wget --no-clobber https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz
# Keep the old file, so we don't re-download them
unxz --keep fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz

mkdir -p images

cp fedora-coreos-$FCOS_VERSION-qemu.x86_64.qcow2 fedora-coreos-qemu.x86_64.qcow2

# Make sure NETWORK matches the network name in virt-net.xml
export NETWORK=okd-net

# https://wiki.libvirt.org/page/VirtualNetworking#virsh_XML_commands
virsh net-define --file $PWD/okd-net.xml
virsh net-start okd-net

# Load Balancer
echo "provisioning load balancer"

export IGNITION_PATH=$PWD/ignition
sudo semanage fcontext -a -t svirt_home_t "$PWD(/.*)?"
sudo restorecon -R -v $PWD
# sudo semanage fcontext -a -t svirt_home_t $PWD/*

export VM_NAME=lb
# Make sure MAC_ADDRESS matches mac in okd-net.xml
export MAC_ADDRESS=00:1c:14:00:00:02
export VM_RAM=2048
export IGNITION_FILE=lb.ign
export VM_CPU=2

# cp fedora-coreos-qemu.x86_64.qcow2 images/$VM_NAME.qcow2
sudo chcon -t svirt_home_t $PWD/images/*
ls $IGNITION_PATH
# sudo qemu-img create -f qcow2 $PWD/images/lb.qcow2 4G
# sudo virsh create $PWD/libvirt-xml/lb-libvirt.xml

# Create the VM with virt-install
# use fedora28, as that's the newest that ships automatically with github-actions-ubuntu
virt-install \
    --connect qemu:///system \
    --name=$VM_NAME \
    --ram=$VM_RAM \
    --vcpus=$VM_CPU \
    --os-type=linux \
    --os-variant=fedora28 \
    --graphics=none \
    --import \
    --network network=$NETWORK,mac=$MAC_ADDRESS \
    --disk size=4,readonly=false,path=$PWD/images/$VM_NAME.qcow2,format=qcow2,bus=virtio \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$IGNITION_PATH/$IGNITION_FILE"

#    --disk size=4,readonly=false,path=$PWD/images/$VM_NAME.qcow2,format=qcow2,bus=virtio \
sudo virsh dumpxml lb
exit 0
echo "provisioning bootstrap"

export IGNITION_FILE=bootstrap.ign
export MAC_ADDRESS=00:1c:14:00:00:03
export VM_NAME=bootstrap
export VM_RAM=2048
export VM_CPU=2

cp fedora-coreos-qemu.x86_64.qcow2 images/$VM_NAME.qcow2
sudo chcon -t svirt_home_t $PWD/images/*

# Create the VM with virt-install

virt-install \
    --connect qemu:///system \
    --name=$VM_NAME \
    --ram=$VM_RAM \
    --vcpus=$VM_CPU \
    --os-type=linux \
    --os-variant=fedora32 \
    --graphics=none \
    --import \
    --network network=$NETWORK,mac=$MAC_ADDRESS \
    --noautoconsole \
    --disk size=4,readonly=false,path=$PWD/images/$VM_NAME.qcow2,format=qcow2,bus=virtio \
 --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$IGNITION_PATH/$IGNITION_FILE"

export IGNITION_FILE=dns.ign
export MAC_ADDRESS=00:1c:14:00:00:04
export VM_NAME=dns
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning ignition"

export IGNITION_FILE=ignition.ign
export MAC_ADDRESS=00:1c:14:00:00:05
export VM_NAME=ignition
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master1"

export IGNITION_FILE=master.ign
export MAC_ADDRESS=00:1c:14:00:00:11
export VM_NAME=master1
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master2"

export IGNITION_FILE=config.ign
export MAC_ADDRESS=00:1c:14:00:00:12
export VM_NAME=master2
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master3"
export IGNITION_FILE=config.ign
export MAC_ADDRESS=00:1c:14:00:00:13
export VM_NAME=master3
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning worker1"
export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:41
export VM_NAME=worker1
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install


#
echo "provisioning worker2"
export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:42
export VM_NAME=worker2
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning worker3"

export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:43
export VM_NAME=worker3
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

# test the connection
#   ssh -i ./libvirt-okd-key core@10.20.15.2


####
#### Shows output
virt-install \
    --connect qemu:///system \
    --name=$VM_NAME \
    --ram=$VM_RAM \
    --vcpus=$VM_CPU \
    --os-type=linux \
    --os-variant=fedora32 \
    --graphics=none \
    --import \
    --network network=$NETWORK,mac=$MAC_ADDRESS \
    --disk size=4,readonly=false,path=$PWD/fedora-coreos-qemu.x86_64.qcow2,format=qcow2,bus=virtio \
 --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$IGNITION_PATH/$IGNITION_FILE"
####


# Reference:
#   https://medium.com/@jesus.alvb/hands-on-fedora-coreos-on-kvm-299f22faebed
#   https://linux.die.net/man/1/virt-install
#   https://serverfault.com/questions/627238/kvm-libvirt-how-to-configure-static-guest-ip-addresses-on-the-virtualisation-ho
#   https://wiki.libvirt.org/page/Networking
#   https://libvirt.org/formatnetwork.html
