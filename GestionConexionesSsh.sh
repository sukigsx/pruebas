#!/bin/bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="GestionConexionesSsh"
export DescripcionDelScript="Gestiona varias conexiones SSH"
export Correo="mi correo@popo.es"
export Web="https://mipweb.com"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="GestionConexionesSsh.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
software="ping which git diff ssh touch sed sort cut grep fzf" #contiene el software necesario separado por espacios

actualizar_script(){
# actualizar el script
#para que esta funcion funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: git diff

git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1


if [ $? = 0 ]
then
    #esta actualizado, solo lo comprueba
    echo ""
    echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
    echo ""
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    actualizado="SI"
    sleep 2
else
    #hay que actualizar, comprueba y actualiza
    echo ""
    echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
    echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
    sleep 3
    cp -r /tmp/comprobar/* $ruta_ejecucion
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} El script se ha actualizado, es necesario cargarlo de nuevo.${borra_colores}"
    echo ""
    sleep 2
    exit
fi
}


software_necesario(){
#funcion software necesario
#para que funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: which

echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
#########software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for paquete in $software
do
which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa llamado programa
sino=$? #recojemos el 0 o 1 del resultado de which
contador="1" #ponemos la variable contador a 1
    while [ $sino -gt 0 ] #entra en el bicle si variable programa es 0, no lo ha encontrado which
    do
        if [ $contador = "4" ] || [ $conexion = "no" ] 2>/dev/null 1>/dev/null 0>/dev/null #si el contador es 4 entre en then y sino en else
        then #si entra en then es porque el contador es igual a 4 y no ha podido instalar o no hay conexion a internet
            clear
            echo ""
            echo -e " ${amarillo}NO se ha podido instalar ${rojo}$paquete${amarillo}.${borra_colores}"
            echo -e " ${amarillo}Intentelo usted con la orden: (${borra_colores}sudo apt install $paquete ${amarillo})${borra_colores}"
            echo -e ""
            echo -e " ${rojo}No se puede ejecutar el script sin el software necesario.${borra_colores}"
            echo ""; read p
            echo ""
            exit
        else #intenta instalar
            echo " Instalando $paquete. Intento $contador/3."
            sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
            let "contador=contador+1" #incrementa la variable contador en 1
            which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
            sino=$? ##recojemos el 0 o 1 del resultado de which
        fi
    done
echo -e " [${verde}ok${borra_colores}] $paquete."
software="SI"
done
echo ""
echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
sleep 2
}


conexion(){
#funcion de comprobar conexion a internet
#para que funciones necesita:
#   conexion ainternet
#   la paleta de colores
#   software: ping

if ping -c1 google.com &>/dev/null
then
    conexion="SI"
    echo ""
    echo -e " Conexion a internet = ${verde}SI${borra_colores}"
else
    conexion="NO"
    echo ""
    echo -e " Conexion a internet = ${rojo}NO${borra_colores}"
fi
}






#toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
clear
menu_info
echo -e "${verde} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
sleep 1
exit
}

#colores
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores


# FUNCIONES

menu_info(){
# muestra el menu de sukigsx
clear
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} ($NombreScript)"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} ($DescripcionDelScript)"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo $Correo) (Web $Web)${borra_colores}"
echo ""
}

# Archivo donde se guarda la lista de servidores
SERVER_LIST="$HOME/.ssh_server_list"

# Crear archivo si no existe
touch "$SERVER_LIST"

# Detectar terminal disponible
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
        TERMINAL_CMD=""
    fi
}

# Función para mostrar el menú principal
mostrar_menu() {
    menu_info
    listar_servidores
    echo -e "${azul} Menu de $NombreScript ${borra_colores}"
    echo ""
    echo -e "    ${azul}1)${borra_colores} Conectar a un servidor ssh"
    echo -e "    ${azul}2)${borra_colores} Añadir un servidor ssh"
    echo -e "    ${azul}3)${borra_colores} Editar un servidor ssh"
    echo -e "    ${azul}4)${borra_colores} Eliminar un servidor"
    echo -e "    ${azul}5)${borra_colores} Realizar backup de configuración"
    echo -e "    ${azul}6)${borra_colores} Restaurar backup de configuración"
    echo -e "    ${azul}7)${borra_colores} Crear alias de acceso rapido a tus servidores"
    echo -e "   ${azul}99)${borra_colores} Salir"
}

# Función para listar los servidores
listar_servidores() {
    hay_servidores || return
    echo ""
    echo -e "${verde} Lista de servidores:${borra_colores}"
    nl -w2 -s'. ' "$SERVER_LIST"
    echo ""
}

# Verifica si hay servidores
hay_servidores() {
    if [ ! -s "$SERVER_LIST" ]; then
        echo -e "${verde} Lista de servidores:${borra_colores}"
        echo -e " ⚠️  ${amarillo}No hay servidores en la lista. Agrega al menos uno primero.${borra_colores}"
        echo ""
        return 1
    fi
    return 0
}

# verifica si hay servidores para las opciones del menu
hay_servidores_menu() {
    if [ ! -s "$SERVER_LIST" ]; then
        echo ""
        echo -e " ⚠️  ${amarillo}No hay servidores en la lista. Agrega al menos uno primero.${borra_colores}"
        echo ""; sleep 2
        return 1
    fi
    return 0
}

# Función para conectar a servidores seleccionados
conectar_servidores() {
    hay_servidores_menu || return
    listar_servidores

    # Selección de servidores con fzf
    mapfile -t seleccionados < <(nl -w2 -s': ' "$SERVER_LIST" | fzf --multi --prompt="Seleccione servidores: (Puedes seleccionar varios utilizando Tab)" --layout=reverse --ansi)

    if [ "${#seleccionados[@]}" -eq 0 ]; then
        echo -e "${rojo} No se ha seleccionado ningun servidor.${borra_colores}"; sleep 2
        return
    fi

    # Extraer solo los números de línea seleccionados
    servidores=()
    for linea in "${seleccionados[@]}"; do
        numero=$(echo "$linea" | cut -d':' -f1 | tr -d ' ')
        servidores+=("$numero")
    done

    # Exportar las variables de entorno del agente SSH
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID

    for numero in "${servidores[@]}"; do
        servidor=$(sed -n "${numero}p" "$SERVER_LIST")

        if [ -z "$servidor" ]; then
            echo -e "${rojo} Servidor seleccionado:${borra_colores} $numero ${rojo}es invalido${borra_colores}"; sleep 2
            continue
        fi

        nombre=$(echo "$servidor" | cut -d',' -f1)
        usuario=$(echo "$servidor" | cut -d',' -f2)
        host=$(echo "$servidor" | cut -d',' -f3)

        echo -e " Abriendo nueva terminal para conectar a $nombre ($usuario@$host)..."

        # Generar una clave única para cada servidor
        KEY_PATH="$HOME/.ssh/id_rsa_$nombre"

        # Verificar si ya hay clave copiada
        if ssh -i "$KEY_PATH" -o BatchMode=yes -o ConnectTimeout=5 "$usuario@$host" 'echo OK' 2>/dev/null | grep -q OK; then
            eval "$TERMINAL_CMD \"ssh -i $KEY_PATH $usuario@$host$TERMINAL_SUFFIX\" &"
        else
            echo "Copiando clave SSH al servidor $nombre..."

            # Generar una nueva clave SSH para el servidor si no existe
            if [ ! -f "$KEY_PATH" ]; then
                ssh-keygen -t rsa -b 4096 -N "" -f "$KEY_PATH" <<< y >/dev/null 2>&1
            fi

            ssh-copy-id -i "$KEY_PATH.pub" "$usuario@$host"
            eval "$TERMINAL_CMD \"ssh -i $KEY_PATH $usuario@$host$TERMINAL_SUFFIX\" &"
        fi
    done
}


# Función para agregar un servidor
agregar_servidor() {
    echo ""
    read -p " Dime un nombre descriptivo para la conexion -> " nombre
    read -p " Usuario SSH ->  " usuario
    read -p " Host/IP -> " host
    echo ""
    echo "$nombre,$usuario,$host" >> "$SERVER_LIST"
    echo -e "${verde} Servidor agregado.${borra_colores}"; sleep 1
}

# Función para editar un servidor
editar_servidor() {
    hay_servidores_menu || return
    listar_servidores
    echo -ne "${azul} Número del servidor a editar (atras = cualquier tecla) ->${borra_colores} "
    read numero

    if [ -z "$numero" ]; then
        echo ""
        echo -e "${rojo} No se ha seleccionado ningun servidor.${borra_colores}"; sleep 2
        return
    fi

    linea=$(sed -n "${numero}p" "$SERVER_LIST")

    if [ -z "$linea" ]; then
        echo ""
        echo -e "${rojo} Servidor no valido.${borra_colores}"; sleep 2
        return
    fi
    echo ""
    echo -e "${azul} Editar/Modificar:${borra_colores} $linea"
    echo -n " Nuevo nombre (ENTER para mantener): "
    read nuevo_nombre
    echo -n " Nuevo usuario (ENTER para mantener): "
    read nuevo_usuario
    echo -n " Nuevo host (ENTER para mantener): "
    read nuevo_host

    nombre=$(echo "$linea" | cut -d',' -f1)
    usuario=$(echo "$linea" | cut -d',' -f2)
    host=$(echo "$linea" | cut -d',' -f3)

    nuevo_nombre=${nuevo_nombre:-$nombre}
    nuevo_usuario=${nuevo_usuario:-$usuario}
    nuevo_host=${nuevo_host:-$host}

    sed -i "${numero}s/.*/$nuevo_nombre,$nuevo_usuario,$nuevo_host/" "$SERVER_LIST"
    echo -e "${verde} Servidor actualizado.${borra_colores}"
}

# Función para eliminar servidores
eliminar_servidores() {
    hay_servidores_menu || return
    listar_servidores
    echo -ne "${azul} Seleccione los números de los servidores a eliminar (separados por espacios) -> ${borra_colores}"
    read -a numeros_a_eliminar

    if [ -z "$numeros_a_eliminar" ]; then
        echo ""
        echo -e "${rojo} No se ha seleccionado ningun servidor.${borra_colores}"; sleep 2
        return
    fi

    # Ordenar los números de forma descendente para evitar problemas al eliminar varias líneas
    IFS=$'\n' sorted=($(for i in "${numeros_a_eliminar[@]}"; do echo "$i"; done | sort -nr))
    unset IFS

    # Eliminar las líneas correspondientes a los números seleccionados
    for numero in "${sorted[@]}"; do
        linea=$(sed -n "${numero}p" "$SERVER_LIST")

        if [ -z "$linea" ]; then
            echo ""
            echo -e "${rojo} Servidor seleccionado:${borra_colores} $numero ${rojo}no es valido.${borra_colores}"; sleep 2
            continue
        fi

        # Eliminar las claves públicas y privadas
        nombre=$(echo "$linea" | cut -d',' -f1)
        usuario=$(echo "$linea" | cut -d',' -f2)
        host=$(echo "$linea" | cut -d',' -f3)

        rm -f "$HOME/.ssh/id_rsa_$nombre" "$HOME/.ssh/id_rsa_$nombre.pub"
        sed -i "${numero}d" "$SERVER_LIST"
        echo -e "${verde} Servidor${borra_colores} $nombre ${verde}eliminado y las claves SSH asociadas han sido borradas.${borra_colores}"
    done
    sleep 2
}

# Función para realizar un backup
backup_config() {
    echo ""
    echo -n " ¿Dónde quieres guardar el archivo de backup? (ruta y nombre del archivo) -> "
    read destino
    cp "$SERVER_LIST" "$destino"
    echo -e "${verde} Backup realizado correctamente en${borra_colores} $destino"; sleep 2
}

# Función para restaurar desde un backup
restaurar_config() {
    echo ""
    echo -n " ¿Dónde está el archivo de backup que quieres restaurar? (ruta y nombre del archivo) -> "
    read origen
    if [ ! -f "$origen" ]; then
        echo -e "${rojo} El archivo de backup no existe.${borra_colores}"; sleep 2
        return
    fi
    cp "$origen" "$SERVER_LIST"
    echo -e "${verde} Backup restaurado correctamente desde${borra_colores} $origen"; sleep 2
}

crear_alias(){
    hay_servidores_menu || return
    alias=$(find $HOME -type f -name "crear_alias")
    clear
    echo ""
    echo -e "${azul} -- Crear alias de conexion a servidores ssh --${borra_colores}"
    echo -e ""
    echo -e "${azul}  1)${borra_colores}  Puedes instalar mi script de creacion de alias que"
    echo -e "      lo puedes encontrar en mi github."
    echo -e "      Lo instalas le das un nombre de alias ej. sshon"
    echo -e "      y le pasas este comando $alias"
    echo -e ""
    echo -e "${azul}  2)${borra_colores}  Que lo ponga automaticamente este script."
    echo -e "      Creara una linea en tu -bashrc como la siguiente"
    echo -e "      (alias sshon='bash $alias')"
    echo -e ""
    echo -e "${azul} 99)${borra_colores}  No hacer nada y regresar."
    echo -e ""
    read -p " ¿ Que forma eliges la 1 o la 2 ? -> " opcion_alias
    case $opcion_alias in
        1)  echo ""
            echo -e "${verde} Direccion web de repositorios de sukigsx:"
            echo -e " https://repositorio.mbbsistemas.es/${borra_colores}"; read p ;;

        2)  LINEA="alias sshon='bash /home/sukigsx/scripts/crear_alias'"
            ARCHIVO="$HOME/.bashrc"

            if grep -Fxq "$LINEA" "$ARCHIVO"; then
                echo ""
                echo -e "${verde} Listo, reinicia tu terminal para que tenga efecto los cambios.${borra_colores}"; sleep 2
            else
                echo "alias sshon='bash $(find $HOME -type f -name "crear_alias")'" >> $HOME/.bashrc
                echo ""
                echo -e "${verde} Listo, reinicia tu terminal para que tenga efecto los cambios.${borra_colores}"; sleep 2
            fi ;;

        99) return ;;

        *) echo ""; echo -e "${amarillo} Opción no valida.${borra_colores}"; sleep 2 ;;
    esac
}

principal(){
# Detectar la terminal disponible antes de iniciar el menú
detectar_terminal

# Loop principal del menú
while true; do
    mostrar_menu
    echo ""
    echo -ne "${azul} Seleccione una opción:${borra_colores} "
    read opcion
    case $opcion in
        1) conectar_servidores ;;
        2) agregar_servidor ;;
        3) editar_servidor ;;
        4) eliminar_servidores ;;
        5) backup_config ;;
        6) restaurar_config ;;
        7) crear_alias ;;
        99) ctrl_c ;;
        *) echo ""; echo -e "${amarillo} Opción no valida.${borra_colores}"; sleep 2 ;;
    esac
    echo
done
}


clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    actualizar_script
    if [ $actualizado = "SI" ]; then
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="SI"
            principal
        else
            echo ""
        fi
    else
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="NO"
            export actualizado="No se ha podido comprobar la actualizacion del script"
            principal
        else
            echo ""
        fi
    fi
else
    software_necesario
    if [ $software = "SI" ]; then
        export software="SI"
        export conexion="NO"
        export actualizado="No se ha podido comprobar la actualizacion del script"
        principal
    else
        echo ""
    fi
fi
