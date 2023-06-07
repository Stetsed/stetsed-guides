---
title: "Setup"
date: 2023-06-07T14:37:42+02:00
draft: false
---

Here is where I keep track what my current homelab contains and how it is setup.

## Server

Currently my primary server is a Dell R530 with the following specs:

- 2x Intel Xeon E5-2667 v3 @ 3.2GHz
- 128GB DDR4 ECC RAM
- 4x 4TB Seagate IronWolf HDDs
- 1x Dell SAS Drive
- iDrac 8 Enterprise
- 1x Intel X520-DA2 10GbE NIC

I am currently running TrueNAS Scale on this machine and run most of my home service inside of the Kubernetes cluster that is included with it. For services I cannot do this with I have both an archlinux VM and a Debian based VM running on it. 

The update path for this server is not very clearly as it's olready very overkill for most of my projects, but if I where to ever upgrade it I would add SSD acceleration

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

- Unifi Dream Machine Pro
- Mikrotik CRS317-1G-16S+RM
- TPLink 24 Port GbE switch

I recently underwent the upgrade from 1GbE for most of my network to 10GbE. The mikrotik switch is where all 10GbE gear plugs in and then for anything GbE it either goes through the UDM Pro or the TPLink switch. 

As I just made a quiet heavy upgrade to this I don't except to upgrade it soon, however I do plan to upgrade my Desktop to 10GbE as currently only my server has a 10GbE NIC inside of it.

## Summary

This was a summary of what is currently in my Homelab/Tech setup and what I plan to upgrade in the future. I will try to keep this page updated as I make changes to my setup.





