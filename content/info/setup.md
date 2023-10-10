---
title: "Setup"
date: 2023-06-07T14:37:42+02:00
draft: false
---

Here is where I keep track what my current homelab contains and how it is setup.

## Server 1

Currently my primary server is a Dell R530 with the following specs:

- 2x Intel Xeon E5-2667 v3 @ 3.2GHz
- 128GB DDR4 ECC RAM
- 4x 4TB Seagate IronWolf HDDs
- 2x Random 800GB Enterprise SAS SSDs
- iDrac 8 Enterprise
- 1x Intel X520-DA1 10Gb SFP+ NIC

I recently converted this into a Proxmox Server and currently run my main projects on it including my Router, Media VM and a few other bits and bobs. There is also my main function VM which is HA and can go between both Server 1 and Server I recently converted this into a Proxmox Server and currently run my main projects on it including my Router, Media VM and a few other bits and bobs. 

It also holds my Linux ISO collection which is currently not replicated over to Server 2 due to it just not being required however in the future I might move this collection to Server 2 due to it having a higher amount of drive slots.(16 v. 8)

The update path for this server is not very clearly as it's olready very overkill for most of my projects, but if I where to ever upgrade it I would add SSD acceleration

## Server 2

I recently acquired a R730XD with the following specs:

- 2x Intel Xeon E5-2650 v4 @ 2.2GHz
- 128GB DDR4 ECC RAM
- 3 x 8 TB Seagate Enterprise HDDs
- 2x 512GB Crucial SATA SSDs
- iDrac 8 Enterprise
- 1x BCM57810 SFP+ 10Gb SFP+ NIC

This server was a recent addition to my Homelab and is currently not in use much. It does store backups of my main server's VM's(Router, Hub VM) and the Hub VM can migrate between Server 1 and Server 2.

It came with 16x 1TB SAS 12Gbps Drives which I am getting rid off due to them adding over 35 euros a month to the power bill on there own and as such replaced them with the 3x8TB Seagate Enterprise Drives. This runs my main function VM however it is HA and can go between both Server 1 and Server 2 as needed if I need to for example restart Server 1 for maintenance. The upgrade path for this server isn't super clear however if I where to upgrade it it would probally be more storage(Can never have enough) and upgrading the CPU's to something a little more single thread powerful.

## Server 3

Another recently acquired server is my Dell R420: 

- 1x Intel Xeon E5-2430 @ 1.1GHz
- 48GB DDR3 ECC RAM
- 2x Random 512GB SATA SSDs
- 1x Random 1TB SATA HDD
- iDrac 8 Enterprise
- 1x Intel X520-DA1 10Gb SFP+ NIC

So this server I recently acquired as I wanted to split the routing function to another server which would basically be my "Don't you dare every touch this", server. It's currently running Proxmox on the host to give me another vote inside of the proxmox cluster and then runs VyOS virtualized inside of proxmox. The VyOS is technically HA as it can migrate between Server 3 and Server 1, however this would require manually changing over the cables to the ISP and as such it's mostly HA in case of last resort(however as noted later I do have an idear to fix this).

This server doesn't have an upgrade path really, I only have it because I got it for free from a friend and it works so until it dies it will probally stay in this configuration as it's not really doing much, if I where to ever replace it I would either go with a Mini PC or something similar.


## Desktop

- Intel i7-11700K @ 3.6GHz
- 64GB 3600MHz DDR4 RAM
- 500TB Samsung 980 Pro NVMe SSD
- 1TB WD Black NVMe SSD
- Nvidia GTX 1660 Super
- Saphire Pulse RX 5600 XT

Currently I don't use this much as I am mostly working on my laptop, but I use this for gaming. I run Arch Linux as the Host OS and run Windows 10 inside of a GPU Passthrough Virtual Machine using QEMU/Libvirt. 

The upgrade path for this isn't very obvious either as it's already overkill for what I use and even hard games to run like Escape From Tarkov run at an very acceptable framerate. If I where to upgrade it I would probably upgrade the 1660 Super to something more recent as it's currently becoming the bottleneck for the gaming inside of the Windows VM.

## Laptop

- i5-1240p @ 2.6GHz
- 32GB 3200Mhz DDR4 RAM
- 1TB SN770 NVMe SSD
- Framework laptop

I currently use my Framework Laptop for basically everything that I do, and for tasks it can't handle I use Sunshine + Moonlight to either remote into my host OS or my windows VM if I want to game. I run Arch Linux as my OS which uses my [Dotfiles](https://github.com/Stetsed/.dotfiles) which I share between Laptop and Desktop.

The upgrade path for this is more clear as I am currently in pre-order of the Ryzen 7 7840U for the framework laptop and a 61Wh battery and with the switch from DDR4 to DDR5 going for 32GB again will be a nice upgrade.

## Networking

- Mikrotik CRS317-1G-16S+RM
- TPLink 24 Port GbE switch

I recently underwent the upgrade from 1GbE for most of my network to 10GbE. The mikrotik switch is where all 10GbE gear plugs in and then it has a 1 GbE link over to the TPLink switch which is where all my 1GbE gear plugs in.

I just made a quiete major upgrade so currently I do not have many plans to upgrade however I do wanna put in a 5 or so port 1GbE L2 switch between my FTTH termination point and my servers so I can have a Cable running to both servers so I can migrate my Router between servers. Besides this I wanna upgrade my desktop to 10GbE as well.

## Summary

This was a summary of what is currently in my Homelab/Tech setup and what I plan to upgrade in the future. I will try to keep this page updated as I make changes to my setup.





