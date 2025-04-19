#!/bin/bash

# COLORES (por si quieres mantener estilo)
verde="\e[;32m\033[1m"
rojo="\e[0;31m\033[1m"
borra_colores="\033[0m\e[0m"

# ARCHIVO DONDE SE GUARDAN LOS SERVIDORES
SERVER_LIST="$HOME/.ssh_server_list"

# DETECTAR TERMINAL DISPONIBLE
detectar_terminal() {
    if command -v gnome-terminal >/dev/null 2>&1; then
        TERMINAL_CMD="gnome-terminal -- bash -c"
        TERMINAL_SUFFIX="; exec bash"
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        TERMINAL_CMD="xfce4-terminal --hold --command"
        TERMINAL_SUFFIX=""
    elif command -v konsole >/dev/null 2>&1; then
        TERMINAL_CMD="konsole -e"
        TERMINAL_SUFFIX=""
    elif command -v xterm >/dev/null 2>&1; then
        TERMINAL_CMD="xterm -hold -e"
        TERMINAL_SUFFIX=""
    elif command -v tilix >/dev/null 2>&1; then
        TERMINAL_CMD="tilix -a session-add-right -x"
        TERMINAL_SUFFIX=""
    else
        echo "❌ No se encontró ninguna terminal gráfica instalada."
        exit 1
    fi
}

# FUNCION PARA CONECTAR
conectar_servidores() {
    if [ ! -s "$SERVER_LIST" ]; then
        echo -e "${rojo}No hay servidores en la lista. Agrega al menos uno primero.${borra_colores}"
        exit 1
    fi

    mapfile -t seleccionados < <(nl -w2 -s': ' "$SERVER_LIST" | fzf --multi --prompt="Seleccione servidores (TAB para varios): " --layout=reverse --ansi)

    if [ "${#seleccionados[@]}" -eq 0 ]; then
        echo -e "${rojo}No se ha seleccionado ningún servidor.${borra_colores}"
        exit 1
    fi

    servidores=()
    for linea in "${seleccionados[@]}"; do
        numero=$(echo "$linea" | cut -d':' -f1 | tr -d ' ')
        servidores+=("$numero")
    done

    for numero in "${servidores[@]}"; do
        servidor=$(sed -n "${numero}p" "$SERVER_LIST")
        nombre=$(echo "$servidor" | cut -d',' -f1)
        usuario=$(echo "$servidor" | cut -d',' -f2)
        host=$(echo "$servidor" | cut -d',' -f3)

        KEY_PATH="$HOME/.ssh/id_rsa_$nombre"

        echo -e "${verde}Conectando a $nombre ($usuario@$host)...${borra_colores}"

        if ssh -i "$KEY_PATH" -o BatchMode=yes -o ConnectTimeout=5 "$usuario@$host" 'echo OK' 2>/dev/null | grep -q OK; then
            eval "$TERMINAL_CMD \"ssh -i $KEY_PATH $usuario@$host$TERMINAL_SUFFIX\" &"
        else
            echo "Copiando clave SSH a $host..."

            if [ ! -f "$KEY_PATH" ]; then
                ssh-keygen -t rsa -b 4096 -N "" -f "$KEY_PATH" <<< y >/dev/null 2>&1
            fi

            ssh-copy-id -i "$KEY_PATH.pub" "$usuario@$host"
            eval "$TERMINAL_CMD \"ssh -i $KEY_PATH $usuario@$host$TERMINAL_SUFFIX\" &"
        fi
    done
}

# EJECUCIÓN
detectar_terminal
conectar_servidores
