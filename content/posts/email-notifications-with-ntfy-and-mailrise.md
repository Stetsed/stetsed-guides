---
title: "'Email' Notifications With Ntfy and Mailrise"
date: 2023-11-13T11:01:44+01:00
draft: false
---

One of the greatest problems in homelabbing/selfhosting is notifications, now you could use e-mail but let's be honest it's a pain in the ass to deal with. But some applications only support e-mail so.. what do we do? We turn those e-mail notifications into another form, and because we wanna selfhost it we gonna also selfhost the actual delivery of the e-mail with the use of a neat program called ntfy.sh which allows us to get push notifications while mostly being selfhosted.

After configuring the below you just have to point whatever app uses SMTP to your "SMTP Gateway" on the host running malrise, port 8025 with the authentication you set(If wanted you can even add SSL).

### docker-compose.yml
```
version: "3"

services:
  mailrise:
    image: yoryan/mailrise
    restart: unless-stopped
    command: -vv /etc/mailrise.conf
    ports:
      - 8025:8025
    volumes:
      - ./mailrise.conf:/etc/mailrise.conf
  ntfy:
    image: binwiederhier/ntfy
    container_name: ntfy
    command:
      - serve
    environment:
      - TZ=Europe/Amsterdam
    volumes:
      - ./cache-ntfy:/var/cache/ntfy
      - ./etc-ntfy:/etc/ntfy
    ports:
      - 9282:80
    healthcheck:
        test: ["CMD-SHELL", "wget -q --tries=1 http://localhost:80/v1/health -O - | grep -Eo '\"healthy\"\\s*:\\s*true' || exit 1"]
        interval: 60s
        timeout: 10s
        retries: 3
        start_period: 40s
    restart: unless-stopped

```

### mailrise.conf
Just add another user section for each user you want, so let's say example1, bluh2 and bluh3, just addd example1@*, then url will be ntfys://notify.example.com/example1 which is where they will be able to subscribe, and then repeat for the users you want.
```conf
configs:
  "(user)@*":
    urls:
      - ntfys://notify.example.com/(user)
smtp:
  auth:
    basic:
      username: password
```

### etc-ntfy/server.yml 
This configuration will make it so by default non-users aka guests will only be able to send messages, you could make this just be guests can't do anything but then you will have to add a user to your mailrise which is effort.
```yml
base-url: "https://notify.example.com"

listen-http: ":80"


cache-file: /var/cache/ntfy/messages.db
cache-duration: "12h"
cache-batch-size: 0
cache-batch-timeout: "0ms"

auth-file: /var/cache/ntfy/user.db
auth-default-access: "write"

behind-proxy: true

attachment-cache-dir: "/var/cache/ntfy/attachments"
attachment-total-size-limit: "10G"
attachment-file-size-limit: "50M"
attachment-expiry-duration: "3h"

keepalive-interval: "60s"

manager-interval: "1h"

enable-signup: false
enable-login: true
enable-reservations: true

upstream-base-url: "https://ntfy.sh"

global-topic-limit: 15000

visitor-request-limit-burst: 60
visitor-request-limit-replenish: "5s"

visitor-attachment-total-size-limit: "100M"
visitor-attachment-daily-bandwidth-limit: "500M"
```

### Setup
```bash
# Enter the ntfy container
docker compose exec -it ntfy /bin/sh

# Make an user, which includes setting a password
ntfy add user example1

# Give user acces to his topic to both read and write
ntfy access example1 "example1" rw

# Done, now your user can login to your server and the topic they have and then notifications for them will go to there ntfy topic.
```
