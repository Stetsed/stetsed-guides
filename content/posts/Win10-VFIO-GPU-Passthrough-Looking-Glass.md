---
title: "Setup Win10 VFIO GPU Passthrough with Looking Glass on Arch Linux"
date: 2023-05-18T13:39:51+02:00
draft: false
tags: ["VFIO", "GPU Passthrough", "Linux", "Arch Linux"]
---

## Install required packages

```bash
yay -Syu qemu-desktop libvirt edk2-ovmf virt-manager dnsmasq dmidecode bridge-utils spice-protocol libsamplerate
```

## Configuration

### Setup Libvirtd
Firstly we will need to enable the networking for libvirt and the libvirt service, which the below commands will do. And also add our user to the libvirt group(for convience), do know this is a massive security risk as it's the same as just giving the user no password root acces, if you do not want this you can ignore the last command but be aware you will have to enter a pasword when you wanna start your VM and do other such functions

```bash
systemctl enable --now libvirtd
sudo virsh net-autostart default
sudo virsh net-start default
sudo usermod -aG libvirt $USER
```

### Enable PCIE Isolation

First add this to your boot parameters, what this does is enable IOMMU which let's use later give our GPU's control over to the Virtual Machine, if you do not know how to do this please consult [Arch Wiki](https://wiki.archlinux.org/title/Kernel_parameters)
```
intel_iommu=on OR amd_iommu=on
```

After this we need to get the vfio-pci id's, you can find this with the below IOMMU script. You will want to look for all the PCI Id's that match your GPU, the ID's will be in the format "XXXX:XXXX" and will be after the device name
```bash
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

Then go into the boot loader entry and add the below to your boot parameters, adding the PCI id's split by comma's.
```bash
vfio-pci.ids=XXXX:XXXX,XXXX:XXXX
```

<!---vfio-pci.ids=10de:21c4,10de:1aeb,10de:1aec,10de:1aed--->

After this you want to go ahead and add the vfio modules to the mkincipio or whatever initframs generator your using.
```bash
MODULES=(... vfio_pci vfio vfio_iommu_type1 ...)
```

Regenarate the initframs which is done with the command 
```bash
sudo mkinitcpio -P
```

### Setup networking bridge
After this we setup a network bridge so we can get better performance, if you use WiFi then you can ignore this step, to get the interface name run "ip addr"

```bash
nmcli connection add type bridge ifname br0 stp no
nmcli connection add type bridge-slave ifname (Interface) master br0
```

<!--- nmcli con modify bridge-br0 802-3-ethernet.cloned-mac-address d8:bb:c1:47:7d:f9 -->

### Install Looking Glass

Download from the [website](https://looking-glass.io/downloads)

Install required dependancies

```bash
pacman -Syu cmake gcc libgl libegl fontconfig spice-protocol make nettle pkgconf binutils libxi libxinerama libxss libxcursor libxpresent libxkbcommon wayland-protocols ttf-dejavu libsamplerate
```

Next we will want to move our archive into a directory where we can work with it so we can in the next step compile it into a binary. 

```bash
mkdir ~/.VirtualMachine
mv ~/Downloads/looking-glass* ~/.VirtualMachine/
cd ~/.VirtualMachine
tar xvf looking-glass*
rm looking-glass*.tar.gz
```

Build the client
```bash
cd looking-glass*
mkdir -p client/build
cd client/build
cmake ../
make
cp looking-glass-client ~/.VirtualMachine/
```


Add temp file to /etc/tmpfiles.d/10-looking-glass.conf

```conf
sudo nano /etc/tmpfiles.d/10-looking-glass.conf

f /dev/shm/looking-glass 0660 (user) kvm
```

## Setup Virtual Machine

Downloads windows 10 ISO: [here](https://www.microsoft.com/en-us/software-download/windows10ISO)

Next we will want to move our windows ISO into our storage directory so we know where can find it.

```bash
mv ~/Downloads/Win10* ~/.VirtualMachine/
```

Go into the Virtual Machine Manager UI and enable XML editing.

Now go ahead and setup the VM with your wanted settings, including the network bridge we created earlier and with the ISO we just downloaded in the virtual-machine-manager UI, but click "I want to edit VM", before finishing.

Now go and add the PCIE devices of the GPU by going Add device and then PCIE Device, add all the ones that match your GPU's. After this go into the xml editor and add the below into the "devices" section at the end.
```xml
<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>64</size>
</shmem>
```

After this go ahead and add the enlightenments into your XML in the "features" section, what we are doing here is enabling a bunch of optimizations.
```xml
<features> 
	<hyperv mode='custom'> 
		<relaxed state='on'/>
		<vapic state='on'/>
		<spinlocks state='on' retries='8191'/>
		<vpindex state='on'/>
		<runtime state='on'/>
		<synic state='on'/>
		<stimer state="on"/>
		<reset state='off'/>
		<vendor_id state='on' value='whatever'/>
		<frequencies state='on'/>
		<reenlightenment state='off'/> 
		<tlbflush state='on'/>
		<ipi state='on'/>
		<evmcs state='off'/>
	</hyperv> 
	<kvm> 
		<hidden state="on"/>
	</kvm>
	<ioapic driver='kvm'/>
</features>
```

After this you can go ahead and startup the virtual machine and setup windows as you normally would, after this you will want to go to the Looking Glass [Website](https://looking-glass.io/downloads), and download the windows host binary that matches the version you downloaded earlier. Go ahead and run the installer and it will setup. After this you can either mirror the displays so that if the looking glass app crashes you will be able to use spice on windows, or for full performance disable the spice display and just let looking glass handle it.

I hope this guide was helpful and if it did you can leave a Star on the [Repository](https://github.com/Stetsed/stetsed-guides)

<!--- Connect to TrueNAS iSCSI share by opening iSCSI initiator and add hostname "truenas.selfhostable.net" --->
