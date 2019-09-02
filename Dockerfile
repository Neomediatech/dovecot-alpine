FROM alpine:3.9

ENV VERSION=2.3.7.2-r0
ENV BUILD_DATE=2019-08-29

ENV TZ=Europe/Rome

LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/dovecot-alpine \
      org.label-schema.maintainer=Neomediatech

RUN apk update && apk upgrade && apk add --no-cache tzdata && cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    apk add --no-cache tini dovecot bash && \
    rm -rf /usr/local/share/doc /usr/local/share/man && \ 
    rm -rf /etc/dovecot/* && \ 
    mkdir -p /var/lib/dovecot /usr/local/sbin && \ 
    addgroup -g 5000 vmail && \ 
    adduser -D -u 5000 -G vmail vmail
COPY dovecot.conf dovecot-ssl.cnf /etc/dovecot/

COPY entrypoint.sh /
COPY passwd adduser userdel /usr/local/sbin/
RUN chmod +x /entrypoint.sh /usr/local/sbin/*

EXPOSE 110 143 993 995

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 CMD doveadm service status 1>/dev/null && echo 'At your service, sir' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tini", "--", "dovecot","-F"]
