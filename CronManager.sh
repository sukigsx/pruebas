#!/bin/bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="CronManager"
export DescripcionDelScript="Herramienta de configuracion de tareas Cron de linux"
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
NombreScriptActualizar="CronManager.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [nano]="nano"
        [curl]="curl"
        [konsole]="konsole"
        [getfacl]="acl"
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

clear
menu_info
#!/usr/bin/env bash
set -euo pipefail

CRONTMP="$(mktemp /tmp/cronmgr.XXXXXX)"

cleanup() {
    rm -f "$CRONTMP"
}
trap cleanup EXIT

# --- Funciones de ayuda ---

show_special_help() {
    cat <<'EOF'
 Expresiones especiales disponibles:

   @reboot     → Ejecuta el comando cada vez que el sistema arranca.
   @yearly     → Ejecuta una vez al año (equivale a "0 0 1 1 *").
   @annually   → Alias de @yearly.
   @monthly    → Ejecuta una vez al mes (equivale a "0 0 1 * *").
   @weekly     → Ejecuta una vez a la semana (equivale a "0 0 * * 0").
   @daily      → Ejecuta una vez al día (equivale a "0 0 * * *").
   @midnight   → Alias de @daily.
   @hourly     → Ejecuta una vez por hora (equivale a "0 * * * *").

EOF
}

is_valid_special() {
    local v="$1"
    case "$v" in
        @reboot|@yearly|@annually|@monthly|@weekly|@daily|@hourly|@midnight) return 0 ;;
        *) return 1 ;;
    esac
}

# --- Validación de tokens cron ---
_is_token_valid() {
    local tok="$1"
    local min="$2"
    local max="$3"

    if [[ "$tok" == "*" ]]; then return 0; fi
    if [[ "$tok" =~ ^\*/[0-9]+$ ]]; then return 0; fi
    if [[ "$tok" =~ ^[0-9]+$ ]]; then (( tok >= min && tok <= max )) && return 0 || return 1; fi
    if [[ "$tok" =~ ^[0-9]+/[0-9]+$ ]]; then local n=${tok%%/*}; (( n >= min && n <= max )) && return 0 || return 1; fi
    if [[ "$tok" =~ ^[0-9]+-[0-9]+(/[0-9]+)?$ ]]; then
        local range=${tok%%/*}
        local a=${range%-*}
        local b=${range#*-}
        (( a >= min && b <= max && a <= b )) && return 0 || return 1
    fi
    return 1
}

validate_cron_field() {
    local value="$1"
    local min="$2"
    local max="$3"
    IFS=',' read -r -a tokens <<< "$value"
    for tok in "${tokens[@]}"; do
        tok="${tok//[[:space:]]/}"
        if ! _is_token_valid "$tok" "$min" "$max"; then return 1; fi
    done
    return 0
}

# --- Pedir expresión de programación ---
ask_schedule() {
    echo
    echo "Puedes usar expresiones especiales de cron:"
    echo

    while true; do
        read -p "¿Usar una expresión especial (@reboot, @daily, ...)? (s/n): " choice
        case "$choice" in
            [sS])
                while true; do
                    read -p "Introduce la expresión especial: " special
                    if is_valid_special "$special"; then
                        echo "$special"
                        return 0
                    else
                        echo "Expresión especial inválida. Opciones válidas: @reboot @yearly/@annually @monthly @weekly @daily @hourly @midnight"
                    fi
                done
                ;;
            [nN])
                local MIN HOUR DOM MONTH DOW
                while true; do
                    read -p "Minuto (0-59, admite */n, ranges y listas): " MIN
                    if validate_cron_field "$MIN" 0 59; then break; else echo "Minuto inválido."; fi
                done
                while true; do
                    read -p "Hora (0-23, admite */n, ranges y listas): " HOUR
                    if validate_cron_field "$HOUR" 0 23; then break; else echo "Hora inválida."; fi
                done
                while true; do
                    read -p "Día del mes (1-31, admite *, */n, ranges y listas): " DOM
                    if validate_cron_field "$DOM" 1 31; then break; else echo "Día del mes inválido."; fi
                done
                while true; do
                    read -p "Mes (1-12, admite *, */n, ranges y listas): " MONTH
                    if validate_cron_field "$MONTH" 1 12; then break; else echo "Mes inválido."; fi
                done
                while true; do
                    read -p "Día de la semana (0-6, 0=Dom, admite *, */n, ranges y listas): " DOW
                    if validate_cron_field "$DOW" 0 6; then break; else echo "Día de la semana inválido."; fi
                done
                echo "$MIN $HOUR $DOM $MONTH $DOW"
                return 0
                ;;
            *)
                echo "Responde 's' o 'n'."
                ;;
        esac
    done
}

# --- Cargar crontab ---
load_cron() {
    crontab -l 2>/dev/null | sed '/^#/d' > "$CRONTMP" || true
}

# --- Menú ---
show_menu() {
    while true; do
        clear
        menu_info
        echo -e "${azul} Menu de opciones de ${borra_colores}$0"; echo ""
        echo -e "${azul}  1)${borra_colores} Ver tareas programadas"
        echo -e "${azul}  2)${borra_colores} Crear nueva tarea"
        echo -e "${azul}  3)${borra_colores} Modificar una tarea"
        echo -e "${azul}  4)${borra_colores} Eliminar una tarea"
        echo ""
        echo -e "${azul} 99)${borra_colores} Salir"
        echo ""
        read -p "$(echo -e "${azul} Seleccione una opción: ${borra_colores}")" opt

        case $opt in
            1)  list_tasks ;;
            2)  create_task ;;
            3)  modify_task ;;
            4)  delete_task ;;
            99) ctrl_c ;;
            *) echo -e "\033[1A\033[2K${amarillo} Opción no válida${borra_colores}"; sleep 2 ;;
        esac
    done
}

list_tasks() {
    load_cron
    if [ ! -s "$CRONTMP" ]; then
        echo "No hay tareas programadas."
        return
    fi
    echo
    echo "Tareas actuales:"
    nl -ba "$CRONTMP"
    echo
}

create_task() {
    echo "Crear nueva tarea"
    show_special_help
    schedule="$(ask_schedule)" || return
    while true; do
        read -rp "Comando a ejecutar: " CMD
        [[ -n "${CMD// }" ]] && break
        echo "El comando no puede estar vacío."
    done

    NEW_ENTRY="$schedule $CMD"
    load_cron
    if grep -Fxq "$NEW_ENTRY" "$CRONTMP" 2>/dev/null; then
        echo "La entrada ya existe en el crontab. No se agregó."
        return
    fi
    echo "$NEW_ENTRY" >> "$CRONTMP"
    crontab "$CRONTMP"
    echo "✔ Tarea agregada:"
    echo "  $NEW_ENTRY"
}

modify_task() {
    load_cron
    if [ ! -s "$CRONTMP" ]; then
        echo "No hay tareas para modificar."
        return
    fi
    list_tasks
    read -rp "Número de la tarea a modificar: " num
    TOTAL=$(wc -l < "$CRONTMP")
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$TOTAL" ]; then
        echo "Número inválido."
        return
    fi

    OLD_LINE=$(sed -n "${num}p" "$CRONTMP")
    echo "Tarea actual: $OLD_LINE"
    echo

    first_token="${OLD_LINE%% *}"
    if [[ "$first_token" == @* ]]; then
        echo "La tarea actual usa una @-expresión ($first_token)."
        show_special_help
        while true; do
            read -rp "Deseas usar una @-expresión (s) o cambiar a expresión cron completa (n)? (s/n): " ch
            case "$ch" in
                [sS])
                    while true; do
                        read -rp "Nueva @-expresión: " sp
                        if is_valid_special "$sp"; then
                            schedule="$sp"
                            break
                        else
                            echo "Expresión especial inválida."
                        fi
                    done
                    break
                    ;;
                [nN])
                    schedule="$(ask_schedule)" || return
                    break
                    ;;
                *) echo "Responde s o n." ;;
            esac
        done
    else
        while true; do
            read -rp "Mantener formato cron (min hora dom mes dow) o usar @-expresión? (cron/@): " ch
            case "$ch" in
                cron)
                    schedule="$(ask_schedule)" || return
                    break
                    ;;
                @)
                    show_special_help
                    while true; do
                        read -rp "Nueva @-expresión: " sp
                        if is_valid_special "$sp"; then
                            schedule="$sp"
                            break
                        else
                            echo "Expresión especial inválida."
                        fi
                    done
                    break
                    ;;
                *) echo "Responde 'cron' o '@'." ;;
            esac
        done
    fi

    while true; do
        read -rp "Nuevo comando: " CMD
        [[ -n "${CMD// }" ]] && break
        echo "El comando no puede estar vacío."
    done

    NEW_ENTRY="$schedule $CMD"
    sed -i "${num}s~.*~$NEW_ENTRY~" "$CRONTMP"
    crontab "$CRONTMP"
    echo "✔ Tarea modificada:"
    echo "  $NEW_ENTRY"
}

delete_task() {
    load_cron
    if [ ! -s "$CRONTMP" ]; then
        echo "No hay tareas para eliminar."
        return
    fi
    list_tasks
    read -rp "Número de la tarea a eliminar: " num
    TOTAL=$(wc -l < "$CRONTMP")
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$TOTAL" ]; then
        echo "Número inválido."
        return
    fi
    sed -i "${num}d" "$CRONTMP"
    crontab "$CRONTMP"
    echo "✔ Tarea eliminada."
}
show_menu
