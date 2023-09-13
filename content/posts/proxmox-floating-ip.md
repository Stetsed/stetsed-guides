---
title: "Proxmox Floating Ip"
date: 2023-08-27T11:32:03+02:00
draft: false
tags: ["proxmox", "keepalived", "floating ip", "cluster", "ha", "linux"]
---

Hey everybody welcome back to another guide, today I will be showing you how we can setup a Floating IP on Proxmox VE 8 using Keepalived. This can be handy when your running a cluster and you want to always make your proxmox available even if one of the nodes is down without having to rely on another program to do this for you like NGINX or HAProxy.

## Requirments

- 2 or more Proxmox VE 8 nodes
- Root access to all nodes
- An IP you designate as a floating IP

## Setup

First let's go ahead and install keepalived

```bash
apt update && apt install keepalived
```

Secondly we will want to enable nonlocal IP's so our proxmox machine will actually accept our Floating IP. So go ahead and add the below to /etc/sysctl.conf

```
net.ipv4.ip_nonlocal_bind=1
```

## Configure Keepalived

Next we will want to go ahead and edit the /etc/keepalived/keepalived.conf and firstly add our global preferences. This is the most barebones global_defs we can have, however you can add stuff such as e-mail notifications when it gets triggered and other stuff so play around with it if you want.

```
global_defs {
   router_id ROUTER1
}
```

Next we will want to go ahead and add our actual config which will be a variant of the one below. So firstly you want to do the MASTER config which in olur case will have a priority of 5 as it's the lowest priority we have, and whatever the lower priority is will become the master. Then you want to go ahead and add your interface which in my case is vmbro0. Then you want to add your virtual_router_id which is a number between 1 and 255, this has to be the same for the other keepalived instances that are trying to negotiate the same VRRP. 

Password is the password you want to use to authenticate the nodes with.
Then you will want to go ahead and replace the (Floating IP) with the IP you want Keepalived to manage. Warning this should be an IP outside of your DHCP range or you will have issues. Now go ahead and add the config to each of your nodes with it's settings (So MASTER for 1 node and BACKUP for the rest, correct interfaces and the priority set). After which you can start the Keepalived service on all nodes and you should be good to go and if all went well it should all be working :D.

```conf
vrrp_instance PROXMOXFLOATING {
    state MASTER/BACKUP
    interface vmbr0
    virtual_router_id 0 
    priority 5/10
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ULTRASECRETGODPASSWORD 
    }
    virtual_ipaddress {
        (Floating IP)
    }
}
```

## Conclusion

So after you have done this go ahead and enable the service with "systemctl enable --now keepalived" and then if everything is correct you should be able to ping the Floating IP and it should be working. Now when you want to acces your cluster via the web you just go to that IP and it should work. And your one step closer to a fully HA cluster :D. 

I hope this guide helped you and if you have any questions make an issue on the Github repo and I will try to help as best I can. Credits go to [this](https://blog.alexolivan.com/the-return-of-the-linux-router-from-pfsense-to-debian-part-4-from-carp-to-vrrp/) post which is where I got most of the info but wrote this for if people search for proxmox as this one was specifically for a plain debian box (which in a way proxmox is).
