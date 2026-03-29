#!/usr/bin/env bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="$1"
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
NombreScriptActualizar="Ejecutar_scripts.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/ejecutar_scripts.git" #contiene la direccion de github para actualizar el script
nombre_carpeta_repositorio="ejecutar_scripts" #poner el nombre de la carpeta cuando se clona el repo para poder eliminarla

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [nano]="nano"
        [diff]="diff"
        [sudo]="sudo"
        [ping]="ping"
        [fzf]="fzf"
        [curl]="curl"
        [grep]="grep"
        [jq]="jq"
        [sed]="sed"
        [xdg-user-dir]="xdg-user-dirs"
        [wget]="wget"
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

#comprobar si hay actualizaciones y que lo marque en el menu_info
comprobar_actualizaciones(){
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
        actualizado="SI"
    else
        #hay que actualizar, comprueba y actualiza
        actualizado="Tienes una actualizacion"
    fi
}

comprobar_actualizaciones
menu_info
read p
