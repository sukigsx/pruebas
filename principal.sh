#!/usr/bin/env bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="ppsskjhlkjhlkjh"
export DescripcionDelScript="PRUEBA DE MEJORA"
export Correo="scripts@mbbsistemas.es"
export Web="https://repositorio.mbbsistemas.es"
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="Sin comprobar"
paqueteria="No detectada"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="principal.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas.git" #contiene la direccion de github para actualizar el script
nombre_carpeta_repositorio="pruebas" #poner el nombre de la carpeta cuando se clona el repo para poder eliminarla

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        #requeridos para poder actualizar
        [git]="git"
        [diff]="diff"
        [sudo]="sudo"
        [ping]="ping"
        [xdg-user-dir]="xdg-user-dirs"

        #requeridos para el script en si
        [fzf]="fzf"
        [setfacl]="acl"
        )

###########################
## FUNCIONES PRINCIPALES ##
###########################
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
echo -e "${rosa}                                    ${azul}   Sistema paqueteria =${borra_colores} $paqueteria"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} ( Correo${rosa} $Correo${borra_colores} ) ( Web${rosa} $Web${borra_colores} )${borra_colores}"
echo ""
}

#comprobar si hay actualizaciones y que lo marque en el menu_info y tambien pregunta si quieres actualizar
comprobar_actualizaciones(){

    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1
    diff $ruta_ejecucion/$NombreScriptActualizar /tmp/comprobar/$NombreScriptActualizar >/dev/null 2>&1

    if [ $? = 0 ]
    then
        #esta actualizado, solo lo comprueba
        actualizado="SI"
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    else
        #hay que actualizar, comprueba y actualiza
        echo ""
        echo -e "${amarillo} Existe una actualizacion del script${borra_colores}"
        read -p " Quieres actualizar ? (S/n): " sino
        if [[ $sino == [sS] ]]; then
            actualizar_script
        else
            actualizado="NO"
        fi
        chmod -R +w /tmp/comprobar
        rm -R /tmp/comprobar
    fi
}

#funcion para actualizar el script
actualizar_script(){
    git clone $DireccionGithub /tmp/comprobar >/dev/null 2>&1

    cp -r /tmp/comprobar/* $ruta_ejecucion
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} Sera necesario ejecutarlo de nuevo.${borra_colores}"

    printf " Actualizando... "
    for i in {1..20}; do
        printf "#"
        sleep 0.1
    done
    printf " [ \e[32mOK\e[0m ]\n"

    echo ""
    sleep 1
    exit
}

#funcion para comprobar el software necesario
software_necesario(){
#funcion software necesario
#para que funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: which
paqueteria
echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
for comando in "${!requeridos[@]}"; do
        command -v $comando &>/dev/null
        sino=$?
        contador=1
        while [ $sino -ne 0 ]; do
            if [ $contador -ge 4 ] || [ "$conexion" = "no" ]; then
                clear
                menu_info
                echo -e " ${amarillo}NO se puede ejecutar el script sin los paquetes necesarios ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}NO se ha podido instalar ${rojo}${requeridos[$comando]}${amarillo}.${borra_colores}"
                echo -e " ${amarillo}Inténtelo usted con: (${borra_colores}$instalar${requeridos[$comando]}${amarillo})${borra_colores}"
                echo -e ""
                echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
                for elemento in "${requeridos[@]}"; do
                    echo -e "     $elemento"
                done
                echo ""
                echo -e " ${rojo}No se puede ejecutar el script sin todo el software necesario.${borra_colores}"
                echo ""
                exit 1
            else
                echo -e "${amarillo} Se necesita instalar ${borra_colores}$comando${amarillo} para la ejecucion del script${borra_colores}"
                ### check_root
                echo " Instalando ${requeridos[$comando]}. Intento $contador/3."
                $instalar ${requeridos[$comando]} &>/dev/null
                let "contador=contador+1"
                command -v $comando &>/dev/null
                sino=$?
            fi
        done
        echo -e " [${verde}ok${borra_colores}] $comando (${requeridos[$comando]})."
    done

    echo ""
    echo -e "${azul} Todo el software ${verde}OK${borra_colores}"
    software="SI"
}

# Función que comprueba si se ejecuta como root
check_root() {
    #clear
    #menu_info
  if [ "$EUID" -ne 0 ]; then
    #echo ""
    #echo -e "${amarillo} Se necesita privilegios de root ingresa la contraseña.${borra_colores}"

    # Pedir contraseña para sudo
    #echo -e ""

    # Validar contraseña mediante sudo -v (verifica sin ejecutar comando)
    if sudo -v; then
      echo ""
      echo -e "${verde} Autenticación correcta. Ejecutando como root...${borra_colores}"; sleep 2
      # Reejecuta el script como root
      #exec sudo "$0" "$@"
    else
      clear
      menu_info
      echo -e "${rojo} Contraseña incorrecta o acceso denegado. Saliendo del script.${borra_colores}"
      echo ""
      echo -e "${azul} Listado de los paquetes necesarios para poder ejecutar el script:${borra_colores}"
      for elemento in "${requeridos[@]}"; do
        echo -e "     $elemento"
      done
      echo ""
      echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
     echo ""; exit
    fi
  fi
}

#funcion de detectar sistema de paquetado para instalar
paqueteria(){
echo ""
echo -e "${azul} Detectando sistema de paquetería...${borra_colores}"
echo ""

if command -v apt >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)${borra_colores}"
    instalar="sudo apt install -y "
    paqueteria="apt"

elif command -v dnf >/dev/null 2>&1; then
    echo -e "${cerde} Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)${borra_colores}"
    instalar="sudo dnf install -y "
    paqueteria="dnf"

elif command -v yum >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: YUM (CentOS, RHEL antiguos)${borra_colores}"
    instalar="sudo yum install -y "
    paqueteria="yum"

elif command -v pacman >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Pacman (Arch Linux, Manjaro)${borra_colores}"
    instalar="sudo pacman -S --noconfirm "
    paqueteria="pacman"

elif command -v zypper >/dev/null 2>&1; then
    echo -e "${verde} Sistema de paquetería detectado: Zypper (openSUSE)${borra_colores}"
    instalar="sudo zypper install -y "
    paqueteria="zypper"

elif command -v apk >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: APK (Alpine Linux)${borra_colores}"
    instalar="sudo apk add --no-interactive "
    paqueteria="apk"

elif command -v emerge >/dev/null 2>&1; then
    echo -e "${verde}Sistema de paquetería detectado: Portage (Gentoo)${borra_colores}"
    instalar="sudo emerge -av "
    paqueteria="emerge"

else
    echo -e "${amarillo} No se pudo detectar un sistema de paquetería conocido.${borra_colores}"
    paqueteria="${rojo}Desconocido${borra_colores}"
fi
#sleep 2
}


#comprobar si se ejecuta en una terminal bash
terminal_bash() {

    shell_actual="$(ps -p $$ -o comm=)"

    if [ "$shell_actual" != "bash" ]; then
        echo -e "${amarillo} Este script ${rojo}NO${amarillo} se está ejecutando en Bash.${borra_colores}"
        echo -e "   Shell detectado: ${rojo}$shell_actual${borra_colores}"
        echo -e "   Puede ocasionar problemas ya que solo está pensado para bash."
        echo -e "   ${rojo}No${borra_colores} se procede con la instalación ni la ejecución."
        echo ""
        echo -e "${azul} GRACIAS POR UTILIZAR MI SCRIPT${borra_colores}"
        echo ""
        exit 1
    fi
}

conexion(){
#funcion de comprobar conexion a internet
#para que funciones necesita:
#   conexion ainternet
#   la paleta de colores
#   software: ping

if ping -c1 -W1 8.8.8.8 &>/dev/null
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

#logica de inicio
clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    comprobar_actualizaciones
    if [ $actualizado = "SI" ]; then
        terminal_bash
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
        terminal_bash
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="NOOOOO"
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

# EMPIEZA EL SCRIPT
sleep 2
clear
#menu_info

# Configuración de colores para los mensajes del script y fzf
VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m' # No Color
CLEAR='\033[2J\033[H'

# Estilo profesional universal
export FZF_DEFAULT_OPTS="
  --color=bg+:#262626,bg:#1c1c1c,spinner:#5fafd7,hl:#5fafd7
  --color=fg:#bcbcbc,header:#5fafd7,info:#af87d7,pointer:#5fafd7
  --color=marker:#5fd787,fg+:#ffffff,prompt:#5fafd7,hl+:#5fafd7
  --reverse
"

# Verificar dependencias básicas
if ! command -v fzf &> /dev/null || ! command -v setfacl &> /dev/null; then
    echo -e "${ROJO}❌ Error: Se requiere 'fzf' y 'acl' (setfacl) para ejecutar este script.${NC}"
    exit 1
fi

#echo -e "$CLEAR"
# 1. SELECCIÓN DE USUARIO
usuario=$(getent passwd | awk -F: '$7 ~ /\/(bash|sh|zsh)$/ {print $1}' | sort | \
    fzf --prompt=" 👥 USUARIO > " \
        --header="==================================================
 GESTOR DE ACL: SELECCIÓN DE USUARIO
==================================================
Selecciona el usuario que deseas gestionar:")

if [ -z "$usuario" ]; then
    echo -e "${ROJO}❌ Operación cancelada: No se seleccionó ningún usuario.${NC}"
    echo ""
    ctrl_c
    #exit 1
fi

echo -e "\n${AZUL}🔍 Analizando el sistema y auditando permisos en tiempo real para: ${VERDE}$usuario${NC}"

# 2. RECOPILACIÓN Y AUDITORÍA EN TIEMPO REAL
rutas_desktop=(
    "/usr/share/applications"
    "/usr/local/share/applications"
    "$HOME/.local/share/applications"
)

lista_base_apps=""

while IFS= read -r f_desktop; do
    [ -z "$f_desktop" ] && continue
    app_name=""
    app_exec=""
    while IFS= read -r linea || [ -n "$linea" ]; do
        [[ "$linea" =~ ^"["[a-zA-Z[:space:]]+"]" && "$linea" != "[Desktop Entry]" ]] && break
        if [[ "$linea" =~ ^Name= && -z "$app_name" ]]; then
            app_name=$(echo "$linea" | cut -d'=' -f2- | sed 's/ *$//')
        elif [[ "$linea" =~ ^Exec= && -z "$app_exec" ]]; then
            app_exec=$(echo "$linea" | cut -d'=' -f2-)
            app_exec=$(echo "$app_exec" | sed -E 's/ %[^ ]+//g' | sed 's/^"//;s/"$//' | awk '{print $1}')
        fi
    done < "$f_desktop"
    if [ -n "$app_name" ] && [ -n "$app_exec" ]; then
        lista_base_apps+="$app_name|$app_exec\n"
    fi
done < <(find "${rutas_desktop[@]}" -name "*.desktop" 2>/dev/null)

lista_base_apps=$(echo -e "$lista_base_apps" | sort -u)

lista_plana_auditada=""
while IFS= read -r app; do
    [ -z "$app" ] && continue
    nombre_app=$(echo "$app" | cut -d'|' -f1)
    comando=$(echo "$app" | cut -d'|' -f2)

    if [[ "$comando" == /* ]]; then
        fichero="$comando"
    else
        fichero=$(command -v "$comando")
    fi

    # Si es nuestro wrapper, auditamos basándonos en el binario real oculto trasero (.real)
    fichero_test="$fichero"
    [ -f "${fichero}.real" ] && fichero_test="${fichero}.real"

    if [ -n "$fichero" ] && [ -f "$fichero_test" ]; then
        if sudo -u "$usuario" test -x "$fichero_test" 2>/dev/null; then
            lista_plana_auditada+="PERMITIDO@@@$nombre_app@@@$fichero\n"
        else
            lista_plana_auditada+="DENEGADO@@@$nombre_app@@@$fichero\n"
        fi
    fi
done <<< "$lista_base_apps"

lista_columnas=$(echo -e "$lista_plana_auditada" | column -t -s "@@@")

lista_final_coloreada=""
while IFS= read -r linea; do
    [ -z "$linea" ] && continue
    if [[ "$linea" == PERMITIDO* ]]; then
        resto=${linea#PERMITIDO}
        lista_final_coloreada+="$(printf "${VERDE}PERMITIDO${NC}%s\n" "$resto")\n"
    elif [[ "$linea" == DENEGADO* ]]; then
        resto=${linea#DENEGADO}
        lista_final_coloreada+="$(printf "${ROJO}DENEGADO${NC}%s\n" "$resto")\n"
    fi
done <<< "$lista_columnas"

# 3. INTERFAZ INTERACTIVA FZF
seleccion=$(echo -e "$lista_final_coloreada" | \
    fzf --ansi \
        --multi \
        --prompt=" 🎯 SELECTOR APLICACIONES > " \
        --header="==================================================
 ESTADO ACTUAL DE PERMISOS PARA: ${VERDE}$usuario${NC}
==================================================
Filtra por nombre o estado (PERMITIDO / DENEGADO).
[TAB] Marcar programas para modificar | [ENTER] Confirmar")

if [ -z "$seleccion" ]; then
    echo -e "${ROJO}❌ Operación cancelada: No se seleccionó ninguna aplicación.${NC}"
    exit 1
fi

binarios_a_modificar=$(echo "$seleccion" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $NF}')

# 4. MENÚ DE ACCIÓN
echo -e "$CLEAR"
opcion=$(printf "🟢 Otorgar permisos de ejecución (+x)\n🔴 Revocar permisos de ejecución (-x)" | \
    fzf --prompt=" 🛠️ ACCIÓN > " \
        --header="==================================================
 SELECCIONA LA ACCIÓN DE CAMBIO (ACL) PARA: ${VERDE}$usuario${NC}
==================================================
¿Qué directiva deseas aplicar a los elementos seleccionados?")

case "$opcion" in
    *"Otorgar"*)
        accion_acl="u:$usuario:rx"
        modo_bloqueo="falso"
        msg="Añadido permiso de ejecución"
        ;;
    *"Revocar"*)
        # Le quitamos el acceso al binario trasero
        accion_acl="u:$usuario:r-"
        modo_bloqueo="verdadero"
        msg="Quitado permiso de ejecución"
        ;;
    *)
        echo -e "${ROJO}❌ Operación cancelada.${NC}"
        exit 1
        ;;
esac

# 5. APLICACIÓN DE CAMBIOS CON WRAPPER DE MENSAJE PERSONALIZADO
echo -e "\n${AZUL}🚀 Aplicando directivas y envoltorios de seguridad...${NC}\n"

echo "$binarios_a_modificar" | while IFS= read -r fichero; do
    if [ -n "$fichero" ] && [ -f "$fichero" ]; then

        # DEFINICIÓN DE RUTAS (Fichero original vs Envoltorio)
        if [ ! -f "${fichero}.real" ]; then
            # Es la primera vez que tocamos este software: movemos el binario original a .real
            sudo mv "$fichero" "${fichero}.real"
        fi

        binario_real="${fichero}.real"

        # Aplicamos la ACL restrictiva o permisiva sobre el ejecutable real trasero
        sudo setfacl -m "$accion_acl" "$binario_real"

        # Volvemos a escribir/actualizar el script wrapper frontal en la ruta original
        # Este script interceptará la llamada y comprobará el acceso del usuario en vivo
        sudo bash -c "cat << 'EOF' > $fichero
#!/bin/bash
# Envoltorio de seguridad automático para control de ACL
BINARIO_REAL=\"$binario_real\"

if test -x \"\$BINARIO_REAL\"; then
    # El usuario actual sí está permitido -> Se lanza el software pasándole sus argumentos originales (\$@)
    exec \"\$BINARIO_REAL\" \"\$@\"
else
    # El usuario actual está bloqueado por el administrador -> Mensaje personalizado
    echo -e \"\n\033[0;31m🚫 SOFTWARE BLOQUEADO: No tienes autorización para ejecutar este programa.\033[0m\n\"

    # Si el usuario está ejecutando desde el escritorio gráfico, lanzamos una alerta emergente limpia
    if [ -n \"\$DISPLAY\" ] && command -v zenity &> /dev/null; then
        zenity --error --title=\"Control de Accesos\" --text=\"🚫 SOFTWARE BLOQUEADO:\nNo tienes autorización para usar este programa.\" --timeout=15 2>/dev/null &
    fi
    exit 130
fi
EOF"

        # Hacemos que el wrapper frontal sea ejecutable de forma global para que todo el mundo pueda llamarlo
        sudo chmod 755 "$fichero"

        echo -e " [${VERDE}OK${NC}] $msg -> ${AZUL}$fichero${NC}"
    fi
done

echo -e "\n${VERDE}✨ Proceso completado con éxito.${NC}\n"





