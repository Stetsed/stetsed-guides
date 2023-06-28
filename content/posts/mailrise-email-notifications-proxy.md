---
title: "Mailrise Email Notifications Gateway"
date: 2023-06-28T15:29:36+02:00
draft: false
tags: ["docker", "mailrise", "email", "notifications", "discord", "smtp"]
---

Hey everybody, I usually don't have notifications because well... I don't want to get a third party email service to send emails. So when looking for solutions I recently found [Mailrise](https://github.com/YoRyan/mailrise) which acts as a SMTP gateway and forwards emails to your own email address. It's a great solution to use because it means you can send notifications anywhere and in this guide I will be showing how to set it up on Discord.

## Requirments

* Server with Docker installed
* A Discord account
* A notification endpoint.

## Setup

So this is gonna be a very simple tutorial but we will start with setting up our notification endpoint. You can see the available endpoints [here](https://github.com/caronc/apprise), it basically has everything from Discord to Matrix to Rocket chat to Signal if you setup a signal bridge, signal would be cool and good for privacy although it should be noted that it currently doesn't support it with 1 phone number as sending it to self doesn't work.

### Getting Discord Webhook URL

So go ahead and make a discord server, you can name it whatever you want it doesn't really matter. Then in the channel you want to recieve notifications you are going to want to click on "Edit Channel" cog and go to "Integrations" and then "Create Webhook". You can name it whatever you want, I named mine "Mailrise" and then you can choose a profile picture if you want. Then you will be given a webhook URL, copy that and save it for later.

### Setting up Mailrise

Go ahead and make a new directory called "Mailrise" and then edit docker-compose.yml, in there you want to paste in the bellow configuration.

```yml
version: "3"

services:
  mailrise:
    image: yoryan/mailrise
    ports:
      - 8025:8025
    volumes:
      - ./mailrise.conf:/etc/mailrise.conf
```

Next we will want to go ahead and add our mailrise.conf file, so go ahead and edit that file and then paste in the below. Firstly where the "urls" is you will want to get your earlier saved discord webhook URL and remove the section that starts at https:// and ends at webhooks/, now go ahead and paste the rest of the string after the discord:// . Then I like to have SMTP authentication so I would say go ahead and replace "username" with the username you wanna use and "password" with the password you wanna use

```conf
configs:
  "*@*":
    urls:
      - discord://
smtp:
  auth:
    basic:
     (username): (password) 
```

## Setup Applications

Now the hard part is done, now all you have to do is setup your applications to send SMTP via your server. In your application your "from" email can be whatever you wish, the outgoing mail server will be your server IP and the port will be 8025. The username and password will be the ones you set in the mailrise.conf file. Encryption type will be none, be aware this means the SMTP stuff will go over plaintext as I am assuming you are doing it over a trusted network. If it's not trusted Mailrise does support using TLS encryption, but for that please check the documentation.

## There's more?

Mailrise has alot more advanced configuration than this that I didn't cover in here, for example that if it's send to X mail adress then send it to Y notification channel, let's say you want personal emails to go to a personal channel and the system warnings to go to a "maintenance" channel the possibilites are endless for more info check the [Github](https://github.com/YoRyan/mailrise).






