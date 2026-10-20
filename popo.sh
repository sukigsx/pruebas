#!/usr/bin/env bash

# VARIABLES PRINCIPALES
# Con export son las variables necesarias para exportar a los siguientes scripts
export NombreScript="Control de aplicaciones Linux"
export DescripcionDelScript="Control de ejecución de aplicaciones en tu sistema Linux"
export Correo="scripts@mbbsistemas.es"
export Web="https://mbbsistemas.es"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="Sin comprobar"
paqueteria="No detectada"

# VARIABLE QUE RECOGEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") # Ruta de ejecución del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP)        # Ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZACION CON GITHUB
NombreScriptActualizar="ssh-manager.sh" # Contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com" # Contiene la direccion de github para actualizar el script
nombre_carpeta_repositorio="ssh-manager" # Nombre de la carpeta cuando se clona el repo para poder eliminarla

# VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con los paquetes correspondientes.
# Formato si cambian: [comando]="paquete_debian / paquete_redhat / paquete_arch"
# Formato si son iguales: [comando]="paquete_unico"
declare -A requeridos
requeridos=(
    # Requeridos para poder actualizar
    [git]="git"
    [diff]="diff"
    [sudo]="sudo"
    [ping]="iputils-ping/iputils/iputils"
    [curl]="curl"
    [jq]="jq"
    [nc]="netcat-openbsd/nc/gnu-netcat"
    [sed]="sed"
    [ssh-copy-id]="openssh-client/openssh-clients/openssh"
    [ssh-keygen]="openssh-client/openssh-clients/openssh"
    [xdg-user-dir]="xdg-user-dirs"

    # Requeridos para el script en si
    [fzf]="fzf"
    [awk]="gawk/gawk/gawk"
)

###########################
## FUNCIONES PRINCIPALES ##
###########################
# Colores
rojo="\e[0;31m\033[1m"
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m"

# Toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
    clear
    echo ""
    echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
    echo ""
    sleep 1
    exit
}

menu_info(){
    # Muestra el menu de sukigsx
    echo ""
    echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} $NombreScript"
    echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} $DescripcionDelScript"
    echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
    echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
    echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
    echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
    echo -e "${rosa}                                    ${azul}   Sistema paqueteria =${borra_colores} $paqueteria"
    echo ""
    echo -e "${azul} Contacto:${borra_colores} ( Correo${rosa} $Correo${borra_colores} ) ( Web${rosa} $Web${borra_colores} )${borra_colores}"
    echo ""
}

# Comprobar si hay actualizaciones y que lo marque en el menu_info y tambien pregunta si quieres actualizar
comprobar_actualizaciones(){
    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1
    diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1

    if [ $? = 0 ]
    then
        # Esta actualizado, solo lo comprueba
        actualizado="SI"
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    else
        # Hay que actualizar, comprueba y actualiza
        echo ""
        echo -e "${amarillo} Existe una actualizacion del script${borra_colores}"
        read -p " Quieres actualizar ? (S/n): " sino
        if [[ $sino == [sS] ]]; then
            actualizar_script
        else
            actualizado="NO"
        fi
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    fi
}

# Funcion para actualizar el script
actualizar_script(){
    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

    cp -r /tmp/comprobar/* $ruta_ejecucion
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} Sera necesario ejecutarlo de nuevo.${borra_colores}"

    printf " Actualizando... "
    for i in {1..20}; do
        printf "#"
        sleep 0.1
    done
    printf " [ \e[32mOK\e[0m ]\n"

    echo ""
    sleep 1
    exit
}

# Funcion de detectar sistema de paquetado para instalar
paqueteria(){
    echo ""
    echo -e "${azul} Detectando sistema de paquetería...${borra_colores}"
    echo ""

    if command -v apt >/dev/null 2>&1; then
        echo -e "${verde} Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)${borra_colores}"
        instalar="sudo apt install -y"
        paqueteria="apt"
        idx_distro=1

    elif command -v dnf >/dev/null 2>&1; then
        echo -e "${verde} Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)${borra_colores}"
        instalar="sudo dnf install -y"
        paqueteria="dnf"
        idx_distro=2

    elif command -v pacman >/dev/null 2>&1; then
        echo -e "${verde} Sistema de paquetería detectado: PACMAN (Arch Linux, Manjaro)${borra_colores}"
        instalar="sudo pacman -S --noconfirm"
        paqueteria="pacman"
        idx_distro=3

    else
        echo -e "${rojo} Sistema de paquetería no soportado automáticamente.${borra_colores}"
        paqueteria="No detectada"
        exit 1
    fi
}

# Funcion para comprobar el software necesario
software_necesario(){
    # Detectamos la paqueteria y establecemos el idx_distro antes de evaluar la matriz
    paqueteria

    echo ""
    echo -e "${azul} Comprobando el software necesario.${borra_colores}"
    echo ""

    for comando in "${!requeridos[@]}"; do
        # Evaluamos si el valor de la matriz contiene variantes por barra '/'
        if [[ "${requeridos[$comando]}" == *"/"* ]]; then
            paquete_real=$(echo "${requeridos[$comando]}" | cut -d'/' -f$idx_distro)
        else
            paquete_real="${requeridos[$comando]}"
        fi

        command -v "$comando" &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                menu_info
                echo -e " ${amarillo}NO se puede ejecutar el script sin los paquetes necesarios ${rojo}$paquete_real${amarillo}.${borra_colores}"
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}$paquete_real${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}$instalar $paquete_real${amarillo})${borra_colores}"
                echo ""
                echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"

                # Listar los nombres traducidos de los paquetes para comodidad del usuario
                for cmd_lista in "${!requeridos[@]}"; do
                    if [[ "${requeridos[$cmd_lista]}" == *"/"* ]]; then
                        echo -e "     $(echo "${requeridos[$cmd_lista]}" | cut -d'/' -f$idx_distro)"
                    else
                        echo -e "     ${requeridos[$cmd_lista]}"
                    fi
                done

                echo ""
                echo -e " ${rojo}No se puede ejecutar el script sin todo el software necesario.${borra_colores}"
                echo ""
                exit 1
            else
                echo -e "${amarillo} Se necesita instalar ${borra_colores}$comando${amarillo} para la ejecucion del script${borra_colores}"
                echo " Instalando $paquete_real. Intento $contador/3."

                # Ejecución de la instalación silenciosa
                $instalar "$paquete_real" &>/dev/null

                let "contador=contador+1"
                command -v "$comando" &>/dev/null
                sino=$?
            fi
        done
        echo -e " [${verde}ok${borra_colores}] $comando ($paquete_real)."
    done

    echo ""
    echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
    software="SI"
}

# Función que comprueba si se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        if sudo -v; then
            echo ""
            echo -e "${verde} Autenticación correcta. Ejecutando...${borra_colores}"; sleep 2
        else
            clear
            menu_info
            echo -e "${rojo} Contraseña incorrecta o acceso denegado. Saliendo del script.${borra_colores}"
            echo ""
            echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
            echo ""; exit
        fi
    fi
}

# ==========================================
# FLUJO DE EJECUCIÓN INICIAL DEL SCRIPT
# ==========================================
clear

# 1. Ejecutar las comprobaciones automáticas iniciales
software_necesario

# 2. Refrescar la pantalla con la información recopilada en limpio
clear
menu_info

# Aquí puedes continuar escribiendo el cuerpo de tu script...
echo -e "${verde}¡Entorno verificado correctamente! Listo para procesar la lógica de control.${borra_colores}"
