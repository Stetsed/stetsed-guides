---
title: "ZFS on Arch Linux"
date: 2023-05-29T09:00:56+02:00
draft: false
tags: ["Arch Linux", "Linux", "ZFS"]
---

Good evening, today I will be showing in this guide how to use the ZFS(Zetabyte-File-System) on Arch Linux. I shall be doing this because ZFS has a number of advantages that can be useful such as:

* Builtin Snapshots Feature
* Builtin Encryption
* Builtin File System Compression
* Builtin Deduplication
* Builtin Volume Manager
* Builtin Transfer Mechanism

All of these features together make it a really appealing option to use as your file system, but do be warned that due to licensing issues between the GPL which Linux uses and CDDL which ZFS uses, ZFS cannot be included into the main line kernel. As such we will be using an external project called Arch ZFS which provides Arch Repositories for ZFS packages, you may also use the AUR for such tasks but generally is unrecommended as it would require you to create a new user and then build due to not being able to makepkg on the root user.

## Notes

This guide was made for 1 drive, if you are using multiple drives you probally wanna make the boot pool a ZFS pool aswell to it replicates. To do this read [This](https://wiki.archlinux.org/title/ZFS#GRUB-compatible_pool_creation) section of the Arch Wiki to make a GRUB compatible boot pool. In this guide we will be using EFI direct booting to get very fast boot times but at this time it seems to be an annoying process to EFI direct boot while replicating over multiple drives. Although in theory you could do this by modifying the mount paths and mounting each drive to for example /boot/EFI1, /BOOT/EFI2 etc and then adding rules to mkinitcpio to generate boot files for each of them.

This guide is assuming your using a Modern NVME SSD. Through parts of this guide I will add notes where you might want to change the settings for certain diffrent scenarios. So please read the comments before just copy and pasting.

Alot of this info I have integrated into my Installer which you can find [Here](https://github.com/Stetsed/.dotfiles/blob/main/.bin/install/zfs_install.sh), while I wouldn't recommend blindly using it you might be able to use it as a starting point for your installer to make setting up ZFS easier.

## Setup

### ArchISO

Firstly we will need to get ZFS on the ArchISO, this can be done 2 ways but because we are lazy we are gonna do it the easy way. You are gonna go ahead and enter the bellow command which will curl down a script(just run curl if you wanna see what it does), which will install the ZFS packages onto the ISO so we can interact with them. If you don't wanna go through this every time the other solution is to build a custom ArchISO with the ZFS packages already installed.

```bash
curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash
```

### Creating the Drive Paritition

Firstly let's go ahead and partition our drive, to start off with we will have to wipe it which is the first command listed. You can find the drive you wanna use in /dev/disk/by-id, make sure you use by-id as mount paths can change. Then we can go ahead and enter the second command and the third command which will first generate a 550MB partition tagged with the EFI tag which we will use as our EFI partition. Secondly we create a partition with the rest of the remaining space where our ZFS pool shal later reside.

```bash
# Command 1
blkdiscard -f /dev/disk/by-id/(disk)
# Command 2
sgdisk -n1:0:+550M -t1:ef00 /dev/disk/by-id/(disk)
# Command 3
sgdisk -n2:0:0 -t2:bf00 /dev/disk/by-id/(disk)
```

### Setup ZFS Pool and Volumes

#### ZPool Creation

Next we will have to go ahead and make some choices. Firstly we will start with the base command which is the first command in this list. This will setup a ZFS pool. If your running an older drive you might want to change ashift away from 12 as 12 uses 4096 byte sectors. While older drives might use 512 in which case you wanna use ashift=9. Incase you wanna use encryption on the zpool go ahead ahead and use the modified "Encrypted" command. You can also specify some of the extra options I have layed out in the "Extra" section such as deduplication and compression. Do note that some of these features like Deduplication require more RAM and a beefier CPU to run them so use at your own risk. 

```bash
# Base Command
zpool create -f -O acltype=posixacl -O xattr=sa -O canmount=off -o ashift=12 zroot /dev/disk/by-id/(drive)-part2
# Encrypted Command
zpool create -f -O acltype=posixacl -O xattr=sa -O canmount=off -o ashift=12 -O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt zroot /dev/disk/by-id/(drive)-part2
# Extra options
-O compression=lz4 -O dedup=on -O atime=off
```

#### Root Volume Creation

We can go ahead and create our top level volume. This will create a volume called zroot/ROOT under which we will create our wanted root volume. I made it like this so you can have multiple diffrent root volumes incase you want multiple installs as the same time or just multiple diffrent Distro's. After this we can go ahead and create our Root Volume.
```bash
# Create top level volume
zfs create -o canmount=off -o mountpoint=none zroot/ROOT
```

```bash
# Create Root Volume
zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/arch
```

#### Home Volume Creation

Next we will go ahead and create our Home Folder which we will be able to use across all of our installations. Firstly we will want to create the data root folder than will store our home folder. That can be done with the first command listed here. After this you can go ahead and enter the second command which will create our home folder.

```bash
# Create top level volume
zfs create -o mountpoint=none zroot/data
# Create Home Volume
zfs create -o mountpoint=/home zroot/data/home
```

#### Cleaning up

Next we can go ahead and run the following command which in order do, unmount the ZFS volume, export them, import them, including -l if your using encryption, mount the ROOT volume and the home volume which will be mounted to /mnt and /mnt/home respectivley and then set the bootfs by default to be zroot/ROOT/arch on zroot. Lastly we make a /boot directory and mount our EFI partition to /boot.

```bash
# Umount ZFS Volume
zfs umount -a
# Export ZFS Pool
zpool export zroot
# Import ZFS Pool
zpool import -l -d /dev/disk/by-id -R /mnt zroot
# Mount the ROOT and Home Volume
zfs mount zroot/ROOT/arch
zfs mount zroot/data/home
# Set bootfs
zpool set bootfs=zroot/ROOT/arch zroot
# Make boot and etc dir
mkdir /mnt/boot
mkdir /mnt/etc
# Mount EFI partition
mount /dev/disk/by-id/(drive)-part1 /mnt/boot
```

### Chroot

Now you can follow the normal guide of setting up the system which can be found on the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide#Installation). You will however in your chroot enviroment have to do one extra step which is installing the ZFS DKMS package and adding it to your mkinitcpio. You can do this by putting ZFS between keyboard and keymap in /etc/mkinitcpio.conf, and adding the ArchZFS repository to your pacman.conf and then install zfs-dkms or zfs-dkms-git

#### Setup ArchZFS Repository

```bash
# Add ArchZFS Repository to pacman.conf
echo -e '[archzfs]\nServer = https://archzfs.com/$repo/$arch' >>/etc/pacman.conf
# Import ArchZFS Key and Sign it
pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
# Refresh Database
pacman -Syu
# Install zfs-dkms or zfs-dkms-git
pacman -Syu zfs-dkms(-git)
```

#### Add ZFS module to mkinitcpio.conf and kernel cmdline

Open /etc/mkinitcpio.conf in your preffered text editor that's installed. Then in the "Hooks" line between keyboard and keymap add a "zfs" hook which will do what we want. Then go ahead and regenerate mkinitcpio files and then you can continue your install as normal as you usually would.

```bash
mkinitcpio -P
```

You also need to add the below options to your kernel cmdline, this can either be in /etc/kernel/cmdline if your generating UKI's using Mkinitcpio, or in your dracut settings or in your bootloader settings.

```
zfs=zroot/ROOT/arch rw
```

## After Setup

### Services you should enable

Firstly make sure to enable these services on your install as they do things like scrub which keeps your data integrity up, and mount for example your home partition.

```bash
systemctl enable zfs-scrub-weekly@zroot.timer
systemctl enable zfs.target
systemctl enable zfs-import-cache
systemctl enable zfs-mount
```

### Commands you should know

Now some commands you might want to know are listed below and with what they do, ZFS is a very nice file system with alot of uses. If you want to learn more check the OpenZFS [Wiki](https://openzfs.github.io/openzfs-docs/) and the [Arch Wiki](https://wiki.archlinux.org/title/ZFS#Installation).

```bash
# Create a Snapshot(No spaces between Path @ and Snapshot name)
zfs snapshot -r (path) @ (snapshot-name)

# Send a snapshot over SSH to another machine running ZFS
zfs send -vw (path) @ (snapshot-name) | ssh kaboommachine "zfs recieve pool/backups/machine"
```

### What can you do after this?

You can setup something like [ZFSBootMenu](https://docs.zfsbootmenu.org/en/v2.2.x/) which allows you to easily switch between Distro's that are hosted on your ZFS pool, or go back to previous snapshots, or hell even bootstrap your entire system from a NAS via ZFS recv. Do note that for this to work you need to have your boot items be on the ZFS pool, so you would want to move your EFI mount to something like /EFI or /boot/EFI.

If you setup encryption but want to be able to unlock the PC remotely have a look at [My Script](https://github.com/Stetsed/.dotfiles/blob/main/.bin/install/extra.sh) specifically at the ZFS_Remote_Unlock_Setup part of the script which utilizes dropbear to allow you to remotely unlock the PC via SSH.

## Credits

Arch Wiki Entries: [ZFS](https://wiki.archlinux.org/title/ZFS#Installation) & [Install Arch On ZFS](https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS)





