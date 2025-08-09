---
title: "Pangolin Stack"
date: 2025-08-09T17:20:42+02:00
draft: true
---

Hey everybody, haven't written something in a while so decided that while I am having my yearly "redo the entire configuration because I can", moment. I might aswell document for other people aswell how to setup a full [Pangolin](https://digpangolin.com/).

For those who do not know what Pangolin is, it's a reverse-proxy, combined with an authentication portal, and networking. It combines features from software such as Authelia, Cloudflare Tunnels, Wireguard and others, while being based on the traefik reverse proxy as it's core router.

I personally love it because it allows me to centrally manage all my proxies even those that go to another VM. And instead of having to keep track of the remote IP's that might change in the lab the VM's connect to pangolin via a wireguard tunnel. Which also means I can easily add off-site locations without having to mess around alot.

And it does all of this with a really clean looking UI, a very friendly development team who is activley taking in feedback from the community, and has commited to keep even features considered enterprise by some such as auto-provisoning IDP inside of the selfhosted package. Shout out to Milo!
