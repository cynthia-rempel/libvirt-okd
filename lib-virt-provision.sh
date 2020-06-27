#!/bin/bash

unxz --version || { echo 'unxz --version failed' ; exit 1; }
export BASE_IMAGE_PATH=$PWD/images/base
export FCOS_VERSION=32.20200615.2.2
export BASE_IMAGE_NAME=fedora-coreos-$FCOS_VERSION-qemu.x86_64.qcow2

wget --no-clobber https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz

unxz fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz

# Make sure NETWORK matches the network name in virt-net.xml
export NETWORK=okd-net

# https://wiki.libvirt.org/page/VirtualNetworking#virsh_XML_commands
virsh net-define --file ./okd-net.xml

# Load Balancer
echo "provisioning load balancer"

export IGNITION_PATH=./ignition
export IGNITION_FILE=lb.ign

# Make sure MAC_ADDRESS matches mac in vir-net.xml
export MAC_ADDRESS=00:1c:14:00:00:02
export SERIAL_NO=WD-WMAP9A966102
export VM_NAME=lb
export VM_RAM=2048
export VM_CPU=2
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
    --network $NETWORK,mac=$MAC_ADDRESS \
    --disk size=1,readonly=false,backing_store=$BASE_IMAGE_NAME/$BASE_IMAGE_NAME,serial=$SERIAL_NO \
 --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$IGNITION_PATH/$IGNITION_FILE"

echo "provisioning bootstrap"

export IGNITION_PATH=./ignition
export IGNITION_FILE=bootstrap.ign
export MAC_ADDRESS=00:1c:14:00:00:03
export SERIAL_NO=WD-WMAP9A966103
export VM_NAME=bootstrap
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning DNS"

export IGNITION_PATH=./ignition
export IGNITION_FILE=dns.ign
export MAC_ADDRESS=00:1c:14:00:00:04
export SERIAL_NO=WD-WMAP9A966104
export VM_NAME=dns
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning ignition"

export IGNITION_PATH=./ignition
export IGNITION_FILE=ignition.ign
export MAC_ADDRESS=00:1c:14:00:00:05
export SERIAL_NO=WD-WMAP9A966105
export VM_NAME=ignition
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master1"

export IGNITION_PATH=./ignition
export IGNITION_FILE=master.ign
export MAC_ADDRESS=00:1c:14:00:00:11
export SERIAL_NO=WD-WMAP9A966111
export VM_NAME=master1
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master2"

export IGNITION_PATH=./ignition
export IGNITION_FILE=config.ign
export MAC_ADDRESS=00:1c:14:00:00:12
export SERIAL_NO=WD-WMAP9A966112
export VM_NAME=master2
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning master3"
export IGNITION_PATH=./ignition
export IGNITION_FILE=config.ign
export MAC_ADDRESS=00:1c:14:00:00:13
export SERIAL_NO=WD-WMAP9A966113
export VM_NAME=master3
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning worker1"
export IGNITION_PATH=./ignition
export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:41
export SERIAL_NO=WD-WMAP9A966141
export VM_NAME=worker1
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install


#
echo "provisioning worker2"
export IGNITION_PATH=./ignition
export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:42
export SERIAL_NO=WD-WMAP9A966142
export VM_NAME=worker2
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

echo "provisioning worker3"

export IGNITION_PATH=./ignition
export IGNITION_FILE=worker.ign
export MAC_ADDRESS=00:1c:14:00:00:43
export SERIAL_NO=WD-WMAP9A966143
export VM_NAME=worker3
export VM_RAM=2048
export VM_CPU=2
# Create the VM with virt-install

# test the connection
#   ssh -i ./libvirt-okd-key core@10.20.15.2


# Reference:
#   https://medium.com/@jesus.alvb/hands-on-fedora-coreos-on-kvm-299f22faebed
#   https://linux.die.net/man/1/virt-install
#   https://serverfault.com/questions/627238/kvm-libvirt-how-to-configure-static-guest-ip-addresses-on-the-virtualisation-ho
#   https://wiki.libvirt.org/page/Networking
#   https://libvirt.org/formatnetwork.html
