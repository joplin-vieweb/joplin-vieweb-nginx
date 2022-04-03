FROM nginx:1.21-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx_conf /etc/nginx/conf.d/
COPY start_nginx.sh /bin/start_nginx.sh
RUN chmod +x /bin/start_nginx.sh
CMD [ "/bin/start_nginx.sh" ]