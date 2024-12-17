---
title: "Setup"
date: 2023-06-07T14:37:42+02:00
draft: false
---

Here is where I keep track what my current homelab contains and how it is setup.

## Server 1 - Dell R530

- CPU: 2x Intel Xeon E5-2667 v3 @ 3.2GHz
- RAM: 128GB DDR4 ECC RAM
- Storage:
  - 4x 4TB Seagate IronWolf HDDs
  - 2x Random 800GB Enterprise SAS SSDs
- Networking: 1x Intel X520-DA1 10Gb SFP+ NIC
- OOBM: iDrac 8 Enterprise

My first server was the Dell R530, this was the first server added to my Homelab and it's served me well, it currently doesn't do alot within my homelab. It odoes do part of my Linux ISO acquisition, and in another Debian VM I run a few services that I have running on both servers at the same time including GaragEQ which I use to give me an S3 compatible storage API to do backups, image upload and other file upload functions. It runs Proxmox as it's host OS as a virtualization layer and is part of the Rij1 Proxmox Cluster.

The R530 doesn't have a really specific upgrade path as most of my storage needs have been moved to the R730XD, however if I where to upgrade it I would probally add v4 CPU's to give it a little extra single core performance for game servers like minecraft and others that favor single core performance.

## Server 2 - Dell R730XD

- CPU: 2x Intel Xeon E5-2650 v4 @ 2.2GHz
- RAM: 128GB DDR4 ECC RAM
- GPU: Nvidia P2000 5GB
- Storage:
  - 6 x 18TB WD HC550 HDDs
  - 3 x 16TB WD DC HC550 HDDs
  - 2x 512GB Crucial SATA SSDs
- Networking: 1x BCM57810 SFP+ 10Gb SFP+ NIC
- OOBM: iDrac 8 Enterprise

This server was the second addition to my homelab and is currently running Proxmox as it's host OS, also part of the Rij1 Proxmox Cluster. It is running my main production workloads, which includes my "Debian1" server which is the server has hosts most of my single VM bound services like Gitea and such, the services that are critical are backed up to garage which then replicates to both Debian2(On the R530), and to an off site VM that I have recieved from a friend. The VM is also capable of HA and when I need to perform maintenance on the R730XD I migrate it to the R530, and when the R530 has maintenace I'll move Debian2 to this server.

It also runs the bulk of my Linux ISO acquisition setup due to it's high amount of drive bays(16x 3.5"), which currently are occupied with the drives listed above both sets being in there own vdev in raidz1, which gives me a total of 48TB of usable storage for my Linux ISO collection. I use apps like Sonarr, Radarr, Jellyfin and others to provide an easy experience in managing them and I highly enjoy it.

The upgrade path for this server at time of update(17-12-2024) is to add more storage, probally in the form of adding more 18TB+ drives as i have more slots remaining for MORE STORAGE.

## Server 3 - Supermicro Smth Server

Server: Supermicro(SMTH)
Motherboard: X11DDW-NT
CPU: 2x Intel(R) Xeon(R) Gold 6248 @ 2.5GHz
Memory: 768GB, 12x Micron 2666MHz 64GB ECC
Networking: Intel x520 2 port SFP+ card
GPU: 2x Nvidia Tesla P4 8GB
Operating System: Proxmox 8.3

Storage:

- 2x 200GB Random Enterprise SSD's in mirror for boot
- 1x 1TB + 1x 8TB random drives in a mirror for data storage
- 2x18TB,1x16TB,1x14TB wide range of drives in a raidz1 for data storage

I recently as of time of writing(17-12-2024) got a new supermicro server which is up to this point besides storage my most powerful server, it was a replacement for the old R420 and is planning to be my main workstation server, as it also has some GPU compute for VM's with VDI. I also setup Nvidia VGPU to allow me to split up the P4's into smaller GPU's.

## Desktop - Custom Build

- CPU: 1x Intel i7-11700K @ 3.6GHz
- RAM: 64GB 3600MHz DDR4 RAM
- Storage:
  - 500GB Samsung 980 Pro NVMe SSD
  - 1TB WD Black NVMe SSD
- GPU:
  - Nvidia GTX 1660 Super
  - Saphire Pulse RX 5600 XT

Currently I don't use this much as I am mostly working on my laptop, but I use this for gaming. I run Arch Linux as the Host OS and run Windows 10 inside of a NVME and GPU passthrough VM for gaming, the 500GB NVME is used for the VM and the 1TB NVME is used for the Host OS, and the GTX 1660 Super is used for the guest and the RX 5600 XT is used for the host.

The upgrade path for this is currently not very expansive as the only plan to add the Desktop to my 10Gb backbone with a SFP+ NIC and some fiber cables/transcievers. Besides this for now it's fine for me as it can handle any games I wanna play, however I might upgrade the 1660 Super in the future to give my gaming VM a bit more umph for some of the newer games I might want to play.

## Laptop - Framework Laptop

- CPU: i5-1240p @ 2.6GHz
- RAM: 32GB 3200Mhz DDR4 RAM
- Storage:
  - 1TB SN770 NVMe SSD

I currently use my Framework Laptop for basically everything that I do, and for tasks it can't handle I use Sunshine + Moonlight to either remote into my host OS or my windows VM if I want to game. I run Arch Linux as my OS which uses my [Dotfiles](https://github.com/Stetsed/.dotfiles) which I share between Laptop and Desktop.

I did cancel my 7840U preorder from framework due to the i5-1240p being enough and the money currently being better spent on servers and then if I need alot of power I can remote into one of my machines like my desktop or one of my server VM's. However in the future I will most likley upgrade this to some form of AMD framework laptop, however this will be in the future as I am currently happy with the performance of this laptop.

## Networking

- Mikrotik CRS317-1G-16S+RM
- Zyxel 36 Port GbE switch
- Random 24 port Cat6 patch panel

The current backbone of my network is 10Gb capable due to my use of the Mikrotik which has 16 SFP+ capable ports, and then for gigabit I use the Zyxel switch which has 36 ports. The mikrotik downstreams to the Zyxel via the Mikrotiks 1GbE port, however I am planning to get a GbE switch that includes an SFP+ port so I can uplink it that way instead of doing it through the 1GbE port. I also added a patch panel to make it easier to manage the cables and to make it easier to add more cables in the future.

The upgrade path for this is pretty clear it will involve removing the Zyxel and replacing it with a switch that has a SFP+ port for upstreaming to the rest of my network, next to this as I said with the R420 section and the router I wanna add a 5 port L2 switch between my ISP and servers so I can have multiple servers be able to take the job of router instead of having to manually do cables.

## Summary

This was a summary of what is currently in my Homelab/Tech setup and what I plan to upgrade in the future. I will try to keep this page updated as I make changes to my setup.
