FROM alpine:3.19

LABEL "owner"="jackfrost" \
      "info"="This is DynuDNS Updater"

ENV LOCALTIME_FILE="/tmp/localtime"

RUN mkdir -p -m 755 /app

COPY ./scripts/*.sh /app/

RUN chmod 755 /app/*.sh

RUN ln -sf "${LOCALTIME_FILE}" /etc/localtime

RUN apk add --no-cache bash supercronic tzdata curl

ENTRYPOINT ["/app/start.sh"]
