#!/usr/bin/env bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="pp"
export DescripcionDelScript="PRUEBA DE MEJORA"
export Correo="scripts@mbbsistemas.es"
export Web="https://repositorio.mbbsistemas.es"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="Sin comprobar"
paqueteria="No detectada"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="principal.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas.git" #contiene la direccion de github para actualizar el script
nombre_carpeta_repositorio="pruebas" #poner el nombre de la carpeta cuando se clona el repo para poder eliminarla

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        #requeridos para poder actualizar
        [git]="git"
        [diff]="diff"
        [sudo]="sudo"
        [ping]="ping"
        [xdg-user-dir]="xdg-user-dirs"
[fzf]="fzf"
        #requeridos para el script en si
        #[fzf]="fzf"
        #[curl]="curl"
        #[grep]="grep"
        #[jq]="jq"
        #[sed]="sed"
        #[wget]="wget"
        #[nano]="nano"
    )
###########################
## FUNCIONES PRINCIPALES ##
###########################
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
echo -e "${rosa}                                    ${azul}   Sistema paqueteria =${borra_colores} $paqueteria"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} ( Correo${rosa} $Correo${borra_colores} ) ( Web${rosa} $Web${borra_colores} )${borra_colores}"
echo ""
}

#comprobar si hay actualizaciones y que lo marque en el menu_info y tambien pregunta si quieres actualizar
comprobar_actualizaciones(){

    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1
    diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1

    if [ $? = 0 ]
    then
        #esta actualizado, solo lo comprueba
        actualizado="SI"
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    else
        #hay que actualizar, comprueba y actualiza
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

#funcion para actualizar el script
actualizar_script(){
    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

    echo ""
    echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
    echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
    cp -r /tmp/comprobar/* $ruta_ejecucion
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${verde} El script se ha actualizado.${amarillo} Es necesario cargarlo de nuevo.${borra_colores}"
    echo ""
    exit
}

#funcion para comprobar el software necesario
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
for comando in "${!requeridos[@]}"; do
        command -v $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                menu_info
                echo -e " ${amarillo}NO se puede ejecutar el script sin los paquetes necesarios ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}$instalar${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
                for elemento in "${requeridos[@]}"; do
                    echo -e "     $elemento"
                done
                echo ""
                echo -e " ${rojo}No se puede ejecutar el script sin todo el software necesario.${borra_colores}"
                echo ""
                exit 1
            else
                echo -e "${amarillo} Se necesita instalar ${borra_colores}$comando${amarillo} para la ejecucion del script${borra_colores}"
                ### check_root
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                $instalar ${requeridos[$comando]} &>/dev/null
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
}

# Función que comprueba si se ejecuta como root
check_root() {
    #clear
    #menu_info
  if [ "$EUID" -ne 0 ]; then
    #echo ""
    #echo -e "${amarillo} Se necesita privilegios de root ingresa la contraseña.${borra_colores}"

    # Pedir contraseña para sudo
    #echo -e ""

    # Validar contraseña mediante sudo -v (verifica sin ejecutar comando)
    if sudo -v; then
      echo ""
      echo -e "${verde} Autenticación correcta. Ejecutando como root...${borra_colores}"; sleep 2
      # Reejecuta el script como root
      #exec sudo "$0" "$@"
    else
      clear
      menu_info
      echo -e "${rojo} Contraseña incorrecta o acceso denegado. Saliendo del script.${borra_colores}"
      echo ""
      echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
      for elemento in "${requeridos[@]}"; do
        echo -e "     $elemento"
      done
      echo ""
      echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
     echo ""; exit
    fi
  fi
}

#funcion de detectar sistema de paquetado para instalar
paqueteria(){
echo ""
echo -e "${azul} Detectando sistema de paquetería...${borra_colores}"
echo ""

if command -v apt >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)${borra_colores}"
    instalar="sudo apt install -y "
    paqueteria="apt"

elif command -v dnf >/dev/null 2>&1; then
    echo -e "${cerde} Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)${borra_colores}"
    instalar="sudo dnf install -y "
    paqueteria="dnf"

elif command -v yum >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: YUM (CentOS, RHEL antiguos)${borra_colores}"
    instalar="sudo yum install -y "
    paqueteria="yum"

elif command -v pacman >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Pacman (Arch Linux, Manjaro)${borra_colores}"
    instalar="sudo pacman -S --noconfirm "
    paqueteria="pacman"

elif command -v zypper >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Zypper (openSUSE)${borra_colores}"
    instalar="sudo zypper install -y "
    paqueteria="zypper"

elif command -v apk >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: APK (Alpine Linux)${borra_colores}"
    instalar="sudo apk add --no-interactive "
    paqueteria="apk"

elif command -v emerge >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: Portage (Gentoo)${borra_colores}"
    instalar="sudo emerge -av "
    paqueteria="emerge"

else
    echo -e "${amarillo} No se pudo detectar un sistema de paquetería conocido.${borra_colores}"
    paqueteria="${rojo}Desconocido${borra_colores}"
fi
#sleep 2
}


#comprobar si se ejecuta en una terminal bash
terminal_bash() {

    shell_actual="$(ps -p $$ -o comm=)"

    if [ "$shell_actual" != "bash" ]; then
        echo -e "${amarillo} Este script ${rojo}NO${amarillo} se está ejecutando en Bash.${borra_colores}"
        echo -e "   Shell detectado: ${rojo}$shell_actual${borra_colores}"
        echo -e "   Puede ocasionar problemas ya que solo está pensado para bash."
        echo -e "   ${rojo}No${borra_colores} se procede con la instalación ni la ejecución."
        echo ""
        echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
        echo ""
        exit 1
    fi
}

conexion(){
#funcion de comprobar conexion a internet
#para que funciones necesita:
#   conexion ainternet
#   la paleta de colores
#   software: ping

if ping -c1 -W1 8.8.8.8 &>/dev/null
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

#logica de inicio
clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    comprobar_actualizaciones
    if [ $actualizado = "SI" ]; then
        terminal_bash
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
        terminal_bash
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="NOOOOO"
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

sleep 2
clear
menu_info
echo "empieza el programa"




