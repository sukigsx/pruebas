#!/bin/bash

# ===========================================
# Gestor de crontab interactivo
# ===========================================

CRON_TMP="/tmp/cron_$$"

mostrar_menu() {
    clear
    echo "==============================="
    echo "      GESTOR DE CRONTAB"
    listar_cron
    echo "1) Listar tareas del cron"
    echo "2) Crear nueva tarea"
    echo "3) Modificar una tarea"
    echo "4) Borrar una tarea"
    echo "5) Ayuda cron (@reboot, @yearly...)"
    echo "0) Salir"
    echo ""
    read -p "Seleccione una opción: " opcion
}

listar_cron() {
    echo "===== TAREAS ACTUALES ====="
    crontab -l 2>/dev/null || echo "(No hay tareas programadas)"
}

ayuda_cron() {
    echo
    echo "===== AYUDA CRON ====="
    cat <<EOF
Macros especiales de cron:
  @reboot     -> Ejecuta al iniciar el sistema
  @yearly     -> Una vez al año (equivalente a '0 0 1 1 *')
  @annually   -> Igual que @yearly
  @monthly    -> Una vez al mes (equivalente a '0 0 1 * *')
  @weekly     -> Una vez a la semana (equivalente a '0 0 * * 0')
  @daily      -> Una vez al día (equivalente a '0 0 * * *')
  @midnight   -> Igual que @daily
  @hourly     -> Una vez por hora (equivalente a '0 * * * *')

Ejemplo usando macros: @reboot /usr/bin/wakeonlan AA:BB:CC:DD:EE:FF
EOF
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
    [[ "$1" == "*" || ( "$1" =~ ^[0-9]+$ && "$1" -ge 1 && "$1" -le 7 ) ]]
}

leer_input_valido() {
    local mensaje=$1
    local funcion_validadora=$2
    local valor

    while true; do
        read -p "$mensaje" valor
        if $funcion_validadora "$valor"; then
            echo "$valor"
            return
        else
            echo "Valor inválido. Intente de nuevo."
        fi
    done
}

leer_comando_no_vacio() {
    local cmd
    while true; do
        read -p "Comando a ejecutar: " cmd
        [[ -n "$cmd" ]] && { echo "$cmd"; return; }
        echo "El comando no puede estar vacío."
    done
}

crear_tarea() {
    echo
    echo "===== CREAR NUEVA TAREA ====="
    ayuda_cron
    read -p "¿Deseas usar una macro especial como @reboot, @daily, etc? (s/n): " usar_macro

    # Acepta s o S
    #if [[ "$usar_macro" =~ ^[sS] ]]; then
    if [[ $usar_macro == "s" ]]; then
        # Validar macro hasta que sea correcta
        while true; do
            read -p "Introduce la macro: " macro

            if [[ "$macro" =~ ^@(reboot|yearly|annually|monthly|weekly|daily|midnight|hourly)$ ]]; then
                break
            else
                echo "Macro inválida. Debe ser una de estas:"
                echo "@reboot @yearly @annually @monthly @weekly @daily @midnight @hourly"
            fi
        done

        # Evitar comando vacío
        comando=$(leer_comando_no_vacio)

        crontab -l 2>/dev/null > $CRON_TMP
        echo "$macro $comando" >> $CRON_TMP
        crontab $CRON_TMP

        echo "Tarea creada."
        return
    fi
}

modificar_tarea() {
    clear
    echo "Opcion: Modificar una tarea"
    crontab -l 2>/dev/null > $CRON_TMP || { echo "No hay tareas."; return; }
    echo ""
    nl -ba $CRON_TMP
    echo ""
    read -p "Número de la tarea a modificar: " num

    total=$(wc -l < $CRON_TMP)
    [[ $num -ge 1 && $num -le $total ]] || { echo "Número inválido."; return; }

    echo "Introduce los nuevos valores para la tarea (no dejes nada vacío):"

    min=$(leer_input_valido "Minuto (0-59 o *): " validar_minuto)
    hora=$(leer_input_valido "Hora (0-23 o *): " validar_hora)
    dia=$(leer_input_valido "Día del mes (1-31 o *): " validar_dia)
    mes=$(leer_input_valido "Mes (1-12 o *): " validar_mes)
    semana=$(leer_input_valido "Día de la semana (1-7 o *): " validar_semana)

    comando=$(leer_comando_no_vacio)

    nueva_linea="$min $hora $dia $mes $semana $comando"

    sed -i "${num}s|.*|$nueva_linea|" $CRON_TMP
    crontab $CRON_TMP

    echo "Tarea modificada."
}

borrar_tarea() {
    listar_cron
    crontab -l 2>/dev/null > $CRON_TMP || { echo "No hay tareas."; return; }

    echo
    nl -ba $CRON_TMP
    read -p "Número de la tarea a borrar: " num

    total=$(wc -l < $CRON_TMP)
    [[ $num -ge 1 && $num -le $total ]] || { echo "Número inválido."; return; }

    sed -i "${num}d" $CRON_TMP
    crontab $CRON_TMP

    echo "Tarea eliminada."
}

# Bucle principal
while true; do
    mostrar_menu
    case $opcion in
        1) listar_cron ;;
        2) crear_tarea ;;
        3) modificar_tarea ;;
        4) borrar_tarea ;;
        5) ayuda_cron ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida" ;;
    esac
    echo
    read -p "Presiona ENTER para continuar..."
done
