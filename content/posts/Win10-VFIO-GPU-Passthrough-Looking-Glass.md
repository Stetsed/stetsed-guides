---
title: "Setup Win10 VFIO GPU Passthrough with Looking Glass on Arch Linux"
date: 2023-05-18T13:39:51+02:00
draft: false
---

## Install required packages

```bash
yay -Syu qemu-desktop libvirt edk2-ovmf virt-manager dnsmasq dmidecode bridge-utils spice-protocol libsamplerate
```

## Configuration

### Setup Libvirtd
Firstly we will need to enable the networking for libvirt and the libvirt service, which the below commands will do. And also add our user to the libvirt group(for convience)
```bash
systemctl enable --now libvirtd
sudo virsh net-autostart default
sudo virsh net-start default
sudo usermod -aG libvirt $USER
```

### Enable PCIE Isolation

First add this to your boot parameters.
```
intel_iommu=on OR amd_iommu=on
```

After this we need to get the vfio-pci id's, you can find this with the below IOMMU script.
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

Then go into the boot loader entry and add the below to your systemd-boot configuration.
```bash
vfio-pci.ids=(Your PCI ids)
```

After this you want to go ahead and add the vfio modules to the mkincipio
```bash
MODULES=(... vfio_pci vfio vfio_iommu_type1 ...)
```

Regenarate the initframs which is done with the command 
```bash
sudo mkinitcpio -P
```

### Setup networking bridge
We create the Network Interface, then assign it the MAC adress of the network card to make it keep the same IP.sudo 

```bash
nmcli connection add type bridge ifname br0 stp no
nmcli connection add type bridge-slave ifname (Interface) master br0
```

### Install Looking Glass

Download from the [website](https://looking-glass.io/downloads)

Install required dependancies

```bash
pacman -Syu cmake gcc libgl libegl fontconfig spice-protocol make nettle pkgconf binutils libxi libxinerama libxss libxcursor libxpresent libxkbcommon wayland-protocols ttf-dejavu libsamplerate
```

Move the source to the virtual machine directory and extract it.
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
mkdir client/build
cd client/build
cmake ../
make
mv looking-glass-client ~/.VirtualMachine/
```


Add temp file to /etc/tmpfiles.d/10-looking-glass.conf

```
sudo nano /etc/tmpfiles.d/10-looking-glass.conf

f /dev/shm/looking-glass 0660 (user) kvm
```

## Setup Virtual Machine

Downloads windows 10 ISO: [here](https://www.microsoft.com/en-us/software-download/windows10ISO)

Make a Virtual Machine Storage Directory and move the windows 10 ISO into there.

```bash
mv ~/Downloads/Win10* ~/.VirtualMachine/
```

Go into the Virtual Machine Manager UI and enable XML editing.

Now go ahead and setup the VM with your wanted settings, including the network bridge we created earlier and with the ISO we just downloaded in the virtual-machine-manager UI, but click "I want to edit VM", before finishing.

Now go and add the PCIE devices of the GPU and NVME SSD if you have one and then add the below snippet to the bottom of the XML
```xml
<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>64</size>
</shmem>
```

And add the enlightmens
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
Then start the virtual machine and setup windows.
