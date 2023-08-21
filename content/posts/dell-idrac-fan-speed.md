---
title: "Dell iDrac Fan Speed Control"
date: 2023-08-21T13:47:47+02:00
draft: false
tags: ["dell", "idrac", "fan","control", "homelab"]
---

Hey everybody, quick guide today on how to manually set the fan speed on your Dell iDrac. This is useful if you want to lower the noise of your Dell server. As most dell servers have a fan floor which means it will always be loud even when it's already cooled off.

## Prerequisites

* Dell Server with iDrac
* iDrac IP address
* iDrac username and password
* Linux Box

### Step 1: Install ipmitool

Firstly we will want to go ahead and install the tool that will allow us to send commands to the IPMI(iDrac is a form of IPMI). So go ahead and install it I have listed below some of the commands

```bash
# Arch
pacman -S ipmitool

# Debian/Ubuntu
apt install ipmitool

# Fedora
dnf install ipmitool
```

### Step 2: Enable IPMI over LAN

Next you will want to go ahead and login on your iDrac IPMI over your network and follow the below steps to enable IPMI over LAN which will allow us to send commands over the LAN.

1. Login to your iDrac
2. Go to iDrac Settings
3. Go to Network
4. Scroll down to IPMI Settings
5. Enable IPMI over LAN

### Step 3: Send IPMI commands

So next we will first want to go ahead and pick out what fan speed we want to use. Generally I use 20% as it's a good balance between sound and temperature. However your speed will depend on your enviroment. After you have done this go ahead and execute this first command replacing the required sections.

```bash
# Enable manual fan control
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x01 0x00

#0% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x00

#5% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x05

#10% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x0A

#20% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x14

#30% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x1e

#50% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x32

#70% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x46

#80% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x50

#100% Fan Speed
ipmitool -I lanplus -H (iDrac IP) -U (Username) -P (Password) raw 0x30 0x30 0x02 0xff 0x64
```

To understand what we are doing here we are sending a raw command to the IPMI which is the iDrac. The first command is enabling manual fan control. The commands atfer that are to set the fan speed, the first part is basically "Set fan speed" and then the last HEX decides what the fan speed is, the 0x does nothing while the 2 digits after that tell us what the fan speed should be, so 00 is 0%, 50 is 80% and so on and so forth.

## Conclusion

I hoped you enjoyed this short tutorial, I just wrote it as I found myself also using it alot and it was always a pain to find the guide I used so I wrote this. If it helps I would appreciate a star on the repository and otherwise have a wonderful day.
