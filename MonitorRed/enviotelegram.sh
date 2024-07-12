#!/bin/bash

ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final
source $ruta_ejecucion/configurado.config
source $ruta_ejecucion/MonitorRedBot_telegram.config

comprobar_servicios(){
#funcion de comprobar comprobar_servicios
archivo="$ruta_ejecucion/MonitorRedServicios.config"

#comprueba si esta configurado
if [ "$configurado_servicios" = "no" ]; then
    echo "" >> $ruta_ejecucion/resultado.txt
    echo -e " - Comprobando SERVICIOS -\n" >> $ruta_ejecucion/resultado.txt
    echo -e " No tienes ningun Servicio configurado." >> $ruta_ejecucion/resultado.txt
else
    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo "" >> $ruta_ejecucion/resultado.txt
        echo -e " - Comprobando SERVICIOS -\n" >> $ruta_ejecucion/resultado.txt
        source $ruta_ejecucion/MonitorRedServicios.config
        for resultado in "${!servicios[@]}"
        do
            curl -s -o -I $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf " SERVICIO ${servicios[$resultado]} ENCENDIDO en la ip y puerto $resultado\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            else
                printf " SERVICIO ${servicios[$resultado]} APAGADO   en la ip y puerto $resultado\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            fi
        done
        echo "" >> $ruta_ejecucion/resultado.txt
    fi
fi
}

comprobar_ips(){
#funcion de comprobar comprobar_ips
archivo="$ruta_ejecucion/MonitorRedIps.config"
#comprobar si esta configurado
if [ "$configurado_ips" = "no" ]; then
    echo "" >> $ruta_ejecucion/resultado.txt
    echo -e " - Comprobando IPS activas en tu red -\n" >> $ruta_ejecucion/resultado.txt
    echo -e " No tienes ninguna Ip configurada." >> $ruta_ejecucion/resultado.txt
else
    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo "" >> $ruta_ejecucion/resultado.txt
        echo -e " - Comprobando IPS activas en tu red -\n" >> $ruta_ejecucion/resultado.txt
        source $ruta_ejecucion/MonitorRedIps.config
        for resultado in "${!ips[@]}"
        do
            ping -w 1 $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf " IP $resultado ENCENDIDA del equipo ${ips[$resultado]}\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            else
                printf " IP $resultado APAGADA   del equipo ${ips[$resultado]}\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            fi
        done
        echo "" >> $ruta_ejecucion/resultado.txt
    fi
fi
}

comprobar_dominios(){
#funcion de comprobar comprobar_servicios
archivo="$ruta_ejecucion/MonitorRedDominios.config"

#comprueba si esta configurado
if [ "$configurado_dominios" = "no" ]; then
    echo "" >> $ruta_ejecucion/resultado.txt
    echo -e " - Comprobando DOMINIOS -\n" >> $ruta_ejecucion/resultado.txt
    echo -e "${amarillo} No tienes ningun Dominio configurado.${borra_colores}" >> $ruta_ejecucion/resultado.txt
else

    if [ -f "$archivo" ] && grep -q "\[" "$archivo"; then
        echo "" >> $ruta_ejecucion/resultado.txt
        echo -e " - Comprobando DOMINIOS -\n" >> $ruta_ejecucion/resultado.txt
        source $ruta_ejecucion/MonitorRedDominios.config
        for resultado in "${!dominios[@]}"
        do
            curl -s -o -I $resultado 1>/dev/null 2>/dev/null
            if [ $? = "0" ]
            then
                printf " DOMINIO $resultado ENCENDIDO del servicio web ${dominios[$resultado]}\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            else
                printf " DOMINIO $resultado APAGADO   del servicio web ${dominios[$resultado]}\n" | column -t -s $'\t' >> $ruta_ejecucion/resultado.txt
            fi
        done
        echo "" >> $ruta_ejecucion/resultado.txt
    fi
fi
}



#borra el resultado por si hay alguno
rm $ruta_ejecucion/resultado.txt >/dev/null 2>&1

comprobar_servicios
comprobar_ips
comprobar_dominios

#envia el telegram
curl -s -X POST $url -d chat_id=$id -d text="$(cat $ruta_ejecucion/resultado.txt)"

#borra el resultado
rm $ruta_ejecucion/resultado.txt >/dev/null 2>&1
