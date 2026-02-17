#!/usr/bin/env bash

#VARIABLES PRINCIPALES
# con export son las variables necesarias para exportar al los siguientes script
#variables para el menu_info

export NombreScript="Ejecutar_scripts"
export DescripcionDelScript="esto se esta probando"
export Correo=""
export Web=""
export version="1.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"
paqueteria="No detectada"

# VARIABLE QUE RECOJEN LAS RUTAS
ruta_ejecucion=$(dirname "$(readlink -f "$0")") #es la ruta de ejecucion del script sin la / al final
ruta_escritorio=$(xdg-user-dir DESKTOP) #es la ruta de tu escritorio sin la / al final

# VARIABLES PARA LA ACTUALIZAION CON GITHUB
NombreScriptActualizar="Ejecutar_scripts.sh" #contiene el nombre del script para poder actualizar desde github
DireccionGithub="https://github.com/sukigsx/pruebas" #contiene la direccion de github para actualizar el script

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [nano]="nano"
        [diff]="diff"
        [sudo]="sudo"
        [ping]="ping"
        [fzf]="fzf"
        [curl]="curl"
        [grep]="grep"
        [jq]="jq"
        [sed]="sed"
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
echo -e "${rosa}                                    ${azul}   Sistema paqueteria =${borra_colores} $paqueteria"
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
        echo -e "${verde} El script se ha actualizado.${amarillo} Es necesario cargarlo de nuevo.${borra_colores}"
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
paqueteria
echo ""
echo -e "${azul} Comprobando el software necesario.${borra_colores}"
echo ""
#which git diff ping figlet xdotool wmctrl nano fzf
#########software="which git diff ping figlet nano gdebi curl konsole" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
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
sleep 2
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

#comprobar si ya esta instalado.
comprobar_instalado(){
FILE_CHECK="$HOME/.Ejecutar_scripts.config"
BASHRC_FILE="$HOME/.bashrc"

if [ -f "$FILE_CHECK" ] && grep -q "^source /home/$(whoami)/.Ejecutar_scripts.config" "$BASHRC_FILE" 2>/dev/null; then
    while true; do
    clear
    menu_info
    echo ""
    echo -e "${azul} Menu de opciones del Ejecutar_scripts${borra_colores}"
    echo ""
    echo -e "  ${azul}1.${borra_colores} Incluir uno o varios scripts."
    echo ""
    echo -e "  ${azul}2.${borra_colores} Quitar uno o varios scripts."
    echo ""
    echo -e "  ${azul}3.${borra_colores} Guardar tus script."
    echo ""
    echo -e "  ${azul}4.${borra_colores} Instalar scripts de sukigsx"
    echo ""
    echo -e "  ${azul}5.${borra_colores} Ver los scripts wue tienes $(whoami)"
    echo ""
    echo -e " ${azul}10.${borra_colores} Desistalar. (${rojo}Cuidado se borrara el contenido de la carpeta scripts${borra_colores})"
    echo ""
    echo -e " ${azul}90.${borra_colores} Ayuda."
    echo ""
    echo -e " ${azul}99.${borra_colores} Salir."
    echo ""
    read -p " Seleccione una opción (1 - 99): " opcion

    case $opcion in
        1)  # Define las opciones del menú
            options=("" "- Scripts sencillos de un unico fichero sh" "- Aplicaciones mas complejas con varios ficheros y carpetas")

            # Utiliza fzf para mostrar el menú y obtener la selección del usuario
            selected_option=$(printf '%s\n' "${options[@]}" | fzf --prompt="Incluir scripts. (esc = atras)" --header="Selecciona un de las opciones :" --reverse --no-info)

            # Verifica la opción seleccionada y ejecuta el comando correspondiente
            case $selected_option in
                "- Scripts sencillos de un unico fichero sh")
                    #incluir uno o varios scripts
                    clear
                    echo ""
                    echo -e "${rosa} Incluir - Scripts${borra_colores}"
                    # Buscar archivos .sh en el directorio HOME, excluyendo carpetas ocultas
                    #files=$(find /home/$(whoami) -type f -name "*.sh" | grep -v '/\.')
                    files=$(find "/home/$(whoami)/" -type f -name "*.sh" -not -path '*/\.*' -not -path "/home/$(whoami)/scripts/*" -not -path "/home/$(whoami)/ejecutar_scripts/*")
                    # Usar fzf para la selección múltiple
                    selected_files=$( echo "$files" | fzf --multi --height 80% --reverse --prompt="Selecciona scripts: Info: (tab = Marcar multiple) (Enter = Seleccionar) (Esc = Salir))" --header="Scripts encontrados en tu carpeta HOME de usuario :" --no-info)
                    # Copiar los archivos seleccionados a /home/sukigsx/scripts
                    if [ -n "$selected_files" ]; then
                        echo "$selected_files" | xargs -I {} cp {} /home/$(whoami)/scripts/
                        echo ""
                        echo -e "${verde} Archivos copiados correctamente.${borra_colores}"; sleep 2
                    else
                        echo ""
                        echo -e "${amarillo} Ningun archivo seleccionado.${borra_colores}"; sleep 2
                    fi
                    ;;

                "- Aplicaciones mas complejas con varios ficheros y carpetas")
                    # Utiliza fzf para seleccionar una carpeta o directorio
                    selected_dir=$(find /home/$(whoami) -type f -name "*.sh" -exec dirname {} \; | sort -u | fzf --reverse --prompt="Incluir aplicacion en bash. (esc = atras)" --header="Seleciona la carpeta donde esta la aplicacion :" --no-info)

                    # Verifica si se ha seleccionado una carpeta
                    if [ -n "$selected_dir" ]; then
                        # Copia el contenido de la carpeta seleccionada a /home/usuario/scripts
                        cp -r "$selected_dir"/* /home/$(whoami)/scripts/
                        echo ""
                        echo -e "${verde} Contenido de la carpeta copiado exitosamente a /home/$(whoami)/scripts/${borra_colores}"; sleep 2
                    else
                        echo ""
                        echo -e "${verde}No se seleccionó ninguna carpeta.${borra_colores}"; sleep 2
                    fi
                    ;;
            *)
                    echo "Opción no válida"
                    ;;
            esac
            ;;

        2)  # Utiliza fzf para seleccionar una carpeta o directorio
            selected_dirs=$(find /home/$(whoami)/scripts -mindepth 1 -maxdepth 1 ! -name "ejecutar_scripts.sh" | fzf --reverse --prompt="Selecciona scripts y carpetas: Info: (tab = Marcar múltiples) (Enter = Seleccionar) (Esc = Salir)" --header="Selecciona lo que quieres borrar:" --no-info --multi)

            for borrar in $selected_dirs; do
                sudo rm -r $borrar
                echo ""
                echo -e "${verde}Carpeta/Fichero ${borra_colores}$borrar${verde} borrado exitosamente de /home/$(whoami)/scripts/${borra_colores}"; sleep 2
            done
            ;;


        3)  #guardar tus scripts
            clear
            echo ""
            echo -e "${rosa} Guardar - Scripts ${borra_colores}"
            echo ""
            read -p " Dime la ruta absoluta en donde guardar tus scripts -> " ruta_guardar
            if [ -d $ruta_guardar ]
            then
                echo ""
                # Buscar archivos .sh en el directorio HOME, excluyendo carpetas ocultas
                files=$(find "/home/$(whoami)/scripts/" -type f -name "*.sh" ! -name "ejecutar_scripts.sh")
                # Usar fzf para la selección múltiple
                selected_files=$( echo "$files" | fzf --multi --height 80% --reverse --prompt="Selecciona scripts: Info: (tab = Marcar multiple) (Enter = Seleccionar) (Esc = Salir)" --no-info)
                # Copiar los archivos seleccionados a /home/sukigsx/scripts
                if [ -n "$selected_files" ]; then
                    echo "$selected_files" | xargs -I {} cp 2>/dev/null {} $ruta_guardar
                    echo ""
                    echo -e "${verde} Archivos guardados correctamente en $ruta_guardar ${borra_colores}"; sleep 2
                else
                    echo ""
                    echo -e "${amarillo} Ningun archivo seleccionado.${borra_colores}"; sleep 2
                fi
            else
                echo ""
                mkdir $ruta_guardar
                echo -e "${amarillo} Creando carpeta de destino (${borra_colores}$ruta_guardar${amarillo})${verde} OK ${borra_colores}"
                mkdir $ruta_guardar 2>/dev/null
                echo ""
                # Buscar archivos .sh en el directorio HOME, excluyendo carpetas ocultas
                files=$(find "/home/$(whoami)/scripts/" -type f -name "*.sh" ! -name "ejecutar_scripts.sh")
                # Usar fzf para la selección múltiple
                selected_files=$( echo "$files" | fzf --multi --height 80% --reverse --prompt="Selecciona scripts: Info: (tab = Marcar multiple) (Enter = Seleccionar) (Esc = Salir)" --no-info)
                # Copiar los archivos seleccionados a /home/sukigsx/scripts
                if [ -n "$selected_files" ]; then
                    echo "$selected_files" | xargs -I {} cp 2>/dev/null {} $ruta_guardar
                    echo ""
                    echo -e "${verde} Archivos guardados correctamente en $ruta_guardar ${borra_colores}"; sleep 2
                else
                    echo ""
                    echo -e "${amarillo} Ningun archivo seleccionado.${borra_colores}"; sleep 2
                fi
            fi
            ;;

        4)
            clear
            echo ""
            echo -e "${rosa} Scripts-sukigsx ${borra_colores}"
            echo ""

            # Obtener repositorios (excluyendo algunos)
            repos=$(curl -s "https://api.github.com/users/sukigsx/repos" \
            | jq -r '.[].name' \
            | grep -vE 'sukigsx.github.io|ejecutar_scripts')

            echo -e "${azul} Lista de repositorios de sukigsx.${borra_colores}"
            echo ""

            PS3="Selecciona un repositorio: "

            select repo in $repos "Salir"; do

            # Validar selección inválida
            if [[ -z "$repo" ]]; then
                echo ""
                echo -e "${rojo} Opción inválida. Selecciona un número de la lista.${borra_colores}"
                echo ""
                continue
            fi

            case "$repo" in
            "Salir")
                echo "Saliendo..."
                break
                ;;
            *)
                echo ""
                echo -e "${verde}Seleccionaste el repositorio:${borra_colores} $repo"
                sleep 1

                DEST="/home/$(whoami)/scripts/$repo"

                # Clonar repositorio
                if ! git clone "https://github.com/sukigsx/$repo.git" "$DEST" > /dev/null 2>&1; then
                    echo -e "${rojo}Error al clonar el repositorio.${borra_colores}"
                    continue
                fi

                # Copiar contenido
                cp -r "$DEST/"* "/home/$(whoami)/scripts/"

                # Eliminar repositorio clonado
                rm -rf "$DEST" > /dev/null 2>&1

                echo -e "${verde}Archivos del repositorio${borra_colores} $repo ${verde}han sido copiados a${borra_colores} /home/$(whoami)/scripts/${borra_colores}"
                sleep 2
                break
                ;;
            esac
            done
            ;;

        5)  #ver los scripts
            clear
            menu_info
            echo ""
            echo -e "${azul} Listado de los scripts actuales en /home/$(whoami)/scripts${borra_colores}"
            echo ""
            ls -1 /home/$(whoami)/scripts/*.sh 2>/dev/null | xargs -n 1 basename
            echo -e "${azul}"
            read -p " Pulsa una tecla para continuar" pause
            echo -e ${borra_colores}
            ;;

        10)  #desistalar
            echo ""
            echo -e "${verde} Desistalando:${borra_colores}"
            echo ""
            echo -e " Eliminado carpeta (scripts) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; rm -r /home/$(whoami)/scripts 2>/dev/null; sleep 1
            echo -e " Eliminado fichero de configuracion (Ejecutar_scripts.config) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; rm /home/$(whoami)/.Ejecutar_scripts.config 2>/dev/null; sleep 1
            echo -e " Eliminada la entrada en (.bashrc) [${verde}ok${borra_colores}]."; sed -i "\|^source $HOME/.Ejecutar_scripts.config$|d" "$HOME/.bashrc"; sleep 1
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
            echo -e "${amarillo} Opción no válida. Por favor, seleccione 1 o 99.${borra_colores}"
            sleep 3
            ;;
    esac
    done
else
    echo -e "${verde} Instalando:${borra_colores}"
    echo ""

    #comprueba si existe la carpeta /home/usuario/.config y si no esta la crea
    if [ -d /home/$(whoami)/scripts ]
    then
        echo ""
    else
        # Crear la carpeta .config si no existe
        echo -e " Creando carpeta (scripts) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; mkdir /home/$(whoami)/scripts; sleep 1
    fi

    echo -e " Creando fichero de configuracion (Ejecutar_scripts.config) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; cp Ejecutar_scripts.config /home/$(whoami)/.Ejecutar_scripts.config; sleep 1
    echo -e " Creando entrada en (.bashrc) [${verde}ok${borra_colores}]."; echo "source /home/$(whoami)/.Ejecutar_scripts.config" >> /home/$(whoami)/.bashrc; sleep 1
    echo -e " Incluyendo este script a tu carpeta de scripts [${verde}ok${borra_colores}]."; cp Ejecutar_scripts.sh /home/$(whoami)/scripts/; sleep 1
    echo ""
    echo -e " Instalacion completada [${verde}ok${borra_colores}] ."
    echo ""
    echo -e "${amarillo} Tienes que reiniciar la terminal para que surjan efecto los cambios.${borra_colores}"
    echo ""
    exit
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
comprobar_instalado

