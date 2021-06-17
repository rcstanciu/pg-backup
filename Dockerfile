FROM google/cloud-sdk:321.0.0-alpine

RUN apk add --no-cache postgresql-client openssl tini

COPY ./scripts /usr/local/bin/scripts
RUN chmod +x /usr/local/bin/scripts/*
RUN mv /usr/local/bin/scripts/* /usr/local/bin \
    && rmdir /usr/local/bin/scripts
    
COPY ./entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint

# https://crontab.guru/#*_*/8_*_*_*
RUN echo '* * */8 * * cd /app && bash /app/scripts/backup.sh >> /var/log/pg_backup.log' >> /etc/crontabs/root

WORKDIR /app
ENTRYPOINT ["/entrypoint"]
CMD ["/sbin/tini", "--", "/usr/sbin/crond", "-f", "-l", "8"]