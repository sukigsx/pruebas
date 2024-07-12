#!/bin/bash

ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final
source $ruta_ejecucion/configurado.config

comprobar_servicios(){
#funcion de comprobar comprobar_servicios
clear
archivo="$ruta_ejecucion/MonitorRedServicios.config"

#comprueba si esta configurado
if [ "$configurado_servicios" = "no" ]; then
    echo ""
    echo -e "${amarillo} No tienes ningun Servicio configurado.${borra_colores}" >> $ruta_ejecucion/resultado.txt
    echo ""
else
    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo ""
        echo -e "${azul} Comprobando SERVICIOS.${borra_colores}\n" >> $ruta_ejecucion/resultado.txt
        source $ruta_ejecucion/MonitorRedServicios.config
        for resultado in "${!servicios[@]}"
        do
            curl -s -o -I $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf "${azul} SERVICIO ${amarillo}${servicios[$resultado]} ${verde}ENCENDIDO${borra_colores} en la ip y puerto ${amarillo}$resultado\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            else
                printf "${azul} SERVICIO ${amarillo}${servicios[$resultado]} ${rojo}APAGADO  ${borra_colores} en la ip y puerto ${amarillo}$resultado\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            fi
        done
        echo ""
        printf "${azul} Escaneo de servicios Terminado.${borra_colores}\n" >> $ruta_ejecucion/resultado.txt
        echo "----------------------------------------------------" >> $ruta_ejecucion/resultado.txt

    fi
fi
}

comprobar_ips(){
#funcion de comprobar comprobar_ips
clear
echo -e "${rosa}"; figlet Escaneando; echo -e "${borra_colores}"
archivo="$ruta_ejecucion/MonitorRedIps.config"
#comprobar si esta configurado
if [ "$configurado_ips" = "no" ]; then
    echo -e ""
    echo -e "${amarillo} No tienes ninguna Ip configurada.${borra_colores}"; sleep 2
    echo -e ""
else
    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo ""
        echo -e "${azul} Comprobando IPS activas en tu red.${borra_colores}\n"
        source $ruta_ejecucion/MonitorRedIps.config
        for resultado in "${!ips[@]}"
        do
            ping -w 1 $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf "${azul} IP${amarillo} $resultado ${verde}ENCENDIDA${borra_colores} del equipo ${amarillo}${ips[$resultado]}\n" | column -t -s $'\t'
            else
                printf "${azul} IP${amarillo} $resultado ${rojo}APAGADA  ${borra_colores} del equipo ${amarillo}${ips[$resultado]}\n" | column -t -s $'\t'
            fi
        done
        echo ""
        printf "${azul} Escaneo Terminado. Pulsa una tecla para continuar.${borra_colores}\n"
        echo "----------------------------------------------------"
        read -p " Pulsa una tecla para continuar." p
    fi
fi
}

comprobar_dominios(){
#funcion de comprobar comprobar_servicios
clear
echo -e "${rosa}"; figlet Escaneando; echo -e "${borra_colores}"
archivo="$ruta_ejecucion/MonitorRedDominios.config"

#comprueba si esta configurado
if [ "$configurado_dominios" = "no" ]; then
    echo -e ""
    echo -e "${amarillo} No tienes ningun Dominio configurado.${borra_colores}"; sleep 2
    echo -e ""
else

    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo ""
        echo -e "${azul} Comprobando DOMINIOS.${borra_colores}\n"
        source $ruta_ejecucion/MonitorRedDominios.config
        for resultado in "${!dominios[@]}"
        do
            curl -s -o -I $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf "${azul} DOMINIO ${amarillo}$resultado ${verde}ENCENDIDO${borra_colores} del servicio web ${amarillo}${dominios[$resultado]}\n" | column -t -s $'\t'
            else
                printf "${azul} DOMINIO ${amarillo}$resultado ${rojo}APAGADO${borra_colores} del servicio web ${amarillo}${dominios[$resultado]}\n" | column -t -s $'\t'
            fi
        done
        echo ""
        printf "${azul} Escaneo Terminado. Pulsa una tecla para continuar.${borra_colores}\n"
        echo "----------------------------------------------------"
        read -p " Pulsa una tecla para continuar." p
    fi
fi
}

comprobar_servicios
