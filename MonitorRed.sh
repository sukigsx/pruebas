#!/bin/bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="MonitorRed"
export DescripcionDelScript="Comprobar Dominios, Ips y Servicios activos en tu red "
export Correo="scripts@mbbsistemas.es"
export Web="https://repositorio.mbbsistemas.es"
export version="1.aaaaaaaaaaaaaaaaaaaaaaaaaaa"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="MonitorRed.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas.git" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
software="ping which git diff tail sed figlet curl wmctrl" #contiene el software necesario separado por espacios


#colores
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores

# FUNCIONES

#toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
clear
echo ""
echo -e "${azul} Gracias ${rosa}$(whoami)${azul}. Por utilizar mi script.${borra_colores}"
echo ""
exit
}

menu_principal(){
# muestra el menu de sukigsx
clear
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script ( ${borra_colores}$NombreScript${azul} )${borra_colores}"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion ( ${borra_colores}$DescripcionDelScript${azul})${borra_colores}"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto: ( ${borra_colores}Correo $Correo${azul} ) ( ${borra_colores}Web $Web${azul} )${borra_colores}"
echo ""
echo -e "${azul} Estado de configuracion del script:${borra_colores}"
echo ""
echo -e "${azul}  Servicios${borra_colores} =${amarillo} $servicios${borra_colores} | ${azul}Bot de telegram${borra_colores}  =${amarillo} $bot_telegram ${borra_colores}"
echo -e "${azul}  Ips      ${borra_colores} =${amarillo} $ips${borra_colores} | ${azul}Envio a telegram${borra_colores} =${amarillo} $envio_telegram ${borra_colores}"
echo -e "${azul}  Dominios ${borra_colores} =${amarillo} $dominios${borra_colores} | ${azul}Envio por correo${borra_colores} =${amarillo} $envio_correo ${borra_colores}"
echo ""
}

menu_inicial(){
echo ""
echo -e "${rosa}            _    _                  ${azul}   "
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   "
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Nombre del script ( ${borra_colores}$NombreScript${azul} )${borra_colores}"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Descripcion ( ${borra_colores}$DescripcionDelScript${azul})${borra_colores}"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}"
echo -e "${rosa}                  |___/             ${azul}"
echo -e ""
echo -e "${azul} Contacto: ( ${borra_colores}Correo $Correo${azul} ) ( ${borra_colores}Web $Web${azul} )${borra_colores}"
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
menu_inicial
conexion
if [ $conexion = "SI" ]; then
    actualizar_script
    if [ $actualizado = "SI" ]; then
        software_necesario
        if [ $software = "SI" ]; then
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


#carga el fichero de configuracion para ver su estado
source $ruta_ejecucion/MonitorRed/configurado.config

while :
do
    clear
    echo ""
    echo -e "${rosa}            _    _                  ${azul}   Nombre del script ( ${borra_colores}$NombreScript${azul} )${borra_colores}"
    echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion ( ${borra_colores}$DescripcionDelScript${azul})${borra_colores}"
    echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
    echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
    echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
    echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
    echo -e ""
    echo -e "${azul} Contacto: ( ${borra_colores}Correo $Correo${azul} ) ( ${borra_colores}Web $Web${azul} )${borra_colores}"
    echo ""
    echo -e "   ${azul}Comprobar servicios:${borra_colores}"
    echo -e "   ${azul} 1-${borra_colores} Comprobar Servicios activos de la misma ip"
    echo -e "   ${azul} 2-${borra_colores} Comprobar Ips activas"
    echo -e "   ${azul} 3-${borra_colores} Comprobar Dominio"
    echo -e "   ${azul} 4-${borra_colores} Comprobar todo"
    echo -e ""
    echo -e "   ${azul}Configuraciones:${borra_colores}"
    echo -e "   ${azul}10-${borra_colores} Servicios            ${azul}(${amarillo} $servicios${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}11-${borra_colores} Ips                  ${azul}(${amarillo} $ips${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}12-${borra_colores} Dominios             ${azul}(${amarillo} $dominios${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}13-${borra_colores} Bot de Telegram      ${azul}(${amarillo} $bot_telegram${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}13-${borra_colores} Automatico a Telegram${azul}(${amarillo} $envio_telegram${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}15-${borra_colores} Correo Electronico   ${azul}(${amarillo} $configurar_correo${borra_colores} configurado${azul})${borra_colores}"
    echo -e "   ${azul}16-${borra_colores} Automatico a Correo  ${azul}(${amarillo} $envio_correo${borra_colores} configurado${azul})${borra_colores}"
    echo -e ""
    echo -e "   ${azul}Borrar configuraciones de MonitorRed:${borra_colores}"
    echo -e "   ${azul}20-${rojo} Servicios${borra_colores}"
    echo -e "   ${azul}21-${rojo} Ips${borra_colores}"
    echo -e "   ${azul}22-${rojo} Dominios${borra_colores}"
    echo -e "   ${azul}23-${rojo} Bot de Telegram${borra_colores}"
    echo -e "   ${azul}24-${rojo} Automatico a Telegram${borra_colores}"
    echo -e "   ${azul}25-${rojo} Correo Electronico${borra_colores}"
    echo -e "   ${azul}26-${rojo} Automatico a Correo${borra_colores}"
    echo -e "   ${azul}27-${rojo} Restaurar todo${borra_colores}"
    echo -e ""
    echo -e "   ${azul}Resto de opciones:${borra_colores}"
    echo -e "   ${azul}90-${borra_colores} Ayuda"
    echo -e "   ${azul}99-${borra_colores} Salir del MonitorRed."
    echo ""
    echo -e -n "${azul} Selecciona numero de las opciones del menu ->${borra_colores} "; read opcion
    case $opcion in
        1)  #Comprobar Servicios activos de la misma ip
            ;;

        2)  #Comprobar Ips activas
            ;;

        3)  #Comprobar Dominio
            ;;

        4)  #Comprobar todo
            ;;

        10) #configurar servicios
            bash $ruta_ejecucion/MonitorRed/configurarservicios
            ;;

        11) #Configurar ips
            ;;


        12) #Configurar dominios
            ;;

        13) #Configurar bot telegram
            ;;

        14) #automatico a telegram
            ;;

        15) #configurar correo
            ;;

        16) #automatico a correo
            ;;

        20) #Borrar servicios
            echo ""
            read -p " ¿ Seguro que quieres borrar la configuracion de SERVICIOS ? (S/n) -> " sn
            if [[ "$sn" == "s" ]] || [[ "$sn" == "S" ]]; then
                rm $ruta_ejecucion/MonitorRedServicios.config 2>/dev/null 1>/dev/null 0>/dev/null
                sed -i 's/servicios="si"/servicios="no"/' "$ruta_ejecucion/configurado.conf"
                echo ""
                echo -e "${amarillo} Borrada la configuracion de SERVICIOS.${borra_colores}"; sleep 2
            else
                echo ""
                echo -e "${verde} No se borra nada.${borra_colores}"; sleep 2
            fi
            ;;

        21) #Borrar ips
            ;;

        22) #Borrar dominios
            ;;

        23) #Borrar bot de telegram
            ;;

        24) #Borrar automatico de telegram
            ;;

        25) #Borrar correo electronico
            ;;

        26) #Borrar automatico correo electronico
            ;;

        27) #Borrar todo
            echo ""
            read -p " ¿ Seguro que quieres borrar toda la configuracion (S/n) ? -> " sn
            if [[ "$sn" == "s" ]] || [[ "$sn" == "S" ]]; then
                rm $ruta_ejecucion/configurado.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedServicios.config 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedDominios.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedIps.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedBot_telegram.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedEnvio_telegram.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedEnvio_correo.conf 2>/dev/null 1>/dev/null 0>/dev/null
                rm $ruta_ejecucion/MonitorRedConfigurar_correo.conf 2>/dev/null 1>/dev/null 0>/dev/null

                #crea el fichero de estado de configuracion (configurado.conf)
                echo 'servicios="no"' >> $ruta_ejecucion/configurad.conf
                echo 'dominios="no"' >> $ruta_ejecucion/configurado.conf
                echo 'ips="no"' >> $ruta_ejecucion/configurado.conf
                echo 'bot_telegram="no"' >> $ruta_ejecucion/configurado.conf
                echo 'envio_telegram="no"' >> $ruta_ejecucion/configurado.conf
                echo 'envio_correo="no"' >> $ruta_ejecucion/configurado.conf
                echo 'configurar_correo="no"' >> $ruta_ejecucion/configurado.conf
                echo ""
                echo -e "${amarillo} Toda la configuracion restablecida a sus valores iniciales.${borra_colores}"; sleep 2

                ########crontab -l | grep -v "MonitorRed" | crontab - 2>/dev/null 1>/dev/null 0>/dev/null
                #####rm $ruta_ejecucion/MonitorRedTelegram.config 2>/dev/null 1>/dev/null 0>/dev/null
                #####rm -r /home/$(whoami)/.config/MonitorRedAutomatico 2>/dev/null 1>/dev/null 0>/dev/null

            else
                echo ""
                echo -e "${verde} No se borra nada.${borra_colores}"; sleep 2
            fi
            ;;

        90) #ayuda
            clear
            cat $ruta_ejecucion/MonitorRed/ayuda
            read p
            ;;

        99) #salir
            ctrl_c
            ;;

        *)  echo ""
            echo -e "${amarillo} Opcion no valida del menu.${borra_colores}"
            sleep 2
            ;;
    esac
done













