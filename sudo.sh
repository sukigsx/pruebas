#!/bin/bash

# Este script verifica si un usuario tiene permisos de sudo en un servidor remoto.
# Recibe como argumentos el usuario y el host (ej: ./verificar_sudo.sh sukigsx 192.168.1.101)

# Comprueba si se proporcionaron los argumentos necesarios
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <usuario> <host>"
    exit 1
fi

USUARIO=$1
HOST=$2

# Intenta ejecutar 'sudo -l' en el host remoto y redirige la salida
# La redirección '> /dev/null 2>&1' oculta cualquier salida (exitosa o de error)
# Lo que nos interesa es el código de salida ($?) para saber si el comando fue exitoso
ssh "$USUARIO@$HOST" 'sudo -l' > /dev/null 2>&1

# Almacena el código de salida del último comando
if [ $? -eq 0 ]; then
    echo "El usuario $USUARIO tiene permisos de sudo en $HOST."
else
    echo "El usuario $USUARIO NO tiene permisos de sudo en $HOST."
fi
