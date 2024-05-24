FROM alpine:3.19

LABEL "Original Repo"="https://github.com/ttionya/vaultwarden-backup" \
      "owner"="jackfrost" \
      "info"="This is based on the original repo"

ENV LOCALTIME_FILE="/tmp/localtime"

RUN mkdir -p -m 755 /app

RUN mkdir -p -m 755 ~/.config/rclone

RUN mkdir -p -m 700 ~/.gnupg/

COPY ./scripts/*.sh /app/

RUN chmod 755 /app/*.sh

RUN ln -sf "${LOCALTIME_FILE}" /etc/localtime

RUN apk add --no-cache bash gnupg 7zip rclone sqlite supercronic tzdata

ENTRYPOINT ["/app/restore.sh"]
