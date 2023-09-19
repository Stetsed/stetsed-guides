---
title: "Grafana Prometheus Monitoring"
date: 2023-09-14T12:13:14+02:00
draft: false
tags: ["grafana", "monitoring", "prometheus", "linux", "docker"]
---

Hey everybody, today we will be going through on how to setup a Grafana + Prometheus stack to allow you to monitor external tools such as Blocky and other services that can output to prometheus(Basically anything with some effort). I have used this to monitor my Linux ISO collector, and my DNS server and it has worked great and has allowed me to create nice dashboards for use. We will be using docker and docker compose to set it up with bind mounts so that trasnfering data is easy.

## Requirments
- Linux Server with Docker Installed
- Root Access
- A cuppa coffee

## Setup

So firstly we will want to go ahead and create the docker-compose.yml file in the directory you want, I would recommend creating a "monitoring" stack directory so its nice and organized. So in that directory go ahead and nano in the below docker compose file.


```yml
version: '3'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus-etc:/etc/prometheus
      - ./prometheus-data:/prometheus
    restart: unless-stopped
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    user: root
    ports:
      - "3000:3000"
    volumes:
      - ./grafana-data:/var/lib/grafana
        ./grafana-etc:/etc/grafana
    restart: unless-stopped
```

We basically create 2 applications here, the prometheus and grafana applications. Both of them have 2 bind mounts one for where they store there data and one for where they store there configuration. This allows us to easily transfer the data to another server if we need to. We also expose the ports for both of them so we can access them from the outside world. And then we tell prometheus where it's config file is. And set the Grafana user to root as it just doesn't seem to work even with permissions set up. Go figure.

Next we want to create a few directories and modify some permissions as otherwise both apps will just say "Ehhh.. no" due to permission issues, firstly go ahead and create each of the directories with the below commands, this includes some nested directories for grafana. Then we want to change the owner of the directories to nobody:nogroup so that the applications inside of the docker containers can access them.

```bash
mkdir -p grafana-etc prometheus-etc grafana-data prometheus-data
cd grafana-etc
mkdir -p provisioning/datasources provisioning/plugins provisioning/notifiers provisioning/dashboards
touch grafana.ini
cd ..
chown nobody:nogroup -R grafana-etc grafana-data prometheus-data

touch prometheus-etc/prometheus.yml
```

Now we have created everything we need and next we can go ahead and enter stuff into our prometheus.yml, I have provided a template below. This basically tells prometheus to scrape the specific endpoint on the machine, most prometheus enabled applications will have a /metrics endpoint that you can scrape. You can also add multiple jobs to this file if you want to monitor multiple things. Just add another job_name and static_configs.

```yml
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: '(Name of Job)'
    static_configs:
      - targets: ['(IP Address of Prometheus Compatible Endpoint)']
```

## Conclusion

Hey so we have arrived at the end of this guide, I hope it helped as I personally found some issues getting information on using grafana with bindmounts as all guides used volumes which I do not like myself as I prefer bindmounts for everything. I hope this guide helped you and if you have any questions feel free to create an issue on the Github Repository and I will try to get to it when I can. Thanks for reading and have a nice day!



