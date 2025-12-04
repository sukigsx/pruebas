#!/bin/bash

# ===========================================
# Gestor de crontab interactivo
# ===========================================

CRON_TMP="/tmp/cron_$$"

mostrar_menu() {
    clear
    echo "==============================="
    echo "      GESTOR DE CRONTAB"
    echo ""
    echo " 1) Listar tareas del cron"
    echo " 2) Crear nueva tarea"
    echo " 3) Borrar una tarea"
    echo " 4) Ayuda cron (@reboot, @yearly...)"
    echo "99) Salir"
    echo
    listar_cron
    echo ""
    read -p "Seleccione una opción: " opcion
}

listar_cron() {
    CRON_CONTENT=$(crontab -l 2>/dev/null | grep -v '^\s*$' | grep -v '^#' | sed 's/^/   /')
    if [[ -z "$CRON_CONTENT" ]]; then
        echo "No hay tareas programadas en el crontab de $(whoami)"
    else
        echo "Listado de tareas del cron de usurio $(whoami)"
        echo ""
        echo "$CRON_CONTENT"
    fi
}

ayuda_cron() {
    clear
    echo
    echo "Opcion: Ayuda de cron"
    echo ""
    echo -e "Macros especiales de cron:"
    echo -e ""
    echo -e "   @reboot     -> Ejecuta al iniciar el sistema"
    echo -e "   @yearly     -> Una vez al año (equivalente a '0 0 1 1 *')"
    echo -e "   @annually   -> Igual que @yearly"
    echo -e "   @monthly    -> Una vez al mes (equivalente a '0 0 1 * *')"
    echo -e "   @weekly     -> Una vez a la semana (equivalente a '0 0 * * 0')"
    echo -e "   @daily      -> Una vez al día (equivalente a '0 0 * * *')"
    echo -e "   @midnight   -> Igual que @daily"
    echo -e "   @hourly     -> Una vez por hora (equivalente a '0 * * * *')"
    echo -e ""
    echo -e "   Minuto          0–59, * Minuto dentro de la hora"
    echo -e "   Hora            0–23, * Hora del día"
    echo -e "   Día del mes     1–31, * Día del mes"
    echo -e "   Mes             1–12, * Mes (1=enero)"
    echo -e "   Día de semana   0–7 , * (0 y 7 = domingo)"
    echo -e ""
    echo -e "   Ejemplo usando macros: @reboot /usr/bin/wakeonlan AA:BB:CC:DD:EE:FF"
    echo -e "                          * * * * * /script.sh >> /var/log/script.log"
    echo ""
    read -p "Pulsa una tecla para continuar" p
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
    echo
    echo "Opcion: CREAR NUEVA TAREA ====="
    echo ""
    # Preguntar si usar macro (s/S)
    read -rp "¿Deseas usar una macro especial como @reboot, @daily, etc? (s/n): " usar_macro
    if [[ "$usar_macro" =~ ^[sS]$ ]]; then

        # Lista de macros válidas
        MACROS_VALIDAS=(
            "@reboot" "@yearly" "@annually" "@monthly"
            "@weekly" "@daily" "@midnight" "@hourly"
        )

        # Pedir macro hasta que sea válida
        while true; do
            submenu 2>/dev/null
            echo ""
            read -rp "Introduce la macro (99 = atras ): " macro

            if [ "$macro" = "99" ]; then
                return
            fi

            if printf "%s\n" "${MACROS_VALIDAS[@]}" | grep -Fxq "$macro"; then
                break
            fi

            echo ""; echo "Macro inválida. Selecciona una de la lista:"
            echo ""
            printf "  %s\n" "${MACROS_VALIDAS[@]}"
            echo ""
            read -p "Pulsa una tecla para continuar." p
            submenu() {
                clear
                echo
                echo "Opcion: CREAR NUEVA TAREA ====="
            }
        done

        # Validación de comando no vacío
        while true; do
            read -rp "Comando a ejecutar: " comando
            [[ -n "$comando" ]] && break
            echo "El comando no puede estar vacío."
        done

        # Añadir cron
        crontab -l 2>/dev/null > "$CRON_TMP"
        echo "$macro $comando" >> "$CRON_TMP"
        crontab "$CRON_TMP"

        echo "Tarea creada con macro."
        return
    fi

    # ================================
    # Validación repetitiva campos cron
    # ================================

    while true; do
        echo ""
        read -rp "Minuto 0-59 o *, (99 = Atras): " min
        if [ "$min" = "99" ]; then
            return
        fi
        validar_minuto "$min" && break
        echo "Valor inválido. Debe ser 0-59 o *"
    done

    while true; do
        echo ""
        read -rp "Hora 0-23 o *, (99 = Atras): " hora
        if [ "$hora" = "99" ]; then
            return
        fi
        validar_hora "$hora" && break
        echo "Valor inválido. Debe ser 0-23 o *"
    done

    while true; do
        echo ""
        read -rp "Día del mes 1-31 o *, (99 = Atras): " dia
        if [ "$dia" = "99" ]; then
            return
        fi
        validar_dia "$dia" && break
        echo "Valor inválido. Debe ser 1-31 o *"
    done

    while true; do
        echo ""
        read -rp "Mes 1-12 o *, (99 = Atras): " mes
        if [ "$mes" = "99" ]; then
            return
        fi
        validar_mes "$mes" && break
        echo "Valor inválido. Debe ser 1-12 o *"
    done

    while true; do
        echo ""
        read -rp "Día de la semana 1-7 o *, (99 = Atras): " semana
        if [ "$semana" = "99" ]; then
            return
        fi
        validar_semana "$semana" && break
        echo "Valor inválido. Debe ser 1-7 o *"
    done

    # Validación del comando
    while true; do
        echo ""
        read -rp "Comando a ejecutar (99 = Atras): " comando
        if [ "$comando" = "99" ]; then
            return
        fi
        [[ -n "$comando" ]] && break
        echo "El comando no puede estar vacío."
    done

    # Añadir nueva tarea cron
    crontab -l 2>/dev/null > "$CRON_TMP"
    echo "$min $hora $dia $mes $semana $comando" >> "$CRON_TMP"
    crontab "$CRON_TMP"
    echo ""
    echo "Tarea creada."; sleep 2
}


borrar_tarea() {
    clear
    echo ""
    echo "Opcion: Borrar una tarea del usuario $(whoami)"
    echo ""

    CRON_CONTENT=$(crontab -l 2>/dev/null | grep -v '^\s*$' | grep -v '^#' | sed 's/^/   /')
    if [[ -z "$CRON_CONTENT" ]]; then
        echo "No hay tareas programadas en el crontab de $(whoami)"; sleep 3
    else
        crontab -l 2>/dev/null > $CRON_TMP || { echo "No hay tareas."; return; }
        nl -ba $CRON_TMP
        echo ""
        read -p "Número de la tarea a borrar: " num

        total=$(wc -l < $CRON_TMP)
        [[ $num -ge 1 && $num -le $total ]] || { echo "Número inválido."; return; }

        sed -i "${num}d" $CRON_TMP
        crontab $CRON_TMP
        echo ""
        echo "Tarea eliminada."; sleep 2
    fi


    #crontab -l 2>/dev/null > $CRON_TMP || { echo "No hay tareas."; return; }
    #nl -ba $CRON_TMP
    #echo ""
    #read -p "Número de la tarea a borrar: " num

    #total=$(wc -l < $CRON_TMP)
    #[[ $num -ge 1 && $num -le $total ]] || { echo "Número inválido."; return; }

    #sed -i "${num}d" $CRON_TMP
    #crontab $CRON_TMP
    #echo "Tarea eliminada."
}

# Bucle principal
while true; do
    mostrar_menu
    case $opcion in
         1) listar_cron ;;
         2) crear_tarea ;;
         3) borrar_tarea ;;
         4) ayuda_cron ;;
        99) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida" ;;
    esac
done
