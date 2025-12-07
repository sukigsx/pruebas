#!/bin/bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="CronManager"
export DescripcionDelScript="Herramienta de configuracion de tareas Cron de linux"
export Correo="scripts@mbbsistemas.es"
export Web="https://repositorio.mbbsistemas.es"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="CronManager.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [nano]="nano"
        [curl]="curl"
        [grep]="grep"
        [crontab]="cron"
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

echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
#########software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for comando in "${!requeridos[@]}"; do
        which $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                echo ""
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}sudo apt install ${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e " ${rojo}No se puede ejecutar el script sin el software necesario.${borra_colores}"
                echo ""; read p
                echo ""
                exit 1
            else
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                sudo apt install ${requeridos[$comando]} -y &>/dev/null
                let "contador=contador+1"
                which $comando &>/dev/null
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



###################################################################################
######### EMPIEZA LO GORDO

CRON_TMP="/tmp/cron_$$"

mostrar_menu() {
    echo -e "${azul}      GESTOR DE CRONTAB${borra_colores}"
    echo ""
    echo -e "  ${azul}1)${borra_colores} Crear nueva tarea"
    echo -e "  ${azul}2)${borra_colores} Borrar una tarea"
    echo -e "  ${azul}3)${borra_colores} Ayuda cron (@reboot, @yearly...)"
    echo ""
    echo -e " ${azul}99)${borra_colores} Salir"
    echo
    listar_cron
    echo ""
    read -p "$(echo -e " ${azul}Selecciona una opcion: ${borra_colores}")" opcion
    #read -p " Seleccione una opción: " opcion
}

listar_cron() {
    CRON_CONTENT=$(crontab -l 2>/dev/null | grep -v '^\s*$' | grep -v '^#' | sed 's/^/   /')
    if [[ -z "$CRON_CONTENT" ]]; then
        echo -e " ${amarillo}No hay tareas programadas en el crontab de${borra_colores} $(whoami)"
    else
        echo -e " ${azul}Listado de tareas del cron de usurio${borra_colores} $(whoami)"
        echo ""
        echo -e "${turquesa}$CRON_CONTENT${borra_colores}"
    fi
}

ayuda_cron() {
    clear
    menu_info
    echo
    echo -e "${azul} Opcion: Ayuda de cron${borra_colores}"
    echo ""
    echo -e "${turquesa} Macros especiales de cron:${borra_colores}"
    echo -e ""
    echo -e "    @reboot     -> Ejecuta al iniciar el sistema"
    echo -e "    @yearly     -> Una vez al año (equivalente a '0 0 1 1 *')"
    echo -e "    @annually   -> Igual que @yearly"
    echo -e "    @monthly    -> Una vez al mes (equivalente a '0 0 1 * *')"
    echo -e "    @weekly     -> Una vez a la semana (equivalente a '0 0 * * 0')"
    echo -e "    @daily      -> Una vez al día (equivalente a '0 0 * * *')"
    echo -e "    @midnight   -> Igual que @daily"
    echo -e "    @hourly     -> Una vez por hora (equivalente a '0 * * * *')"
    echo -e ""
    echo -e "${turquesa} Opciones de ejecucion programadas:${borra_colores}"
    echo -e ""
    echo -e "    Minuto          0–59, * Minuto dentro de la hora"
    echo -e "    Hora            0–23, * Hora del día"
    echo -e "    Día del mes     1–31, * Día del mes"
    echo -e "    Mes             1–12, * Mes (1=enero)"
    echo -e "    Día de semana   0–7 , * (0 y 7 = domingo)"
    echo -e ""
    echo -e "${turquesa} Ejemplos usando macros y programacion:${borra_colores}"
    echo ""
    echo -e "    @reboot /usr/bin/wakeonlan AA:BB:CC:DD:EE:FF #ejecuta en cada reinicio."
    echo -e "    * * * * * bash /home/script.sh #ejecuta a todos los minutos del dia"
    echo ""
    read -p "$(echo -e "${azul} Pulsa una tecla para continuar ${borra_colores}")" pause
}

# ================================
# VALIDADORES INDIVIDUALES
# ================================

validar_minuto() {
    #[[ "$1" == "*" || ( "$1" =~ ^[0-9]+$ && "$1" -ge 0 && "$1" -le 59 ) ]]
    [[ "$1" == "*" || "$1" == "0" || "$1" =~ ^[1-9][0-9]?$ ]] && [[ ! ( "$1" =~ ^[0-9]+$ && "$1" -gt 59 ) ]]
}

validar_hora() {
    #[[ "$1" == "*" || ( "$1" =~ ^[0-9]+$ && "$1" -ge 0 && "$1" -le 23 ) ]]
    [[ "$1" == "*" || "$1" == "0" || "$1" =~ ^[1-9][0-9]?$ ]] && [[ ! ( "$1" =~ ^[0-9]+$ && "$1" -gt 59 ) ]]
}

validar_dia() {
    [[ "$1" == "*" || ( "$1" =~ ^[0-9]+$ && "$1" -ge 1 && "$1" -le 31 ) ]]
}

validar_mes() {
    [[ "$1" == "*" || ( "$1" =~ ^[0-9]+$ && "$1" -ge 1 && "$1" -le 12 ) ]]
}

validar_semana() {
    [[ "$1" == "*" || ( "$1" =~ ^[1-9]+$ && "$1" -ge 1 && "$1" -le 7 ) ]]
}

crear_tarea() {
    clear
    menu_info
    echo
    echo -e "${azul} Opcion: Crear tarea nueva${borra_colores}"
    echo ""
    listar_cron
    # Preguntar si usar macro (s/S)
    echo ""
    read -rp " ¿Deseas usar una macro especial como @reboot, @daily, etc? (s/n) (99 = Atras): " usar_macro
    if [[ "$usar_macro" =~ "99" ]]; then
        return
    fi

    case "$usar_macro" in
    [sS])
        # Lista de macros válidas
        MACROS_VALIDAS=(
            "@reboot" "@yearly" "@annually" "@monthly"
            "@weekly" "@daily" "@midnight" "@hourly"
        )

        # Pedir macro hasta que sea válida
        while true; do
            submenu 2>/dev/null

            echo ""
            echo -e "${azul} Listado de macros para cron ${turquesa}"
            echo ""

            printf "%s\n" "${MACROS_VALIDAS[@]}" | sed 's/^/   /'
            echo -e "${borra_colores}"

            read -rp " Introduce la macro (99 = atras ): " macro

            if [ "$macro" = "99" ]; then
                return
            fi

            if printf "%s\n" "${MACROS_VALIDAS[@]}" | grep -Fxq "$macro"; then
                break
            fi

            echo ""; echo -e " ${rojo}Macro inválida.${amarillo} Selecciona una de la lista${borra_colores}"
            sleep 2

            submenu() {
                clear
                menu_info
                echo
                echo -e "${azul} Opcion: Crear tarea nueva${borra_colores}"
                echo ""
                listar_cron
            }
        done

        # Validación de comando no vacío
        while true; do
            echo ""
            read -rp " Comando a ejecutar: " comando
            [[ -n "$comando" ]] && break
            echo -e "${rojo} El comando no puede estar vacío.${borra_colores}"
        done

        # Añadir cron
        crontab -l 2>/dev/null > "$CRON_TMP"
        echo "$macro $comando" >> "$CRON_TMP"
        crontab "$CRON_TMP"

        echo -e "${verde} Tarea creada con macro.${borra_colores}"
        sleep 2
        return
        ;;

    [nN])
    # ================================
    # Validación repetitiva campos cron
    # ================================

    while true; do
        echo ""
        read -rp " Minuto 0-59 o *, (99 = Atras): " min
        if [ "$min" = "99" ]; then
            return
        fi
        validar_minuto "$min" && break
        echo -e "${rojo} Valor inválido.${amarillo} Debe ser 0-59 o *${borra_colores}"
    done

    while true; do
        echo ""
        read -rp " Hora 0-23 o *, (99 = Atras): " hora
        if [ "$hora" = "99" ]; then
            return
        fi
        validar_hora "$hora" && break
        echo -e "${rojo} Valor inválido.${amarillo} Debe ser 0-23 o *${borra_colores}"
    done

    while true; do
        echo ""
        read -rp " Día del mes 1-31 o *, (99 = Atras): " dia
        if [ "$dia" = "99" ]; then
            return
        fi
        validar_dia "$dia" && break
        echo -e "${rojo} Valor inválido.${amarillo} Debe ser 1-31 o *${borra_colores}"
    done

    while true; do
        echo ""
        read -rp " Mes 1-12 o *, (99 = Atras): " mes
        if [ "$mes" = "99" ]; then
            return
        fi
        validar_mes "$mes" && break
        echo -e "${rojo} Valor inválido.${amarillo} Debe ser 1-12 o *${borra_colores}"
    done

    while true; do
        echo ""
        read -rp " Día de la semana 1-7 o *, (99 = Atras): " semana
        if [ "$semana" = "99" ]; then
            return
        fi
        validar_semana "$semana" && break
        echo -e "${rojo} Valor inválido.${amarillo} Debe ser 1-7 o *${borra_colores}"
    done

    # Validación del comando
    while true; do
        echo ""
        read -rp " Comando a ejecutar (99 = Atras): " comando
        if [ "$comando" = "99" ]; then
            return
        fi
        [[ -n "$comando" ]] && break
        echo -e "${rojo} El comando no puede estar vacío.${borra_colores}"
    done ;;

    *)  echo ""; echo -e "${rojo} Opción NO valida${borra_colores}"; sleep 2; return ;;
    esac

    # Añadir nueva tarea cron
    crontab -l 2>/dev/null > "$CRON_TMP"
    echo "$min $hora $dia $mes $semana $comando" >> "$CRON_TMP"
    crontab "$CRON_TMP"
    echo ""
    echo -e "${verde} Tarea creada.${borra_colores}"; sleep 2
}

borrar_tarea() {
    clear
    menu_info
    echo -e "${azul} Opción: Borrar tareas del usuario${borra_colores} $(whoami)"
    echo ""

    CRON_CONTENT=$(crontab -l 2>/dev/null | grep -v '^\s*$' | grep -v '^#' | sed 's/^/   /')
    if [[ -z "$CRON_CONTENT" ]]; then
        echo -e "${rojo} No hay tareas programadas en el crontab de${borra_colores} $(whoami)"; sleep 2
    else
        crontab -l 2>/dev/null > $CRON_TMP || { echo -e "${rojo}No hay tareas.${borra_colores}"; return; }
        nl -ba $CRON_TMP
        echo ""

        read -p "$(echo -e "${azul} Números de las tareas a borrar (separados por espacios) (99 = Atras): ${borra_colores}")" nums
        if [ "$nums" = "99" ]; then
            return
        fi

        nums_array=($nums)
        total=$(wc -l < $CRON_TMP)

        valid_nums=()
        invalid_nums=()

        # Clasificar válidos e inválidos
        for n in "${nums_array[@]}"; do
            if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= total )); then
                valid_nums+=("$n")
            else
                invalid_nums+=("$n")
            fi
        done

        # Mostrar inválidos (pero no abortar)
        if (( ${#invalid_nums[@]} > 0 )); then
            echo -e "${amarillo} Números inválidos ignorados:${borra_colores} ${invalid_nums[*]}"; sleep 2
        fi

        # Si no hay válidos, salir
        if (( ${#valid_nums[@]} == 0 )); then
            echo -e "${amarillo} No hay números válidos para borrar.${borra_colores}"; sleep 2
            return
        fi

        # Ordenar válidos de mayor a menor
        valid_nums_sorted=($(printf "%s\n" "${valid_nums[@]}" | sort -rn))

        # Borrar líneas válidas
        for n in "${valid_nums_sorted[@]}"; do
            sed -i "${n}d" "$CRON_TMP"
        done

        crontab "$CRON_TMP"
        echo ""
        echo -e "${verde} Tareas válidas eliminadas.${borra_colores}"; sleep 2
    fi
}


# Bucle principal
while true; do
    clear
    menu_info
    mostrar_menu
    case $opcion in
         1) crear_tarea ;;
         2) borrar_tarea ;;
         3) ayuda_cron ;;
        99) ctrl_c ;;
        *) echo ""; echo -e "${amarillo} Opción inválida${borra_colores}"; sleep 2 ;;
    esac
done
