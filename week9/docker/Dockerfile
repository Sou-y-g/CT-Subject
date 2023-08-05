FROM nginx:latest

RUN apt update && apt upgrade

COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
