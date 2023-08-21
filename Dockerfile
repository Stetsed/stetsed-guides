FROM docker.io/nginx:alpine

COPY ./public /usr/share/nginx/html
