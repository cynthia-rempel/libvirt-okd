## OKD on Libvirt

### Install Libvirt

```
sudo dnf -y install bridge-utils libvirt virt-install qemu-kvm virt-top libguestfs-tools

sudo systemctl start libvirtd
sudo systemctl enable libvirtd

sudo usermod -aG kvm cindy
sudo usermod -aG libvirt cindy
```

### Create the key-pair
ssh-keygen -t rsa -b 4096 -N '' -f ./libvirt-okd-key

### Install Infrastructure

1. Load Balancer
2. Name Server
3. Web Server
4. Bootstrap
5-7. Masters
8-9. Workers

#### Find the desired download
1. Browse to:
  https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=testing

####
Trouble-shooting installs

qemu-img create -f qcow2 -b fedora-coreos-qemu.x86_64.qcow2 my-fcos-vm.qcow2

qemu-kvm -m 2048 -cpu host -nographic \
  -drive if=virtio,file=my-fcos-vm.qcow2 \
  -fw_cfg name=opt/com.coreos/config,file=/home/cindy/ha-proxy.ign \
  -nic user,model=virtio,hostfwd=tcp::2222-:22

/usr/bin/podman run \
  --name haproxy \
  --restart=always \
  -v /usr/etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
  docker.io/library/haproxy:latest


##### HA Proxy
2. Download QEMU qcow2
```
export FCOS_VERSION=32.20200615.2.2
[cindy@libvirt ~]$ echo fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2

wget https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz

# Extract the qcow2
unxz fedora-coreos-${FCOS_VERSION}-qemu.x86_64.qcow2.xz
sudo chcon -t svirt_home_t /home/cindy/ha-proxy.ign
sudo chcon -t svirt_home_t /home/cindy/fedora-coreos-32.20200615.2.2-qemu.x86_64.qcow2 
# attempt to build a machine, so we can get the selinux errors.
sudo bash -x coreos.sh 
sudo ausearch -c 'qemu-system-x86' --raw | audit2allow -M my-qemusystemx86
sudo semodule -X 300 -i my-qemusystemx86.pp
sed 's/^\#user\=.*/user=root/' -i /etc/libvirt/qemu.conf
sed 's/^\#group\=.*/group=root/' -i /etc/libvirt/qemu.conf

```

##### Openshift VMs
2. Download the Bare Metal PXE kernel 
https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/32.20200615.2.1/x86_64/fedora-coreos-32.20200615.2.1-live-kernel-x86_64

3. Download the Bare Metal initramfs
https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/32.20200615.2.1/x86_64/fedora-coreos-32.20200615.2.1-live-initramfs.x86_64.img

virt-install -n fcos --vcpus 2 -r 2048 \
  --os-variant=fedora31 --import \
  --network bridge=virbr0 \
  --disk=/var/lib/libvirt/images/fedora-coreos-qemu.qcow2,format=qcow2,bus=virtio \
  --noautoconsole \
  --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/path/to/fcos.ign"

virt-install \
--name fed31 \
--ram 1024 \
--vcpus 1 \
--disk path=/var/lib/libvirt/images/fed31.img,size=20 \
--os-variant fedora31 \
--os-type linux \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location 'http://fedora.inode.at/releases/31/Server/x86_64/os/' \
--extra-args 'console=ttyS0,115200n8 serial'

### References

https://computingforgeeks.com/how-to-install-kvm-on-fedora/

https://computingforgeeks.com/install-fedora-coreos-fcos-on-kvm-openstack/


http://nickdesaulniers.github.io/blog/2018/10/24/booting-a-custom-linux-kernel-in-qemu-and-debugging-it-with-gdb/
#### Terraform
https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/
https://computingforgeeks.com/how-to-install-terraform-on-ubuntu-centos-7/
