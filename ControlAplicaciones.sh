#!/bin/bash

# Preguntar contraseña de sudo al inicio
sudo -v

# Mantener activo el timestamp de sudo mientras el script se ejecute
(
    while true; do
        sudo -v
        sleep 60
    done
) &
SUDO_KEEPALIVE_PID=$!

# Asegurarse de matar el proceso de mantenimiento de sudo al salir
trap "kill $SUDO_KEEPALIVE_PID" EXIT

# Evitar advertencias de GTK/Zenity en la consola
export ZENITY_NO_GTK_WARNINGS=1

while true; do
    # 1. Seleccionamos un usuario del sistema con login
    usuario=$(getent passwd | awk -F: '$3>=1000 && $7!="/usr/sbin/nologin" {print $1}' | sort | \
        zenity --list --title="Selecciona un usuario" --text="Usuarios con login:" \
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
        --title="Selecciona binarios" \
        --text="Selecciona los binarios para modificar permisos ACL:" \
        --column="Selecciona" --column="Binario" --column="Seleccionada" \
        "${zenity_list[@]}" \
        --height=400 --width=700 \
        --ok-label="Seleccionar" --cancel-label="Atrás" 2>/dev/null)

    if [ -z "$selected_apps" ]; then
        continue
    fi

    # 3. Preguntar acción
    action=$(zenity --list --title="Acción" --text="Selecciona acción a realizar:" \
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
