#!/bin/bash

# Define el servidor y el puerto
SERVIDOR="192.168.1.101"
PUERTO="22"

# Combina telnet con un tiempo de espera y redirección de E/S
if $(timeout 3 telnet "$SERVIDOR" "$PUERTO" > /dev/null 2>&1); then
    echo "✅ Conexión con el puerto SSH ($PUERTO) en $SERVIDOR exitosa."
else
    echo "❌ Conexión con el puerto SSH ($PUERTO) en $SERVIDOR fallida o tiempo de espera agotado."
fi
