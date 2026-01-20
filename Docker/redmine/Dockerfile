FROM redmine:5.1

ENV LANG=C.UTF-8

# Datenbankkonfiguration
ENV REDMINE_DB_POSTGRES=db
ENV REDMINE_DB_DATABASE=redmine
ENV REDMINE_DB_USERNAME=redmine
ENV REDMINE_DB_PASSWORD=redmine

# Shared files directory
VOLUME ["/usr/src/redmine/files"]

EXPOSE 3000
