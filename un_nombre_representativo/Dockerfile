# Usa la imagen oficial de PostgreSQL como base
FROM postgres:latest


# Configura variables de entorno (opcional)
ENV POSTGRES_DB=GameVault
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=78945


# Copia los archivos de inicialización (si los tienes)
COPY ./init_V2.sql /docker-entrypoint-initdb.d/
COPY ./inserts.sql /docker-entrypoint-initdb.d/
# Exponer el puerto 5432 (puerto por defecto de PostgreSQL)
EXPOSE 5432

