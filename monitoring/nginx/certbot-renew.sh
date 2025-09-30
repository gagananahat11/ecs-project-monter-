#!/bin/bash
DOMAIN=YOUR.GRAFANA.DOMAIN
EMAIL=you@example.com
docker run --rm -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot-www:/var/www/certbot certbot/certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --non-interactive
# then reload nginx
docker exec -it nginx nginx -s reload
