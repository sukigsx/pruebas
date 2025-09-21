#!/bin/bash

#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"

rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores

#toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
clear
echo ""
echo -e " ${verde}- Gracias por utilizar mi script -${borra_colores}"
echo ""
exit
}


# Asegúrate de tener fzf y un emulador de terminal instalados.
# Puedes instalarlos con el gestor de paquetes de tu sistema.

# Directorio de claves SSH. Se recomienda que sea una ruta absoluta.
SSH_DIR="/home/$(whoami)/ssh_clientes"
KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"

# Asegura que el directorio de claves exista
mkdir -p "$SSH_DIR"

# Detecta el emulador de terminal disponible
function find_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        echo "gnome-terminal"
    elif command -v konsole &> /dev/null; then
        echo "konsole"
    elif command -v xfce4-terminal &> /dev/null; then
        echo "xfce4-terminal"
    elif command -v xterm &> /dev/null; then
        echo "xterm"
    elif command -v terminator &> /dev/null; then
        echo "terminator"
    else
        echo "none"
    fi
}

TERMINAL=$(find_terminal)

# Función para ejecutar el comando en la terminal adecuada
function run_in_terminal() {
    local title="$1"
    local command="$2"

    case "$TERMINAL" in
        "gnome-terminal")
            gnome-terminal --title="$title" -- bash -c "$command; exec bash" &
            ;;
        "konsole")
            konsole --new-tab -p tabtitle="$title" -e bash -c "$command; exec bash" &
            ;;
        "xfce4-terminal")
            xfce4-terminal --title="$title" -H -e "bash -c \"$command; exec bash\"" &
            ;;
        "xterm")
            xterm -T "$title" -e "bash -c \"$command; exec bash\"" &
            ;;
        "terminator")
            terminator -e "bash -c \"$command; exec bash\"" &
            ;;
        *)
            echo "Error: No se encontró un emulador de terminal compatible."
            return 1
            ;;
    esac
}

# Función para agregar un nuevo cliente
add_client() {
    clear
    echo ""
    read -p "Ingresa un nombre para el servidor ssh: " DISPLAY_NAME
    read -p "Ingresa el nombre de usuario del servidor $DISPLAY_NAME: " USERNAME
    read -p "Ingresa la dirección IP o el nombre de host del servidor $DISPLAY_NAME: " HOST

    # --- VERIFICACIÓN DE CONECTIVIDAD ---
    echo ""
    echo -e "${azul}Verificando la accesibilidad del host $HOST...${borra_colores}"
    if ! check_host_availability "$HOST"; then
        echo ""
        echo -e "${rojo}¡Error! El host $HOST no es accesible. No se puede continuar.${borra_colores}"
        sleep 3
        return
    fi
    # --- FIN DE LA VERIFICACIÓN ---

    # Crea un nombre de directorio único combinando usuario y host
    CLIENT_DIR="$SSH_DIR/${USERNAME}_${HOST//./-}"
    mkdir -p "$CLIENT_DIR"

    echo ""; echo -e "${azul}Generando par de claves SSH para $USERNAME en $HOST...${borra_colores}";
    ssh-keygen -t rsa -b 4096 -f "$CLIENT_DIR/id_rsa" -N ""

    echo ""; echo -e "${azul}Copiando la clave pública al servidor...${borra_colores}"
    ssh-copy-id -i "$CLIENT_DIR/id_rsa.pub" "$USERNAME@$HOST"

    # Ahora guardamos el nombre a mostrar, el usuario y el host
    echo "$DISPLAY_NAME,$USERNAME,$HOST" >> "$SSH_DIR/clientes.txt"
    echo ""; echo -e "${verde}¡Cliente '$DISPLAY_NAME' agregado exitosamente!${borra_colores}"; sleep 2
}

# Función para conectarse a uno o varios clientes usando fzf
connect_client() {
    clear
    echo ""
    if [ ! -f "$SSH_DIR/clientes.txt" ]; then
        clear
        echo ""
        echo -e "${rojo}No hay servidores registrados.${borra_colores}"; sleep 3
        return
    fi

    # Muestra el nombre a mostrar en el menú
    CLIENTS=$(cat "$SSH_DIR/clientes.txt" | awk -F',' '{print $1" ("$2"@" $3")"}' | fzf -m --layout=reverse --prompt="Selecciona uno o más servidores para conectar (Tab para seleccionar, Enter para confirmar): ")

    if [[ -n "$CLIENTS" ]]; then
        # Extrae la información del formato 'Nombre (usuario@host)'
        echo "$CLIENTS" | while read -r CLIENT; do
            USERNAME=$(echo "$CLIENT" | sed -E 's/.* \((.*)@.*/\1/')
            HOST=$(echo "$CLIENT" | sed -E 's/.*@(.*)\)/\1/')
            DISPLAY_NAME=$(echo "$CLIENT" | sed -E 's/ (.*)//')

            # Crea un nombre de directorio único para la conexión
            CLIENT_DIR_UNIQUE="${USERNAME}_${HOST//./-}"

            echo ""
            echo -e "${azul}Comprobando la disponibilidad de '$DISPLAY_NAME' ($USERNAME@$HOST)...${borra_colores}"

            # --- Lógica para comprobar la conectividad ---
            # Se usa 'ssh' con un comando de salida rápida, sin pedir contraseña y con un timeout.
            # > /dev/null 2>&1 redirecciona la salida estándar y de error a la nada para no ensuciar la terminal.
            if ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$SSH_DIR/$CLIENT_DIR_UNIQUE/id_rsa" "$USERNAME@$HOST" exit > /dev/null 2>&1; then
                echo -e "${verde}¡Conexión disponible! Iniciando sesión...${borra_colores}"
                # Inicia la conexión en una nueva ventana de terminal.
                run_in_terminal "$DISPLAY_NAME ($USERNAME@$HOST)" "ssh -i \"$SSH_DIR/$CLIENT_DIR_UNIQUE/id_rsa\" \"$USERNAME@$HOST\""
            else
                echo -e "${rojo}❌ Error: No se pudo conectar a '$DISPLAY_NAME' ($USERNAME@$HOST).\n El servidor no está disponible o hay un problema de red.${borra_colores}"
                sleep 2
            fi
            # -----------------------------------------------

        done

    else
        echo -e "${rojo}Selección cancelada.${borra_colores}"
    fi
    echo ""
    echo -e "${verde}Conexiones iniciadas. Verifica las nuevas ventanas de terminal.${borra_colores}"; sleep 5
}

# Función para revocar el acceso a un cliente
revoke_access() {
    clear
    echo ""
    if [ ! -f "$SSH_DIR/clientes.txt" ]; then
        echo -e "${rojo}No hay clientes registrados.${borra_colores}"
        return
    fi

    CLIENT_REVOKE=$(cat "$SSH_DIR/clientes.txt" | awk -F',' '{print $1" ("$2"@" $3")"}' | fzf --layout=reverse --prompt="Selecciona un servidor para revocar el acceso: ")

    HOST=$(echo "$CLIENT_REVOKE" | sed -E 's/.*@(.*)\)/\1/')


    if [[ -n "$CLIENT_REVOKE" ]]; then
        # Extrae la información del formato 'Nombre (usuario@host)'
        USERNAME=$(echo "$CLIENT_REVOKE" | sed -E 's/.* \((.*)@.*/\1/')
        HOST=$(echo "$CLIENT_REVOKE" | sed -E 's/.*@(.*)\)/\1/')

        # Crea un nombre de directorio único para la revocación
        CLIENT_DIR_UNIQUE="${USERNAME}_${HOST//./-}"

        echo -e "${amarillo}Revocando acceso para $USERNAME@$HOST...${borra_colores}"; sleep 2

        #ssh -t "$USERNAME@$HOST" "sudo sed -i '/$USERNAME/d' ~/.ssh/authorized_keys"
        USUARIODOMINIO=$(echo "$(whoami)@$(hostname)")
        ssh -t "$USERNAME@$HOST" "sudo sed -i '/$USUARIODOMINIO/d' ~/.ssh/authorized_keys"

        # Elimina la línea completa que contiene el nombre de mostrar, usuario y host
        sed -i "/$USERNAME,$HOST/d" "$SSH_DIR/clientes.txt"

        rm -rf "$SSH_DIR/$CLIENT_DIR_UNIQUE"

        ssh-keygen -R "$HOST"

        echo -e "${verde}Acceso de $USERNAME revocado y archivos locales eliminados.${borra_colores}"; sleep 2
    else
        echo -e "${rojo}Selección cancelada.${borra_colores}"
    fi
    sleep 3
}

# Bucle principal del menú con fzf y preview
while true; do
    clear
    echo ""
    if [ -s "$SSH_DIR/clientes.txt" ]; then
        OPTIONS_LIST="1) Agregar nuevo servidor SSH\n2) Conectarse a un servidor existente\n3) Revocar acceso a un servidor\n5) Salir"
    else
        OPTIONS_LIST="1) Agregar nuevo servidor SSH\n5) Salir"
    fi

    OPTION=$(printf "$OPTIONS_LIST" | fzf \
        --layout=reverse \
        --prompt="Menú de Gestión de Servidores SSH: " \
        --preview-window=right:50% \
        --preview="case {} in
            *'Agregar nuevo servidor SSH'*)
                echo 'Genera un par de claves y configura el acceso SSH para un nuevo servidor.' | fmt -w $(tput cols)
                ;;
            *'Conectarse a un servidor existente'*)
                echo 'Conecta a uno o varios servidores previamente configurados en terminales separadas.' | fmt -w $(tput cols)
                ;;
            *'Revocar acceso a un servidor'*)
                echo 'Elimina la clave pública del servidor y los archivos locales del cliente, revocando el acceso.' | fmt -w $(tput cols)
                ;;
            *'Salir'*)
                echo 'Termina el script y regresa a la terminal.' | fmt -w $(tput cols)
                ;;
        esac")

    case "$OPTION" in
        "1) Agregar nuevo servidor SSH")
            add_client
            ;;
        "2) Conectarse a un servidor existente")
            if [ "$TERMINAL" == "none" ]; then
                echo ""
                echo -e "${rojo}No se encontró un emulador de terminal compatible para abrir las conexiones.${borra_colores}"
                sleep 5
            else
                connect_client
            fi
            ;;
        "3) Revocar acceso a un servidor")
            revoke_access
            ;;
        "4) Revocar todos los accesos")
            revoke_all_clients
            ;;
        "5) Salir")
            ctrl_c
            ;;
        *)
            ;;
    esac
done
