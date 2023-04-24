#! /bin/sh

# exit if a command fails
set -e


apk update

# install pg_dump
apk add postgresql15-client

# install s3 tools
apk --no-cache add aws-cli bash findutils groff less python3 tini inotify-tools

# install go-cron
apk add curl
curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron
apk del curl


# cleanup
rm -rf /var/cache/apk/*
