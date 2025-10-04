#!/bin/bash

rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores
# Preguntar contraseña de sudo al inicio
#sudo -v

# Mantener activo el timestamp de sudo mientras el script se ejecute
#(
#    while true; do
#        sudo -v
#        sleep 60
#    done
#) &
#SUDO_KEEPALIVE_PID=$!

# Asegurarse de matar el proceso de mantenimiento de sudo al salir
#trap "kill $SUDO_KEEPALIVE_PID" EXIT

# Evitar advertencias de GTK/Zenity en la consola
export ZENITY_NO_GTK_WARNINGS=1

# Comprobar si el script se ejecuta con privilegios de root
clear
if [ "$EUID" -ne 0 ]; then
  echo ""
  echo -e "${rojo} Este script necesita permisos de sudo.${borra_colores}"
  echo ""
  echo -e "${amarillo} Por favor, ejecútalo con:${borra_colores}"
  echo -e "   sudo $0"
  echo -e "   sudo bash $0"
  echo ""
  exit 1
else
  echo ""
  echo -e "${amarillo}OK.${borra_colores}"
fi



while true; do
    # 1. Seleccionamos un usuario del sistema con login
    usuario=$(getent passwd | awk -F: '$3>=1000 && $7!="/usr/sbin/nologin" {print $1}' | sort | \
        zenity --list --title="Diseñado por SUKIGSX" --text="Selecciona el usuario para aplicar los permisos de ejecucion de las aplicaciones del sistema:" \
        --column="Usuario" --height=300 --width=300 --ok-label="Seleccionar" --cancel-label="Salir" 2>/dev/null)

    if [ -z "$usuario" ]; then
        exit 0
    fi

    # 2. Listar binarios en rutas del $PATH
    apps_array=()
    IFS=: read -ra path_dirs <<< "$PATH"
    for dir in "${path_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r file; do
                # Solo archivos ejecutables regulares o enlaces simbólicos
                if [ -x "$file" ] && [ -f "$file" ]; then
                    apps_array+=("$file")
                fi
            done < <(find "$dir" -maxdepth 1 -type f -o -type l 2>/dev/null)
        fi
    done

    # Ordenar y eliminar duplicados
    mapfile -t apps_array < <(printf "%s\n" "${apps_array[@]}" | sort -u)

    # Convertimos la lista en formato para Zenity --checklist
    zenity_list=()
    for app in "${apps_array[@]}"; do
        zenity_list+=("$app" "$app" FALSE)
    done

    # Mostramos la lista de binarios
    selected_apps=$(zenity --list --checklist \
        --title="Diseñado por SUKIGSX" \
        --text="Selecciona las aplicaciones marcando las casillas.\n- Puedes seleccionar una o varias\n- Tambien puedes buscar aplicaciones escribiendo directamente su nombre" \
        --column="Selecciona" --column="Binario" --column="Seleccionada" \
        "${zenity_list[@]}" \
        --height=400 --width=700 \
        --ok-label="Seleccionar" --cancel-label="Atrás" 2>/dev/null)

    if [ -z "$selected_apps" ]; then
        continue
    fi

    # 3. Preguntar acción
    action=$(zenity --list --title="Diseñado por SUKIGSX" --text="Selecciona acción a realizar, para el usuario $usuario:" \
        --radiolist --column="Selecciona" --column="Acción" \
        TRUE "Quitar permisos de ejecución (rw-)" \
        FALSE "Dar permisos de ejecución (rwx)" \
        --ok-label="Aplicar" --cancel-label="Salir" 2>/dev/null)

    if [ -z "$action" ]; then
        exit 0
    fi

    # Aplicamos ACL a cada binario seleccionado
    IFS="|" read -ra apps_selected <<< "$selected_apps"
    for app in "${apps_selected[@]}"; do
        # Resolver enlace simbólico si existe
        real_app=$(readlink -f "$app")
        if [ "$action" == "Quitar permisos de ejecución (rw-)" ]; then
            sudo setfacl -m u:"$usuario":rw- "$real_app"
        else
            sudo setfacl -m u:"$usuario":rwx "$real_app"
        fi
    done

    zenity --info --text="Permisos ACL aplicados correctamente al usuario $usuario." 2>/dev/null

    exit 0
done
