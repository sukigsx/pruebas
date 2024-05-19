#!/bin/bash

### FUNCIONES
#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"echo -e "${azul}  7)${borra_colores} TeamViewer               Control remoto de pc's, tablets y moviles."
borra_colores="\033[0m\e[0m" #borra colores

menu_info(){
#muestra el menu de sukigsx
clear
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} (Instalacion de software)"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} (Software de instalacion basado en Debian)"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo $correo_sukigsx) (Web $web_sukigsx)${borra_colores}"
}


actualizar_script(){
#actualizar el script
#para que esta funcion funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: git diff xdotool
archivo_local="InstalacionDeSoftware.sh" # Nombre del archivo local
ruta_repositorio="https://github.com/sukigsx/instalar_software.git" #ruta del repositorio para actualizar y clonar con git clone

# Obtener la ruta del script
descarga=$(dirname "$(readlink -f "$0")")
git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


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
    cp -r /tmp/comprobar/* $descarga
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
#   software: which/tmp/software
echo ""
echo -e " Comprobando el software necesario."
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
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

#se conficgura el script
configuracion(){
#borra y crea la carpeta y el fichero de configuracion
rm -r $ruta_ejecucion/ComprobarServiciosServidor
mkdir $ruta_ejecucion/ComprobarServiciosServidor

#añade el array con los servicio en el bule while
echo '# Define un array con las IP:puertos y los nombres de servicio correspondientes' >> $ruta_ejecucion/ComprobarServiciosServidor/config
echo 'configurado="si"' >> $ruta_ejecucion/ComprobarServiciosServidor/config
echo 'declare -A servicios=(' >> $ruta_ejecucion/ComprobarServiciosServidor/config

    echo ""
    echo -e " El script NO esta configurado."
    echo -e " Se te pedira el servicio a comprobar y un nombre para el servico separado por un espacio."
    echo -e "   servicio, (192.168.1.100:5000) Es la direccion del servidor con su puerto."
    echo -e "   nombre, )portainer)"
    echo -e "   linea completa, (192.168.1.100:9000 portainer)"
    echo -e ""
    for (( ; ; )); do
    read -p " Dime servicio a comprobar (ej. 192.168.1.100:9000 portainer) -> " servicio nombre_servicio
    if [ "$servicio" = "s" ]; then
        break
    fi
    echo "  [$servicio]=\"$nombre_servicio\"" >> $ruta_ejecucion/ComprobarServiciosServidor/config >> $ruta_ejecucion/ComprobarServiciosServidor/config
    done
echo ')' >> $ruta_ejecucion/ComprobarServiciosServidor/config
# ["192.168.1.116:9000"]="Portainer"
}

#se comprueba que este configurado
comprobar_configuracion(){
echo ""
if [ -f $ruta_ejecucion/ComprobarServiciosServidor/config ]
then
    source $ruta_ejecucion/ComprobarServiciosServidor/config
    if [ "$configurado" = "si" ]
    then
        echo "existe el fichero la carpeta y esta configurado"
        break
    else
        configuracion
    fi
else
    configuracion
fi
}
### FIN DE FUNCIONES


ruta_ejecucion=$(dirname "$(readlink -f "$0")")
export version="1.00"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"
correo_sukigsx="scripts@mbbsistemas.com"
web_sukigsx="https://repositorio.mbbsistemas.es"

menu_info
#comprobar_configuracion
if [ -f $ruta_ejecucion/ComprobarServiciosServidor/config ]
then
    source $ruta_ejecucion/ComprobarServiciosServidor/config
    if [ "$configurado" = "si" ]
    then
        echo "existe el fichero la carpeta y esta configurado"
        break
    else
        configuracion
    fi
else
    configuracion
fi
echo "continuamos....."
