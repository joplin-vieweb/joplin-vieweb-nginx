#!/bin/sh

if [ ! -d "/etc/letsencrypt/live/${server_name}" ]
then
    echo "Let's start nginx to create certificates for ${server_name}"
    envsubst '${server_name}' < /etc/nginx/conf.d/init_cert.conf.template > /etc/nginx/conf.d/init_cert
    ln -sf /etc/nginx/conf.d/init_cert /etc/nginx/conf.d/default.conf

    # start nginx until we have a certificate
    nginx -g 'daemon on;'
    safety=0
    while [ ! -d "/etc/letsencrypt/live/${server_name}" ]
    do
        echo "waiting for certificate ..."
        sleep 2
        safety=$((safety + 1))
        if [ $safety -gt 60 ]; then break; fi
    done
    sleep 5
    nginx -s stop
    sleep 5
fi

if [ -d "/etc/letsencrypt/live/${server_name}" ]
then
    echo "We have a certificate for ${server_name}, let's start nginx to serve joplin-vieweb"
    envsubst '${DOMAIN}' < /etc/nginx/conf.d/joplin_vieweb.conf.template > /etc/nginx/conf.d/joplin_vieweb
    ln -sf /etc/nginx/conf.d/joplin_vieweb /etc/nginx/conf.d/default.conf

    # loop to reload every 6h the certificate.
    while :
    do 
        sleep 6h
        echo "RELOAD NGINX"
        nginx -s reload
    done &

    safety2=0
    while [ true ]
    do
        nginx -g 'daemon off;'
        safety2=$((safety2 + 1))
        if [ $safety2 -gt 10 ]; then break; fi
        echo "nginx start retry ${safety2}"
        sleep 5
    done
else
    echo "Certificate acquisition failed."
fi


