#!/bin/bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="pruebas"
export DescripcionDelScript="esto se esta probando"
export Correo=""
export Web=""
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="popo.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [nano]="nano"
        [diff]="diff"
        [popo]="popo"
        [popo1]="popo1"
        [popo1]="popo1"
        #[which]="which"
    )


#colores
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
echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
echo ""
sleep 1
exit
}

menu_info(){
# muestra el menu de sukigsx
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} $NombreScript"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} $DescripcionDelScript"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo $Correo) (Web $Web)${borra_colores}"
echo ""
}


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
paqueteria
echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
#########software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for comando in "${!requeridos[@]}"; do
        command -v $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                #clear
                #check_root
                echo -e " ${amarillo}NO se puede ejecutar el script sin los paquetes necesarios ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}$instalar${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e " ${rojo}No se puede ejecutar el script sin el software necesario.${borra_colores}"
                echo ""; read p
                echo ""
                exit 1
            else
                echo -e "${amarillo} Se necesita instalar ${borra_colores}$comando${amarillo} para la ejecucion del script${borra_colores}"
                check_root
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                $instalar ${requeridos[$comando]} -y &>/dev/null
                let "contador=contador+1"
                command -v $comando &>/dev/null
                sino=$?
            fi
        done
        echo -e " [${verde}ok${borra_colores}] $comando (${requeridos[$comando]})."
    done

    echo ""
    echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
    software="SI"
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

# Función que comprueba si se ejecuta como root
check_root() {
    #clear
    #menu_info
  if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${amarillo} Se necesita privilegios de root ingresa la contraseña.${borra_colores}"

    # Pedir contraseña para sudo
    echo -e ""

    # Validar contraseña mediante sudo -v (verifica sin ejecutar comando)
    if sudo -v; then
      echo ""
      echo -e "${verde} Autenticación correcta. Reejecutando como root...${borra_colores}"; sleep 2
      # Reejecuta el script como root
      #exec sudo "$0" "$@"
    else
      echo ""
      echo -e "${rojo} Contraseña incorrecta o acceso denegado. Saliendo del script.${borra_colores}"; sleep 3
      echo ""
      echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
     echo ""; exit
    fi
  fi
}

#funcion de detectar sistema de paquetado para instalar
paqueteria(){
echo -e "${azul} Detectando sistema de paquetería...${borra_colores}"
echo ""

if command -v apt >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)${borra_colores}"
    instalar="sudo apt install -y "

elif command -v dnf >/dev/null 2>&1; then
    echo -e "${cerde} Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4

elif command -v yum >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: YUM (CentOS, RHEL antiguos)${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4

elif command -v pacman >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Pacman (Arch Linux, Manjaro)${borra_colores}"
    instalar="sudo pacman -S --noconfirm "

elif command -v zypper >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Zypper (openSUSE)${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4

elif command -v apk >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: APK (Alpine Linux)${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4

elif command -v emerge >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: Portage (Gentoo)${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4

else
    echo -e "${amarillo} No se pudo detectar un sistema de paquetería conocido.${borra_colores}"
    echo -e "${amarillo} Tu sistema NO esta soportado para este script ${borra_colores}"; sleep 4
fi
sleep 2
}

#logica de arranque
#variables de resultado $conexion $software $actualizado
#funciones actualizar_script, conexion, software_necesario

#logica para ejecutar o no ejecutar
#comprobado conexcion
#    si=actualizar_script
#        si=software_necesario
#            si=ejecuta, poner variables a sii todo
#            no=Ya sale el solo desde la funcion
#        no=software_necesario
#            si=ejecuta, variables software="SI", conexion="SI", actualizado="No se ha podiso comprobar actualizacion de script"
#            no=Ya sale solo desde la funcion
#
#    no=software_necesario
#        si=ejecuta, variables software="SI", conexion="NO", actualizado="No se ha podiso comprobar actualizacion de script"
#        no=Ya sale solo desde la funcion


clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    actualizar_script
    if [ $actualizado = "SI" ]; then
        software_necesario
        if [ "$software" = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="SI"
            #bash $ruta_ejecucion/ #PON LA RUTA
        else
            echo ""
        fi
    else
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="NO"
            export actualizado="No se ha podido comprobar la actualizacion del script"
            #bash $ruta_ejecucion/ #PON LA RUTA
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
        #bash $ruta_ejecucion/ #PON LA RUTA
    else
        echo ""
    fi
fi

clear
menu_info
echo "continuo ejecutando"
