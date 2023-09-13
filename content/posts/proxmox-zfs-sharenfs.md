---
title: "Proxmox ZFS ShareNFS"
date: 2023-09-13T12:49:05+02:00
tags: ["Proxmox", "ZFS", "Linux",]
draft: false
---

Hey everybody, quick guide today as I could find very little info on this so decided to write this. I will be going through the steps to use ShareNFS on proxmox combined with ZFS to setup an NFS server. We will be adding a few paramters to give convienct access to the NFS server however as I will explain later some of my ones might introduce some inherent risk.

## Requirments
- Promox VE8 Server*
- Root Access
- A cup of Coffee

* An earlier version of proxmox may work and I used the same on Proxmox VE7 but it may not work on earlier versions, do it at your own risk.

## Setup

### Installing the required package

So this is what I forgot to do when setting it up which is installing the required package which is nfs-kernel-server, so go ahead and install that with apt.

```bash
apt install nfs-kernel-server
```

After this go ahead and enable the nfs-kernel-server service.

```bash
systemctl enable --now nfs-kernel-server
```

### Setting up the NFS share

So next we will want to go ahead and setup the NFS share, we will start by creating a dataset which we will share, here I have called it "Share" under the zpool of Vault

```bash
zfs create Vault/Share
zfs mount Vault/Share
```

After this we will want to go ahead and share it with the below command, lemme explain what this does. So firstly we are saying that for security we want to be using the System, which means it will trust that the system handles acces, I do this with a firewall in proxmox which only allows acces from my Trusted Subnet/VLAN. no_root_squash means that the root user on an accesing machine will be treated as the root user on the NFS share. Which means you can do stuff such as chown and chmod. rw means that the share is read and writeable.

```bash
zfs set sharenfs=sec=sys,no_root_squash,rw Vault/Share
```

### Setting up the NFS client

Now lastly we will want to go ahead and mount the NFS share on our NFS client, this part will vary based on your distribution but it will mostly follow the following steps.

1. Install the NFS client, on arch this is nfs-utils on debian based this is nfs-common.
2. Configure the NFS share in the fstab if you wish which will look like the example below. Or mount it with the command with the one below that.


```bash
## fstab
(Proxmox IP):/Vault/Share /mnt/data nfs defaults,_netdev,x-systemd.automount,noauto 0 0

## Command
sudo mount -t nfs (Proxmox IP):/Vault/Share /mnt/data
```

## Done

I hoped this short guide helped as it was slightly annoying to figure this stuff out, if it did you can leave a star on the repository and if you have any questions/corrections make an issue on the repository.

Have a wonderful day.
