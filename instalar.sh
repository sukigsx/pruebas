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
echo " Gracias por utilizar mi script "
exit
}

conexion(){
if ping -c1 google.com &>/dev/null
then
    echo ""
    echo -e " Conexion a internet [${verde}ok${borra_colores}]."
    var_conexion="si"
    echo ""
else
    echo ""
    echo -e " Conexion a internet [${rojo}ko${borra_colores}]."
    var_conexion="no"
    echo ""
    exit
fi
}

software_necesario(){
var_software="no"
echo -e " Verificando software necesario:"
software="which git diff ping apt fzf" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
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
var_software="si"
done
}

clear
echo ""
conexion
software_necesario
sleep 2

clear
echo -e "${rosa} - EJECUTAR SCRIPTS -${borra_colores}"
echo ""
echo -e "${verde} Diseñado por sukigsx / Contacto:   scripts@mbbsistemas.es${borra_colores}"
echo -e "${verde}                                    https://repositorio.mbbsistemas.es${borra_colores}"
echo ""
echo -e "${verde} Nombre del script < $0 > Instalador automatico.  ${borra_colores}"
echo ""


echo ""

#comprobar si ya esta instalado.
if [ -d "/home/$(whoami)/scripts" ] || grep -q "source /home/$(whoami)/.config/ejecutar_scripts.config" "/home/$(whoami)/.bashrc"
then
    while true; do
    echo ""
    echo -e "${amarillo} Parece que ya lo tienes instalado ${borra_colores}$(whoami)${amarillo}.${borra_colores}"
    echo ""
    echo -e "  1. Desistalar. (${rojo}Cuidado se borrara el contenido de la carpeta scripts y toda la configuracion.${borra_colores})"
    echo ""
    echo -e " 99. Salir."
    echo ""
    read -p " ¿ Que hacemos ?, seleccione una opción (1/99): " opcion

    case $opcion in

        1)  #desistalar
            echo ""
            echo -e "${verde} Desistalando:${borra_colores}"
            echo ""
            echo -e " Eliminado carpeta (scripts) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; rm -r /home/$(whoami)/scripts 2>/dev/null; sleep 1
            echo -e " Eliminado fichero de configuracion (ejecutar_scripts.congig) en /home/$(whoami)/.config/ [${verde}ok${borra_colores}]."; rm /home/$(whoami)/.config/ejecutar_scripts.config 2>/dev/null; sleep 1
            echo -e " Eliminada la entrada en (.bashrc) [${verde}ok${borra_colores}]."; sed -i "/source \/home\/$(whoami)\/.config\/ejecutar_scripts.config/d" /home/$(whoami)/.bashrc; sleep 1
            echo ""
            echo -e "${verde} Desistalacion completa.${borra_colores}"
            echo ""
            echo -e "${amarillo} Tienes que reiniciar la terminal para que surjan efecto los cambios.${borra_colores}"
            echo ""
            exit
            ;;

        99)  #Saliendo del programa.
            ctrl_c
            ;;

        *)
            echo ""
            echo -e "${rojo}Opción no válida. Por favor, seleccione 1 o 99.·{borra_colores}"
            sleep 3
            ;;
    esac
done
else
    #comprueba si existe la carpeta /home/usuario/.config y si no esta la crea
    if [ -d /home/$(whoami)/.config ]
    then
        echo ""
    else
        # Crear la carpeta .config si no existe
        mkdir /home/$(whoami)/.config
    fi

    echo -e "${verde} Instalando:${borra_colores}"
    echo ""
    echo -e " Creando carpeta (scripts) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; mkdir /home/$(whoami)/scripts; sleep 1
    echo -e " Creando fichero de configuracion (ejecutar_scripts.congig) en /home/$(whoami)/.config/ [${verde}ok${borra_colores}]."; cp ejecutar_scripts.config /home/$(whoami)/.config/ejecutar_scripts.config; sleep 1
    echo -e " Creando entrada en (.bashrc) [${verde}ok${borra_colores}]."; echo "source /home/$(whoami)/.config/ejecutar_scripts.config" >> /home/$(whoami)/.bashrc; sleep 1
    echo -e " Incluyendo este script a tu carpeta de scripts [${verde}ok${borra_colores}]."; cp ejecutar_scripts.sh /home/$(whoami)/scripts/; sleep 1
    echo ""
    echo -e " Instalacion completada [${verde}ok${borra_colores}] ."
    echo ""
    echo -e "${amarillo} Tienes que reiniciar la terminal para que surjan efecto los cambios.${borra_colores}"
    echo ""
    exit
fi
