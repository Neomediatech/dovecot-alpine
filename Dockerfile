FROM alpine:3.9

LABEL maintainer="docker-dario@neomediatech.it"

RUN apk update; apk upgrade ; apk add --no-cache tzdata; cp /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN apk add --no-cache tini dovecot bash \
    && rm -rf /usr/local/share/doc /usr/local/share/man \ 
    && rm -rf /etc/dovecot/* \ 
    && mkdir -p /var/lib/dovecot /usr/local/sbin \ 
    && addgroup -g 5000 vmail \ 
    && adduser -D -u 5000 -G vmail vmail
COPY dovecot.conf dovecot-ssl.cnf /etc/dovecot/ 

COPY init.sh /
COPY passwd adduser userdel /usr/local/sbin/
RUN chmod +x /init.sh /usr/local/sbin/*

EXPOSE 110 143 993 995

#HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD doveadm service status || exit 1
ENTRYPOINT ["tini", "--", "/init.sh"] 
