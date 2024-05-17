#!/bin/bash

# Define un array con las IP:puertos y los nombres de servicio correspondientes
declare -A servicios=(
    ["192.168.1.116:9000"]="Portainer"
    ["192.168.1.116:9925"]="Mealie"
    ["192.168.1.116:443"]="nginx"
    ["192.168.1.116:81"]="nginx"
    ["192.168.1.116:80"]="nginx"
    ["192.168.1.116:5000"]="snippet-box"
    ["192.168.1.116:4444"]="Vaulwarde"
    ["192.168.1.116:22"]="ssh"
)

#variables para el bot de telegram
TOKEN="6285600343:AAGZbpbGIDRX_pF3qT1uAbAMJRuinBffkb0"
ID="488663957"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"



# Función para comprobar si un servicio está levantado
check_service() {
    ip_port=$1
    nombre_servicio=$2

    # Extrae la IP y el puerto del formato IP:puerto
    ip=$(echo $ip_port | cut -d':' -f1)
    puerto=$(echo $ip_port | cut -d':' -f2)

    # Realiza un ping al host para comprobar si está accesible
    ping -c 1 $ip > /dev/null
    if [ $? -ne 0 ]; then
        echo "- ip $ip FALLO." >> resultado.txt
        return
    fi

    # Intenta conectar al puerto para verificar si el servicio está levantado
    nc -z -w3 $ip $puerto
    if [ $? -eq 0 ]; then
        printf "%-10s %-20s %-5s\n" "- $nombre_servicio" "$ip:$puerto" "V" >> resultado.txt
    else
        printf "%-10s %-20s %-5s\n" "- $nombre_servicio" "$ip:$puerto" "F" >> resultado.txt
    fi
}

# Itera sobre cada elemento del array y comprueba el estado del servicio
for ip_port in "${!servicios[@]}"; do
    nombre_servicio=${servicios[$ip_port]}
    check_service $ip_port "$nombre_servicio"
done
curl -s -X POST $URL -d chat_id=$ID -d text="$(cat resultado.txt | sort -k2 | column -t)" >/dev/null
rm resultado.txt
