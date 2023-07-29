---
title: "How to Use IPv6 With Wireguard"
date: 2023-07-29T15:29:22+02:00
draft: true
---

So I will keep this short due to my intense frustration with this topic as I have spent the last 4 hours trying to figure this out before eventually realising it's very simple. This guide will start with a Debian 12 box and will end with a Wireguard Server. It won't be the most indepth guide I might do that in the future, and we will be taking some shortcuts. But it will work.


## Requirments
- Debian 12 Box
- Root Access
- A public IP/Possibility to port forward

## Installation

Firstly you will want to go ahead and head over to "https://www.wireguardconfig.com/" where you will want to generate a config with the settings you want, the CIDR will be IPv4 we will add IPv6 later. Once you have generated the config you will want to copy it and paste it into a file on your server. I will be using the name "wg0.conf" for this file.

Firstly install wireguard on Debian which involves installing the wireguard package with apt. 
```bash
apt install wireguard
```

After this we will want to go ahead and enable IPv4 and 6 forwarding on the server, that took me way to long to figure out. 

Append the below to /etc/sysctl.conf
```conf
net.ipv6.conf.all.forwarding=1
net.ipv4.ip_forward=1
```

After you have done this you will want to go ahead and replace the Post up and Post down commands that come included with your Wireguard Config with the below set which was the most annoying part to figure out. Replace eth0 with the interface your traffic is gonna go out of.

```bash
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Now to your client configs go ahead and add an IP each generated with https://iplocation.io/ipv6-address-generator which will generate a random local IPv6 adress for you. You will want to add this to the adress section of your client configs adding a comma between the adresses. Also add one to your server in the same way. 

Atfer this go ahead and enable the wireguard service and start it. And then assuming you've port forwarded and set the external IP correctly you should now have an IPv6 and IPv4 capable Wireguard Server. 


PS: Sorry for how low quality this post is, I have solely written it for myself in the future, I may come back to it to improve it.
