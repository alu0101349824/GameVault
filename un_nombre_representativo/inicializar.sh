#!/bin/bash

# Nombre del contenedor y de la imagen
CONTAINER_NAME="gamevault"
IMAGE_NAME="gamevaultdb"


# Eliminar el contenedor si ya existe
if [ "$(sudo docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Eliminando contenedor existente..."
    sudo docker rm -f $CONTAINER_NAME
fi


# Construir la imagen
echo "Construyendo la imagen..."
sudo docker build -t $IMAGE_NAME .


# Ejecutar el contenedor
echo "Iniciando el contenedor..."
sudo docker run --name $CONTAINER_NAME -d -p 5432:5432 $IMAGE_NAME

# Verificar si el contenedor está en ejecución
if [ "$(sudo docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Conectándose al contenedor $CONTAINER_NAME..."
    docker run --name gamevault -e POSTGRES_DB=GameVault -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=78945 -p 5432:5432 -d gamevaultdb
else
    echo "El contenedor $CONTAINER_NAME no está en ejecución."
fi
