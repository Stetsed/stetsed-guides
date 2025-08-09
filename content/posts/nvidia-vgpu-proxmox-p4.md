---
title: "Nvidia vGPU Proxmox P4"
date: 2024-12-16T09:07:21+01:00
draft: true
---

```bash

# Install the packages needed to compile vgpu-unlock.
apt install -y git build-essential dkms pve-headers mdevctl
git clone https://gitlab.com/polloloco/vgpu-proxmox.git

cd /opt
git clone https://github.com/mbilker/vgpu_unlock-rs.git

curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
source $HOME/.cargo/env

# Setup the vgpu_unlock-rs program by building it
cd /opt/vgpu_unlock-rs/
cargo build --release

# Add vgpu-unlock-rs config
mkdir /etc/vgpu_unlock
touch /etc/vgpu_unlock/profile_override.toml

mkdir /etc/systemd/system/{nvidia-vgpud.service.d,nvidia-vgpu-mgr.service.d}
echo -e "[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so" > /etc/systemd/system/nvidia-vgpud.service.d/vgpu_unlock.conf
echo -e "[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so" > /etc/systemd/system/nvidia-vgpu-mgr.service.d/vgpu_unlock.conf


# Add IOMMU and other boot shit
echo "intel_iommu=on" >> /etc/kernel/cmdline
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

# Assuming that the GPu you are using already supports vGPU like the nvidia p4, this will disable the unlocking which can prevent certain issues.
echo "unlock = false" > /etc/vgpu_unlock/config.toml

update-initramfs -u -k all
proxmox-boot-tool refresh

reboot
```

## Obtaining NVIDIA Drivers

Go to the nvidia website and request an ["Enterprise Trial"](https://www.nvidia.com/en-us/data-center/resources/vgpu-evaluation/). After this you want to go to the nvidia apphub website and download the drivers we want, assuming you are using Pascal or Older at time of writing you wanna use 16.8 because GRID 16 is an LTS version and 17 requires extra patching.

Filters:
Product Type: vGPU
Platform: Linux-KVM
Platform Version: All supported
Product-Version: 16.8/17+

## Installing NVIDIA Drivers

```bash
# We are assuming that you don't need to patch the drivers and have the zip file in you're home directory.
mkdir nvidia-drivers
mv NVIDIA* nvidia-drivers/
cd nvidia-drivers
unzip *
cd Host-Drivers
./NVIDIA* --dkms -m=kernel
reboot
```

## Installing the client side drivers

```bash
# Assuming that the client side drivers have already been installed

# Linux
curl --insecure -L -X GET https://10.10.122.75:8261/-/client-token -o /etc/nvidia/ClientConfigToken/client_configuration_token_$(date '+%d-%m-%Y-%H-%M-%S').tok

systemctl restart nvidia-gridd

# Windows

curl.exe --insecure -L -X GET https://10.10.156.108:443/-/client-token -o "C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken\client_configuration_token_$($(Get-Date).tostring('dd-MM-yy-hh-mm-ss')).tok"

```

## Sources

- [VGPU-Proxmox](https://gitlab.com/polloloco/vgpu-proxmox)

```

```
