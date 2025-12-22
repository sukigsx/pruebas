#!/bin/bash
# Script interactivo para gestionar aliases y funciones del bashrc con fzf
# Compatible con bashrc

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
menu_info
echo ""
echo -e " ${verde}- Gracias por utilizar mi script -${borra_colores}"
echo ""
exit
}
clear 

BASHRC="$HOME/.bashrc"

backup_aliases_funciones() {
    local destino
    local nombre="Backup_alias_funciones.txt"

    read -e -p " ¿Dónde quieres guardar el backup? [ENTER = $HOME]: " destino
    destino=${destino:-$HOME}

    if [[ ! -d "$destino" ]]; then
        echo ""
        echo -e "${rojo} Error.${amarillo} El directorio no existe:${borra_colores} $destino"
        sleep 3; return 1
    fi

    local OUT="$destino/$nombre"

    echo "# Backup de alias y funciones" > "$OUT"
    echo "# Generado el $(date)" >> "$OUT"
    echo >> "$OUT"

    grep "^alias " "$BASHRC" >> "$OUT"

    awk '
    /^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ {
        in_func=1; brace=0
    }
    {
        if(in_func){
            print
            brace+=gsub(/\{/, "{")
            brace-=gsub(/\}/, "}")
            if(brace==0){in_func=0; print ""}
        }
    }' "$BASHRC" >> "$OUT"

    chmod +x "$OUT"
    echo ""
    echo -e "${verde} Backup creado en:${borra_colores} $OUT"
    sleep 3
}

restaurar_backup() {
    read -p " Ruta del backup a restaurar: " backup_file
    [[ ! -f "$backup_file" ]] && { echo ""; echo -e "${amarillo} Archivo no encontrado${borra_colores}"; sleep 4; return; }
    echo ""
    echo -e "${azul} Restaurando alias${borra_colores}"
    # Restaurar aliases
    grep "^alias " "$backup_file" | while read -r line; do
        nombre=$(echo "$line" | sed -E "s/^alias[[:space:]]+([a-zA-Z0-9_]+)=.*/\1/")
        if ! grep -Eq "^[[:space:]]*alias[[:space:]]+$nombre=" "$BASHRC"; then
            echo "$line" >> "$BASHRC"
            echo -e " Alias restaurado: $nombre"
        else
            echo -e " Alias ya existe, no se duplica: $nombre"
        fi
    done

    # Restaurar funciones
    echo ""
    echo -e "${azul} Restaurando funciones${borra_colores}"
    awk -v B="$BASHRC" '
    /^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ {
        in_func=1; brace=0
    }
    {
        if (in_func) {
            buf = (buf ? buf "\n" : "") $0
            brace += gsub(/\{/, "{")
            brace -= gsub(/\}/, "}")
            if (brace==0) {
                nombre=buf
                sub(/^[[:space:]]*(function[[:space:]]+)?/, "", nombre)
                sub(/\(\).*$/, "", nombre)
                cmd="grep -Eq \"^[[:space:]]*" nombre "[[:space:]]*\\(\\)\" \"" B "\""
                ret=system(cmd)
                if(ret!=0){print buf >> B; print " Función restaurada: " nombre}
                else{print " Función ya existe, no se duplica: " nombre system("sleep 1")}
                buf=""; in_func=0
            }
        }
    }' "$backup_file"

    echo ""
    echo -e "${verde} Restauración completada${borra_colores}"
    read -p " Pulsa una tecla para continuar" pause
}

# ----------------- Crear -----------------

crear_alias() {
    BASHRC="$HOME/.bashrc"

    read -p " Nombre del alias: " nombre
    read -p " Comando del alias: " comando

    # Comprobar si ya existe un alias con ese nombre
    if grep -qE "^alias[[:space:]]+$nombre=" "$BASHRC"; then
        echo ""
        echo -e "${rojo} Error:${amarillo} Ya existe un alias llamado${borra_colores} $nombre"
        sleep 4; clear; return 1
    fi

    # Crear alias
    echo "alias $nombre='$comando'" >> "$BASHRC"
    echo ""
    echo -e "${verde} Creada correctamente el alias${borra_colores} $nombre"
    sleep 3; clear
}

crear_funcion() {
    BASHRC="$HOME/.bashrc"

    read -p " Nombre de la función: " nombre

    # Comprobar si ya existe una función con ese nombre
    if grep -qE "^[[:space:]]*(function[[:space:]]+)?$nombre[[:space:]]*\(\)[[:space:]]*\{" "$BASHRC"; then
        echo ""
        echo -e "${rojo} Error:${amarillo} ya existe una funcion llamada${borra_colores} $nombre"
        sleep 4; clear; return 1
    fi

    echo ""
    echo -e " Escribe o pega el contenido de la funcion (${amarillo}termina con Ctrl+D${borra_colores}):"
    echo ""
    {
        echo
        echo "$nombre() {"
        cat </dev/tty
        echo "}"
    } >> "$BASHRC"
    echo ""
    echo -e "${verde} Creada correctamente la funcion${borra_colores} $nombre"
    sleep 3; clear
}

# ----------------- Borrar interactivo -----------------
borrar_interactivo() {

    # Obtener todos los alias
    mapfile -t alias_list < <(grep -E '^[[:space:]]*alias[[:space:]]+' "$BASHRC" | sed -E 's/alias[[:space:]]+([^=]+)=.*/\1/')

    # Obtener todas las funciones
    mapfile -t func_list < <(awk '/^[[:space:]]*(function[[:space:]]+)?[[:space:]]*[^[:space:]]+[[:space:]]*\(\)[[:space:]]*\{/{gsub(/^[[:space:]]*(function[[:space:]]+)?/,""); gsub(/[[:space:]]*\(\)[[:space:]]*\{/,""); print $0}' "$BASHRC")

    # Combinar alias y funciones en una lista con indicador
    combined_list=()
    for a in "${alias_list[@]}"; do combined_list+=("$a (alias)"); done
    for f in "${func_list[@]}"; do combined_list+=("$f (func)"); done

    # Selección interactiva con fzf (multi-select)
    selected=$(printf '%s\n' "${combined_list[@]}" | fzf --multi \
        --reverse \
        --border  \
        --prompt='Selecciona alias/función a borrar: ' \
        --preview-window=right:80:wrap \
        --preview 'bash -c "
echo === Listado de Alias y Funciones ===
echo ""
cat $HOME/.alias_funciones.txt

"')

    [[ -z "$selected" ]] && { echo "No se seleccionó nada."; return; }

    # Iterar sobre los seleccionados
    while read -r item; do
        nombre=${item%% *}  # Quitar el indicador (alias/func)
        tipo=${item##* }    # Obtener tipo

        if [[ "$tipo" == "(alias)" ]]; then
            sed -i "/^[[:space:]]*alias[[:space:]]\+$nombre=/d" "$BASHRC"
            echo -e "${verde} Alias eliminado:${borra_colores} $nombre"; sleep 1
        elif [[ "$tipo" == "(func)" ]]; then
            awk -v fn="$nombre" '
            BEGIN { skip=0; brace=0 }
            {
                if (skip) {
                    brace += gsub(/\{/, "{")
                    brace -= gsub(/\}/, "}")
                    if (brace <= 0) skip=0
                    next
                }
                if ($0 ~ "^(function[[:space:]]+)?[[:space:]]*" fn "[[:space:]]*\\(\\)[[:space:]]*\\{") {
                    skip=1
                    brace=1
                    next
                }
                print
            }' "$BASHRC" > "$BASHRC.tmp" && mv "$BASHRC.tmp" "$BASHRC"
            echo -e "${verde} Función eliminada:${borra_colores} $nombre"; sleep 1
        fi
    done <<< "$selected"
}
 
# ----------------- Listar -----------------
listar_alias_funciones() {
    OUTPUT_FILE="$HOME/.alias_funciones.txt"
    BASHRC="$HOME/.bashrc"  # Asegúrate de que BASHRC apunta a tu archivo de configuración

    {
        # === Alias ===
        alias_count=$(grep -c "^alias " "$BASHRC")
        echo "=== Alias ($alias_count encontrados) ==="
        grep "^alias " "$BASHRC"
        echo

        # === Funciones ===
        # Extraemos todas las funciones
        funcs=$(awk '
        /^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ {
            in_func=1
            brace=0
            print
            brace += gsub(/\{/, "{")
            brace -= gsub(/\}/, "}")
            next
        }
        {
            if(in_func){
                print
                brace += gsub(/\{/, "{")
                brace -= gsub(/\}/, "}")
                if(brace==0){in_func=0; print ""}
            }
        }' "$BASHRC")

        # Contamos solo las cabeceras de funciones
        func_count=$(echo "$funcs" | grep -E "^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{" | wc -l)
        echo "=== Funciones ($func_count encontradas) ==="
        echo "$funcs"

    } > "$OUTPUT_FILE"

}

# ----------------- Menú interactivo avanzado -----------------
menu() {
    opciones=("Crear Alias" "Crear Función" "Borrar Alias/Función" "Backup Alias/Funciones" "Restaurar Backup" "Salir")

    while true; do
	menu_info
	listar_alias_funciones

        op=$(printf '%s\n' "${opciones[@]}" | fzf --height 20 --reverse --border --prompt="Opciones del menu :" \
    --header="Usa los cursores para seleccionar y puedes hacer scroll en la info ->" \
    --preview-window=right:80:wrap \
    --preview 'bash -c "
echo === Descripcion de la opcion selecionada ===; echo
declare -A d
d[\"Crear Alias\"]=\"Crea un nuevo alias en tu bashrc.\"
d[\"Crear Función\"]=\"Crea una nueva función interactiva en tu bashrc.\"
d[\"Borrar Alias/Función\"]=\"Selecciona y borra aliases o funciones existentes.\"
d[\"Backup Alias/Funciones\"]=\"Crea un backup de todos los aliases y funciones.\"
d[\"Restaurar Backup\"]=\"Restaura un backup evitando duplicados.\"
d[\"Salir\"]=\"Salir del script.\"
echo \"\${d[{}]}\"
echo ""
cat $HOME/.alias_funciones.txt

"')

        case "$op" in
            "Crear Alias") crear_alias ;;
            "Crear Función") crear_funcion ;;
            "Borrar Alias/Función") borrar_interactivo ;;
            "Backup Alias/Funciones") backup_aliases_funciones ;;
            "Restaurar Backup") restaurar_backup ;;
            "Salir") rm $HOME/.alias_funciones.txt; ctrl_c ;;
        esac
    done
}

menu_info(){
#muestra el menu de sukigsx
clear
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores} $archivo_local"
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} $descripcion"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo scripts@mbbsistemas.com) (Web https://repositorio.mbbsistemas.es)${borra_colores}"
echo ""
}

# ----------------- Inicio -----------------
clear
menu
