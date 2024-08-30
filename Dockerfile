FROM postgres:15

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=my_db

EXPOSE 5432

COPY init.sql /docker-entrypoint-initdb.d/

