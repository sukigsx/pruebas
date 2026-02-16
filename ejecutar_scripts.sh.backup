#!/bin/bash

#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"
rojo="\e[0;31m\033[1m" #rojo
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m" #borra colores

if [ -d "/home/$(whoami)/scripts" ] || grep -q "source /home/$(whoami)/.config/ejecutar_scripts.config" "/home/$(whoami)/.bashrc"
then
    echo ""
else
    clear
    echo ""
    echo -e "${verde} Hola ${borra_colores}$(whoami)."
    echo ""
    echo -e "${amarillo} El software de ejecutar_scripts${rojo} NO ${amarillo}esta instalado en tu sistema.${borra_colores}"
    echo ""
    echo -e "${azul} Tienes que ejecutar primero el instalador con la orden:${borra_colores}"
    echo -e "  (./instalar.sh) o (bash instalar.sh)"
    echo ""
    echo -e "${azul} Tambien pueden ver mas informacion en:${borra_colores}"
    echo -e "  https://github.com/sukigsx/ejecutar_scripts/blob/main/README.md"
    echo ""
    exit
fi




#toma el control al pulsar control + c
trap ctrl_c INT
function ctrl_c()
{
clear
echo " ${verde}- Gracias por utilizar mi script -${borra_colores}"
exit
}

conexion(){
if ping -c1 google.com &>/dev/null
then
    #echo ""
    #echo -e " Conexion a internet [${verde}ok${borra_colores}]."
    var_conexion="si"
    #echo ""
else
    #echo ""
    #echo -e " Conexion a internet [${rojo}ko${borra_colores}]."
    var_conexion="no"
    echo ""
fi
}

software_necesario(){
var_software="no"
echo -e " Verificando software necesario:"
software="which git diff ping apt fzf curl jq" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
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
            read pause
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

actualizar_script(){
archivo_local="ejecutar_scripts.sh" # Nombre del archivo local
ruta_repositorio="https://github.com/sukigsx/ejecutar_scripts.git" #ruta del repositorio para actualizar y clonar con git clone

# Obtener la ruta del script
descarga=$(dirname "$(readlink -f "$0")")
#descarga="/home/$(whoami)/scripts"
git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


if [ $? = 0 ]
then
    #esta actualizado, solo lo comprueba
    echo ""
    #echo -e "${verde} El script${borra_colores} $0 ${verde}esta actualizado.${borra_colores}"
    #echo ""
    var_actualizado="si"
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
else
    #hay que actualizar, comprueba y actualiza
    echo ""
    echo -e "${amarillo} EL script${borra_colores} $0 ${amarillo}NO esta actualizado.${borra_colores}"
    echo -e "${verde} Se procede a su actualizacion automatica.${borra_colores}"
    sleep 3
    mv /tmp/comprobar/$archivo_local $descarga
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${verde} El script se ha actualizado.${borra_colores}"
    sleep 2
    exit
    #kill -9 $(ps -o ppid= -p $$)
    #xdotool windowkill `xdotool getactivewindow`
fi
}

conexion

if [ $var_conexion = "si" ]
then
    var_conexion="si"
    software_necesario
    actualizar_script
else
    var_conexion="no"
    software_necesario
    var_software="si"
    var_actualizado="Imposible comprobar sin conexion a internet"
fi




while true; do
echo ""
clear
#maximiza la terminal.
#wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
echo -e "${rosa} - EJECUTAR SCRIPTS -${borra_colores}"
echo ""
echo -e "${verde} Diseñado por sukigsx / Contacto:   scripts@mbbsistemas.es${borra_colores}"
echo -e "${verde}                                    https://repositorio.mbbsistemas.es${borra_colores}"
echo ""
echo -e "${verde} Nombre del script < $0 > Instalador automatico.  ${borra_colores}"
echo ""
echo -e "${azul}   Conexion a internet  =${borra_colores} $var_conexion"
echo -e "${azul}   Software_necesario   =${borra_colores} $var_software"
echo -e "${azul}   Software actualizado =${borra_colores} $var_actualizado"
    echo ""
    echo -e "${rosa}- Menu - Opciones -${borra_colores}"
    echo ""
    echo -e "  ${azul}1.${borra_colores} Incluir uno o varios scripts."
    echo ""
    echo -e "  ${azul}2.${borra_colores} Quitar uno o varios scripts."
    echo ""
    echo -e "  ${azul}3.${borra_colores} Guardar tus script."
    echo ""
    echo -e "  ${azul}4.${borra_colores} Instalar scripts de sukigsx"
    echo ""
    echo -e "  ${azul}5.${borra_colores} Opcion vacia, para posibles actualizaciones"
    echo ""
    echo -e " ${azul}10.${borra_colores} Desistalar. (${rojo}Cuidado se borrara el contenido de la carpeta scripts${borra_colores})"
    echo ""
    echo -e " ${azul}90.${borra_colores} Ayuda."
    echo ""
    echo -e " ${azul}99.${borra_colores} Salir."
    echo ""
    read -p " ¿ Que hacemos ?, Seleccione una opción : " opcion

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

        5)  #opcion vacia para posibles actualizaciones
            ;;

        10) #desistalar
            echo ""
            echo -e "${verde} Desistalando:${borra_colores}"
            echo ""
            echo -e " Eliminado carpeta (scripts) en /home/$(whoami)/ [${verde}ok${borra_colores}]."; rm -r /home/$(whoami)/scripts; sleep 1
            echo -e " Eliminado fichero de configuracion (ejecutar_scripts.congig) en /home/$(whoami)/.config/ [${verde}ok${borra_colores}]."; rm /home/$(whoami)/.config/ejecutar_scripts.config; sleep 1
            echo -e " Eliminada la entrada en (.bashrc) [${verde}ok${borra_colores}]."; sed -i "/source \/home\/$(whoami)\/.config\/ejecutar_scripts.config/d" /home/$(whoami)/.bashrc; sleep 1
            echo ""
            echo -e "${verde} Desistalacion completa.${borra_colores}"
            echo ""
            echo -e "${amarillo} Tienes que reiniciar la terminal para que surjan efecto los cambios.${borra_colores}"
            echo ""
            exit
            ;;

        90) #ayuda
            clear
            echo ""
            echo -e "${rosa} Ayuda-Scripts ${borra_colores}"
            echo -e "${azul}# ejecutar_scripts${borra_colores}"
            echo ""
            echo "El script proporcionado es una herramienta interactiva que permite a los usuarios ejecutar scripts Bash almacenados en un directorio específico."
            echo "A continuación, se describe cómo utilizar este script:"
            echo ""
            echo -e "${azul}## Ejecutar el script:${borra_colores}"
            echo "Vasta con teclear (scripts) en la linea de comandos de tu terminal. Se cargara el menu interactivo."
            echo "Si no has colocado ningun script, solo aparecera el script de control (ejecutar_scripts.sh)."
            echo ""
            echo -e "${azul}## Interactuar con el Menú de seleccion:${borra_colores}"
            echo "Al ejecutar el script, verás una lista de tus scripts Bash disponibles."
            echo "Utiliza las teclas de flecha hacia arriba y abajo para navegar por la lista de scripts."
            echo "Presiona la tecla Enter para seleccionar un script y ejecutarlo."
            echo "Si deseas salir del menú, selecciona (Salir) y presiona Enter."
            echo "Selecciona (Ayuda) para obtener información sobre cómo utilizar el menú interactivo. Sigue las instrucciones proporcionadas en la pantalla."
            echo "Puedes seleccionar varios scripts presionando la tecla Tab después de seleccionar un script. Una vez que hayas terminado la selección, presiona Enter para ejecutar los scripts seleccionados."
            echo ""
            echo -e "${azul}## Notas Adicionales:${borra_colores}"
            echo "Ten en cuenta que este script se basa en la utilidad fzf, lo que facilita la selección interactiva de scripts."
            echo "Consideraciones de Seguridad:"
            echo ""
            echo -e "${azul}# script de control${borra_colores}"
            echo "El script de control es el fichero (ejecutar_scripts.sh)"
            echo ""
            echo -e "${azul}## Definición de colores:${borra_colores}"
            echo "El script define varias variables que contienen códigos de colores ANSI para facilitar la salida de texto con colores en la terminal."
            echo ""
            echo -e "${azul}## Comprueba los programas necesarios:${borra_colores}"
            echo "Comprueba (git, diff, ping, apt y fzf) que están instalados en el sistema."
            echo "Si falta alguno de estos programas, intenta instalarlo automáticamente utilizando apt."
            echo "Si no puede instalar el software después de tres intentos o si no hay conexión a Internet, muestra un mensaje de error y termina el script."
            echo ""
            echo -e "${azul}## Actualización automática del script:${borra_colores}"
            echo "Comprueba si el script actual (ejecutar_scripts.sh) está actualizado en comparación con una versión en un repositorio de Git."
            echo "Si está actualizado, muestra un mensaje indicando que no es necesario actualizarlo."
            echo "Si no está actualizado, descarga la versión más reciente del repositorio de Git y reemplaza el script local con la versión descargada."
            echo "Luego, cierra la terminal actual para que los cambios surtan efecto y el usuario deba abrir una nueva terminal para usar el script actualizado."
            echo ""
            echo -e "${azul}## Menú de opciones:${borra_colores}"
            echo "Muestra un menú interactivo en la terminal que permite al usuario realizar varias acciones, como incluir o quitar scripts, guardar scripts en una ubicación específica, desinstalar el script, y salir del programa."
            echo "Las opciones del menú están numeradas y el usuario puede seleccionar una opción ingresando el número correspondiente."
            echo ""
            echo -e "${azul}### Funcionalidades específicas:${borra_colores}"
            echo ""
            echo -e "${azul}#### Incluir Scripts:${borra_colores}"
            echo "Permite al usuario seleccionar uno o varios archivos de script (archivos.sh) en el sistema y copiarlos a la carpeta /home/tu_usuario/scripts/."
            echo ""
            echo -e "${azul}#### Quitar Scripts:${borra_colores}"
            echo "Permite al usuario seleccionar uno o varios archivos o carpetas de script existentes en la carpeta /home/tu_usuario/scripts/ y eliminarlos."
            echo ""
            echo -e "${azul}#### Guardar Scripts:${borra_colores}"
            echo "Permite al usuario seleccionar uno o varios archivos de script existentes en la carpeta /home/tu_usuario/scripts/ y copiarlos a una ubicación específica proporcionada por el usuario."
            echo ""
            echo -e "${azul}#### Desinstalar:${borra_colores}"
            echo "Elimina la carpeta scripts en /home/tu_usuario/, elimina el archivo de configuración ejecutar_scripts.config en /home/tu_usuario/.config/, y elimina la entrada correspondiente en .bashrc para desinstalar completamente el script."
            echo ""
            echo -e "${azul}## Salida segura del script:${borra_colores}"
            echo "La función ctrl_c captura la señal Ctrl+C y muestra un mensaje de agradecimiento antes de cerrar la terminal activa."
            echo "En resumen, el script proporciona una interfaz interactiva para gestionar scripts en un sistema Linux, asegurándose de que los programas necesarios estén instalados y permitiendo al usuario incluir, quitar y guardar" echo "scripts de manera fácil y rápida. Además, ofrece una funcionalidad de actualización automática desde un repositorio de Git."
            echo ""
            echo "Asegúrate de que los scripts que planeas ejecutar sean seguros y de confianza, ya que este script permite ejecutar scripts sin confirmación adicional."
            echo "Recuerda que este script es interactivo y te proporciona una forma conveniente de ejecutar tus scripts Bash de manera fácil y rápida."
            echo "¡Disfruta automatizando tus tareas con este menú interactivo!"
            echo ""
            echo -e "${azul}# Instalacion${borra_colores}"
            echo "Simplemente debes clonar el repositorio con la orden:"
            echo "git clone https://github.com/sukigsx/ejecutar_scripts.git"
            echo ""
            echo "Entras en la carpeta y ejecutas instalar.sh con la orden:"
            echo "./instalar.sh o bien con bash instalar.sh"
            echo ""
            echo -e "${azul}# ¡Disfruta automatizando tus tareas con este menú interactivo!${borra_colores}"
            read p
            ;;

        99)  #Saliendo del programa.
            ctrl_c
            ;;

        *)
            echo ""
            echo -e "${rojo}Opción no válida. Por favor, seleccione numero menu valido.${borra_colores}"
            sleep 3
            ;;
    esac
done
