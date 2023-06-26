---
title: "DN42 Network UFW Firewall"
date: 2023-06-26T14:02:13+02:00
draft: false
tags: ["dn42", "network", "firewall", "ufw"]
---

Hey, welcome back my blog. Today I will be going through on how to setup a firewall for the DN42 network so that it can't acces other stuff like the open web over the wireguard connections you open. It's a really scuffed way of doing it but I'm just logging it here because I need to remember itself.

## Setup

### Install

Firstly we will want to go ahead and install UFW, to do this use one of the below command on your distro of choice.
```bash
# Debian/Ubuntu
apt install ufw

# Arch
pacman -S ufw

# Fedora
dnf install ufw
```

### Configure

Firstly we will want to go ahead and allow SSH connections to the server so that we don't get locked out, to do this run the below command. We are also allowing the port range 50000-59999/udp these are the ports I use for my wireguard connections, you can change this to whatever you want.
```bash
# SSH
ufw allow ssh

# Wireguard
ufw allow 50000:59999/udp
```

Next we will want to go ahead and setup our script which we use to add connections, let's walk through the below script. We start by asking for the interface name and then with that we get the endpoint IP so we can allow that. Then we allow all the DN42 and affiliate subnets and deny the rest.

```bash
#!/bin/bash

if [[ $1 == "" ]]; then
	echo "Usage: ./firewall.sh <interface>"
	exit 1
else
	Other_IP=$(wg show $1 endpoints | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
	ufw allow out on $1 to $Other_IP
	ufw allow out on $1 to 172.20.0.0/14
	ufw allow out on $1 to 172.20.0.0/24
	ufw allow out on $1 to 172.21.0.0/24
	ufw allow out on $1 to 172.22.0.0/24
	ufw allow out on $1 to 172.23.0.0/24
	ufw allow out on $1 to 172.31.0.0/16
	ufw allow out on $1 to 10.100.0.0/14
	ufw allow out on $1 to 10.127.0.0/16
	ufw deny out on $1 to 0.0.0.0/0
fi
```

Now when you have your wireguard connection setup just run ./firewall.sh <interface> and it will add the rules to the firewall. Be aware that if the IP of the peer ever changes you will need to run the script again. You could do this alot simpler but wheres the fun in that.

Now just run ufw enable and your done :D

## Extra

So if you want to be able to redirect traffic via your network you can follow the below steps, this is a very scuffed way of doing it but I do it because I do not want to have BGP etc running on my router for DN42.

### UFW Rules

Add the below to the bottom of your /etc/ufw/before.rules file, this will allow traffic to be redirected via your network. replace 10.0.0.0/8 with the subnet you want to be able to redirect from and the --to IP with your DN42 IP.
```rules
*nat
:POSTROUTING ACCEPT [0:0]

# Forward traffic from eth1 through eth0.
-A POSTROUTING -s 10.0.0.0/8 -j SNAT --to 172.23.35.255

COMMIT
```

You will also need to allow connections from those through your firewall which can be done with the below command.

```bash
ufw allow in from (subnet)
```

### Finish

Now just setup a static route on your router to point the DN42 subnet to the machine your using as a router and your done. You can now redirect traffic destined for the DN42 network via your network.

