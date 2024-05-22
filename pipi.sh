#!/bin/bash

# Array de dominios/IPs y puertos
hosts_and_ports=(
    "pass.mbbsistemas.es:80"
    "192.168.1.154:80"
)

# Función para verificar si un host y puerto están disponibles
check_host_port() {
    local host=$1
    local port=$2
    nc -z -w5 $host $port 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Host $host en el puerto $port está disponible."
    else
        echo "Host $host en el puerto $port NO está disponible."
    fi
}

# Iterar sobre el array y verificar cada host:puerto
for entry in "${hosts_and_ports[@]}"; do
    IFS=":" read -r host port <<< "$entry"
    check_host_port $host $port
done
