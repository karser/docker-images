# postgres-backup-s3

Backup PostgresSQL to S3 (supports periodic backups and encryption)

This is a fork of schickling/postgres-backup-s3 with postgres 15 support and encryption.

## Usage

Docker:
```
docker run -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PREFIX=backup \
-e POSTGRES_DATABASE=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password -e POSTGRES_HOST=localhost \
-e ENCRYPT_PUBLIC_KEY_PATH=/test \
karser/postgres-backup-s3:15
```

Docker Compose:
```yaml
postgres:
  image: postgres
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

pgbackups3:
  image: karser/postgres-backup-s3
  links:
    - postgres
  environment:
    SCHEDULE: '@daily'
    S3_REGION: region
    S3_ACCESS_KEY_ID: key
    S3_SECRET_ACCESS_KEY: secret
    S3_BUCKET: my-bucket
    S3_PREFIX: backup
    POSTGRES_DATABASE: dbname
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
    POSTGRES_EXTRA_OPTS: '--schema=public --blobs'
    ENCRYPT_PUBLIC_KEY_PATH: '/db-backups.pub.pem'
  volumes:
    - './db-backups.pub.pem:/db-backups.pub.pem:ro'
```

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

### Generate Public and Private keys
```
openssl req -x509 -nodes -newkey rsa:4096 -keyout db-backups.priv.pem -out db-backups.pub.pem -subj "/C=US/emailAddress=info@acme.com/ST=Ohio/L=Columbus/O=Widgets Inc/OU=Some Unit"
```

### How to restore

```
openssl smime -decrypt -in ./db.sql.gz.enc -binary -inform DEM -inkey ~/.ssh/db-backups.priv.pem -out ./db.sql.gz
gunzip ./db.sql.gz
pg_dump -h localhost -d sentry -U sentry -f /tmp/sentry.sql
```

### How to build
```
docker build -t karser/postgres-backup-s3:15 .
```
