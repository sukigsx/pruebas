#!/bin/bash

#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"
#which git diff ping apt curl awk

ruta_ejecucion=$(dirname "$(readlink -f "$0")")
export version="2.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

# Archivo de estado para controlar si ya se realizó la configuración inicial
estado_config="/etc/samba/.config_inicial_ok"

menu_info(){
#muestra el menu de sukigsx
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores}  $0 "
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripcion${borra_colores} Software de configuracion/creacion usuarios y permisos samba"
echo -e "${rosa} / __| | | | |/ / |/ _\ / __\ \/ /  ${azul}   Version            =${borra_colores} $version"
echo -e "${rosa} \__ \ |_| |   <| | (_| \__ \>  <   ${azul}   Conexion Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\__,_|_|\_\_|\__, |___/_/\_\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo -e ""
echo -e "${azul} Contacto:${borra_colores} (Correo scripts@mbbsistemas.com) (Web https://repositorio.mbbsistemas.es)${borra_colores}"
echo ""
}

actualizar_script(){
#actualizar el script
#para que esta funcion funcione necesita:
#   conexion a internet
#   la paleta de colores
#   software: git diff xdotool
archivo_local="ManagerSambaServer.sh" # Nombre del archivo local
ruta_repositorio="https://github.com/sukigsx/pruebas.git" #ruta del repositorio para actualizar y clonar con git clone

# Obtener la ruta del script
descarga=$(dirname "$(readlink -f "$0")")
git clone $ruta_repositorio /tmp/comprobar >/dev/null 2>&1

diff $descarga/$archivo_local /tmp/comprobar/$archivo_local >/dev/null 2>&1


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
    cp -r /tmp/comprobar/* $descarga
    chmod -R +w /tmp/comprobar
    rm -R /tmp/comprobar
    echo ""
    echo -e "${amarillo} El script se ha actualizado, es necesario cargarlo de nuevo.${borra_colores}"
    echo ""
    sleep 2
    exit
fi
}

#VARIABLES DE SOFTWARE NECESARIO
# Asociamos comandos con el paquete que los contiene [comando a comprobar]="paquete a instalar"
    declare -A requeridos
    requeridos=(
        [git]="git"
        [diff]="diff"
        [curl]="curl"
        [smbstatus]="samba"
        [getfacl]="acl"
        [awk]="awk"
        [hostname]="hostname"
    )

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



# ========================
# Funcion crear_total (script completo 1)
# ========================
crear_total() {
# Funcion para crear usuarios
crear_usuarios() {
clear
menu_info
while true; do
    echo ""
    echo -e "${verde}CREACION DE USUARIOS${borra_colores}"
    echo ""
    echo -e "${azul}Lista de usuarios actuales${borra_colores}"; echo ""
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd

    usuarios=()      # Array para almacenar los nombres de usuario
    contrasenas=()   # Array para almacenar las contraseñas
    login_enabled=() # Array para almacenar si el usuario tendrá login

    #while true; do
        echo ""

        # Validar nombre de usuario
        while true; do
            read -p "Ingrese el nombre del usuario (o 'ok' para terminar): " usuario

            if [ "$usuario" == "ok" ]; then
                break 2  # Salir del while principal
            fi

            # Comprobar que no esté vacío y solo contenga caracteres válidos
            if [[ -z "$usuario" ]]; then
                echo ""
                echo -e "${rojo}El nombre de usuario no puede estar vacío.${borra_colores}"
            elif [[ ! "$usuario" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo ""
                echo -e "${rojo}El nombre de usuario solo puede contener letras, números y guiones bajos.${borra_colores}"
            else
                break
            fi
        done

        # Preguntar por la contraseña del usuario
        read -p "Ingrese la contraseña para $usuario: " pass

        # Añadir el usuario a Samba
        echo "$pass" | sudo smbpasswd -a "$usuario"

        # Preguntar si el usuario tendrá login
        echo ""
        while true; do
            read -p "Desea que $usuario tenga acceso al login del sistema? (s/n): " login

            if [[ "$login" =~ ^[sS]$ ]]; then
                echo ""
                echo -e "${verde}Has elegido que${borra_colores} $usuario ${amarillo}SI${verde} tenga acceso al login${borra_colores}"
                sleep 2; break   # sale del bucle porque ya es válido
            elif [[ "$login" =~ ^[nN]$ ]]; then
                echo ""
                echo -e "${verde}Has elegido que${borra_colores} $usuario${verde} ${amarillo}NO${verde} tenga acceso al login${borra_colores}"
                sleep 2; break   # sale del bucle porque ya es válido
            else
                echo -e "${rojo} Opción no válida. Debe ser 's' o 'n'${borra_colores}"
                sleep 2
            fi
        done

        # Almacenar los datos en los arrays
        usuarios+=("$usuario")
        contrasenas+=("$pass")
        login_enabled+=("$login")

        echo -e "${verde}Usuario agregado correctamente.${borra_colores}"; sleep 1
    #done

    # Crear los usuarios y asignarles las contraseñas
    for i in "${!usuarios[@]}"; do
        usuario="${usuarios[$i]}"
        pass="${contrasenas[$i]}"
        login="${login_enabled[$i]}"

        if [ "$login" == "n" ]; then
            # Si no desea login, bloquear la cuenta
            sudo useradd -s /sbin/nologin "$usuario"
        else
            # Si desea login, asignar /bin/bash como shell
            sudo useradd -s /bin/bash "$usuario"
        fi

        # Crear usuario en Samba
        printf "$pass\n$pass\n" | sudo smbpasswd -a -s "$usuario"

        # Asignar la contraseña al usuario del sistema
        echo "$usuario:$pass" | sudo chpasswd
    done

    echo ""
    echo -e "${verde}Usuarios creados con éxito.${borra_colores}"
done
}

# Funcionn para crear carpetas
crear_carpetas() {
while true; do
    clear
    menu_info
    echo -e "${verde}CREACION DE CARPETAS${borra_colores}"
    echo ""
    echo -e "${amarillo}La carpeta principal se creará en (${borra_colores}/srv/${amarillo}y el nombre que quieras)${borra_colores}"
    echo -e "${verde}Listado de las carpetas de tu${borra_colores} /srv${verde} por si ya tienes una que quieres utilizar${borra_colores}"

    # Buscar solo directorios dentro de /srv
    carpetas=($(find "/srv" -mindepth 1 -maxdepth 1 -type d 2>/dev/null))

    # Comprobar si el array está vacío
    if [ ${#carpetas[@]} -eq 0 ]; then
        echo ""
        echo -e "${amarillo}No hay ninguna carpeta en ${borra_colores}/srv"
        echo -e ""
    else
        for carpeta in "${carpetas[@]}"; do
            echo -e ""
            echo -e " -${azul} $(basename "$carpeta")${borra_colores}"
            echo -e ""
        done
    fi

    # Validar que recurso_compartido no esté vacío
    while true; do
        read -p "Ingresa el nombre del recurso compartido (ej. Servidor_smb): " recurso_compartido
        if [ -n "/srv/$recurso_compartido" ]; then
            break
        else
            echo ""
            echo -e "${rojo}El nombre del recurso compartido no puede estar vacío. Intenta de nuevo.${borra_colores}"; sleep 2
        fi
    done
    echo ""
    echo -e "Ingrese las carpetas a crear dentro de /srv/$recurso_compartido (separadas por espacio, por ejemplo: Descargas Video Photo)"
    read -p "Si el recurso compartido ya tiene las carpetas, presiona Enter: " carpetas
    echo ""

    echo -e "${verde}Carpeta de recurso compartido =${borra_colores} /srv/$recurso_compartido"

    if [ -z "$carpetas" ]; then
        echo -e "${verde}Carpetas dentro de /srv/$recurso_compartido =${borra_colores} $(for dir in /srv/$recurso_compartido/*/; do basename "$dir"; done | tr '\n' ' ')"
    else
        echo -e "${verde}Carpetas dentro de /srv/$recurso_compartido =${borra_colores} $carpetas"
    fi

    echo ""
    read -p "¿Es correcto? (s/n): " sn
    if [[ "$sn" == "s" || "$sn" == "S" ]]; then
        # Crear las carpetas
        for carpeta in $carpetas; do
            sudo mkdir -p /srv/$recurso_compartido/$carpeta
        done
        echo ""
        echo -e "${verde}Carpetas creadas con éxito${borra_colores}"
        break
    else
        echo -e "${rojo}No se crea nada ni se modifica${borra_colores}"; sleep 3
    fi
done
}

# Funcion para asignar permisos
asignar_permisos() {
    clear
    menu_info
    echo ""
    echo -e "${verde}ASIGNACION DE PERMISOS ACL${borra_colores}"
    echo ""

    # Obtener usuarios y carpetas
    usuarios=($(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd))
    carpetas=$(ls /srv/$recurso_compartido)

    # Iterar sobre los usuarios y carpetas para asignar permisos
    for usuario in "${usuarios[@]}"; do
        for carpeta in $carpetas; do
            while true; do
                echo ""
                echo -e "${azul}Qué permisos desea asignar a${borra_colores} $usuario ${azul}en la carpeta${borra_colores} $carpeta${azul}? (rwx = Control Total, rx = Solo lectura, - = Sin acceso)${borra_colores}"
                read -p "Permisos para $usuario en /compartido/$carpeta: " permisos

                # Validar permisos
                if [[ "$permisos" == "rwx" ]]; then
                    sudo setfacl -R -m u:$usuario:rwx /srv/$recurso_compartido/$carpeta
                    break
                elif [[ "$permisos" == "rx" ]]; then
                    sudo setfacl -R -m u:$usuario:rx /srv/$recurso_compartido/$carpeta
                    break
                elif [[ "$permisos" == "-" ]]; then
                    sudo setfacl -R -m u:$usuario:--- /srv/$recurso_compartido/$carpeta
                    break
                else
                    echo ""
                    echo -e "${rojo}Permiso no reconocido.${amarillo} Por favor ingrese nuevamente.${borra_colores}"
                fi
            done
        done
    done

    echo ""
    echo -e "${verde}Permisos asignados con éxito.${borra_colores}"
}

configurar_samba(){
    #aￃﾱado la configuracion a samba
    # Ruta del archivo de configuraciￃﾳn de Samba
    clear; echo -e "${verde}Configuramos el servidor de samba${borra_colores}"; echo ""
    SAMBA_CONF="/etc/samba/smb.conf"
    # Bloque de configuraciￃﾳn a aￃﾱadir
    CONFIG="[$recurso_compartido]
    path = /srv/$recurso_compartido
    valid users = ${usuarios[@]}
    read only = no
    browsable = yes
    writable = yes
    create mask = 0775
    directory mask = 0775
    "

    # Comprobamos si ya existe el bloque [compartido] para evitar duplicados
    if ! grep -q "\[$recurso_compartido\]" "$SAMBA_CONF"; then
        # Aￃﾱadir la configuraciￃﾳn al final del archivo
        sudo echo "$CONFIG" >> "$SAMBA_CONF"
        echo "Configuracion aplacada a $SAMBA_CONF"
    else
        echo "El bloque [compartido] ya existe en $SAMBA_CONF"
    fi

    # Reiniciar el servicio de Samba para aplicar los cambios
    sudo systemctl restart smbd

    echo "Servicio Samba reiniciado para aplicar cambios."
}


# Ejecutar las funciones
crear_usuarios
sleep 1
#read -p "Pulsa una tecla para continuar" p;
crear_carpetas
sleep 1
#read -p "Pulsa una tecla para continuar" p;
asignar_permisos
sleep 1
#read -p "Pulsa una tecla para continuar" p;
configurar_samba
echo ""
echo -e "${verde}Proceso completado con Exito.${borra_colores}"
# Marcar que la configuración inicial ha sido completada
echo -e "${verde}Configuración inicial completada el $(date)${borra_colores}" | sudo tee "$estado_config" > /dev/null
echo ""
echo -e "${amarillo} Ten en cuenta que si esta habilitado el recurso [homes]${borra_colores}"
echo -e "${amarillo} en la configuracion de samba en /etc/samba/smb.conf${borra_colores}"
echo -e "${amarillo} puede ser que se muestre el home de algun usuario.${borra_colores}"
echo ""
echo -e "${amarillo} Puedes eliminarlo en la opcion 4 Borrar configuracion de samba.${borra_colores}"
sudo chmod 600 "$estado_config"
echo ""
read -p "Pulsa una tecla para continuar." pause
}

# ========================
# Funcion permisos acl (script completo 2)
# ========================
permisos_acl() {
#!/bin/bash


# ========================
# Colores
# ========================
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m" # No Color

# ========================
# Funcionn para traducir permisos con colores
# ========================
translate_perms() {
    local perm="$1"
    local desc=""

    [[ "${perm:0:1}" == "r" ]] && desc+="${GREEN}lectura${NC} " || desc+="${RED}sin lectura${NC} "
    [[ "${perm:1:1}" == "w" ]] && desc+="${YELLOW}escritura${NC} " || desc+="${RED}sin escritura${NC} "
    [[ "${perm:2:1}" == "x" ]] && desc+="${BLUE}ejecucion${NC}" || desc+="${RED}sin ejecucion${NC}"

    echo -e "$desc"
}

# ========================
# Pedir la ruta al usuario (con validaciￃﾳn)
# ========================
clear
menu_info
echo -e "${verde}MODIFICAR PERMISOS ACL${borra_colores}"
echo ""
echo -e "${azul}Listado de las carpetas de ${borra_colores}/srv ${azul}de tu sistema${borra_colores}"
echo -e "${turquesa}"
ls -d /srv/*/ | xargs -n 1 basename
echo -e "${borra_colores}"
while true; do
    read -rp "Ingresa la ruta absoluta de la carpeta compartida: " TARGET_carpeta
    TARGET="/srv/$TARGET_carpeta"
    if [ -d "$TARGET" ]; then
        break
    else
        echo -e "${rojo}La ruta '${borra_colores}$TARGET${rojo}' no es una carpeta invadida. Intenta nuevamente.${borra_colores}"; sleep 2
        echo ""
    fi
done

# ========================
# Menￃﾺ principal
# ========================
while true; do
    clear
    menu_info
    echo -e "${verde}MODIFICAR PERMISOS ACL${borra_colores}"
    echo -e "\nCarpeta seleccionada: ${BLUE}$TARGET${NC}\n"
    echo -e "${azul} 1)${borra_colores} Listar permisos ACL"
    echo -e "${azul} 2)${borra_colores} Cambiar permisos ACL de un usuario"
    echo ""
    echo -e "${azul}99)${borra_colores} Atras"
    echo ""
    read -rp "Elige una opcion: " option

    case "$option" in
        1)
            # ========================
            # Listar permisos ACL
            # ========================
            clear
            menu_info
            echo -e "${verde}LISTAR PERMISOS ACL${borra_colores}"
            echo ""
            USERS=$(find "$TARGET" -type d -exec getfacl -p {} \; 2>/dev/null | \
                    grep '^user:' | cut -d: -f2 | sort -u | grep -v '^$')

            echo -e "\nUsuarios con permisos ACL en '$TARGET':"
            echo ""
            echo "     0 Mostrar todos"
            echo ""
            echo "$USERS" | nl

            while true; do
                echo ""
                read -rp "Ingresa el numero del usuario (0 = todos): " choice
                if [[ "$choice" =~ ^[0-9]+$ ]]; then
                    if [ "$choice" -eq 0 ]; then
                        FILTER_USER=""
                        echo ""
                        echo -e "${azul}Mostrando permisos de todos los usuarios${borra_colores}"
                        break
                    elif [ "$choice" -le $(echo "$USERS" | wc -l) ]; then
                        FILTER_USER=$(echo "$USERS" | sed -n "${choice}p")
                        echo ""
                        echo -e "${azul}Filtrando resultados para usuario:${borra_colores} ${FILTER_USER}"
                        break
                    fi
                fi
                echo -e "${rojo}Opcion invadida. Intenta nuevamente.${borra_colores}"
            done

            echo -e "\nPermisos ACL en '$TARGET' ${amarillo}(Los permisos ACL se heredan en todo el contenido de las carpetas principales)${borra_colores}"
            echo "-----------------------------------------------------------------------------------------------------------"
            printf "%-40s    %-22s  %-100s\n" "Carpeta" "Usuario/Grupo" "Permisos"
            echo "-----------------------------------------------------------------------------------------------------------"

            find "$TARGET" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
                getfacl -p "$dir" 2>/dev/null | grep -E '^(user|group|other)' | while IFS= read -r line; do
                    entry=$(echo "$line" | cut -d: -f1)
                    who=$(echo "$line" | cut -d: -f2)
                    perms=$(echo "$line" | cut -d: -f3)
                    readable_perms=$(translate_perms "$perms")

                    if [ -n "$FILTER_USER" ] && [ "$who" != "$FILTER_USER" ]; then
                        continue
                    fi

                    case "$entry" in
                        user) label="Usuario ${who:-Propietario}" ;;
                        group) label="Grupo ${who:-Propietario}" ;;
                        other) label="Otros" ;;
                    esac

                    printf "%-40s | %-20s | %-35s\n" "$dir" "$label" "$readable_perms"
                done
            done | column -t -s '|'
            echo -e "${verde}"
            read -p "Pulsa una tecla para continuar"
            echo -e "${borra_colores}"
            ;;

        2)
            # ========================
            #  Cambiar permisos ACL
            # ========================
            clear
            menu_info
            echo -e "\n${verde}MODIFICACION DE PERMISOS ACL POR USUARIO${borra_colores}"

            # Obtener lista de usuarios con ACL
            USERS=$(find "$TARGET" -type d -exec getfacl -p {} \; 2>/dev/null | \
                    grep '^user:' | cut -d: -f2 | sort -u | grep -v '^$')

            if [ -z "$USERS" ]; then
                echo ""
                echo -e "${rojo}No hay usuarios con permisos ACL en la carpeta $TARGET${borra_colores}"; sleep 3
                return
            else
                echo -e "\nUsuarios con ACL en '$TARGET':"; echo ""
                echo "$USERS" | nl
                while true; do
                    echo ""
                    read -rp "Ingresa el numero del usuario a modificar: " choice
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $(echo "$USERS" | wc -l) ]; then
                        USER=$(echo "$USERS" | sed -n "${choice}p")
                        break
                    fi
                    echo -e "${rojo}Opcion invadida. Intenta nuevamente.${borra_colores}"; sleep 2
                done
            fi

            # Mostrar permisos actuales del usuario seleccionado en columnas
            echo -e "\n${azul}Permisos actuales del usuario${borra_colores} ${USER} ${azul}en la carpeta '${borra_colores}$TARGET${azul}' incluyendo carpetas y ficheros:${borra_colores}"; echo ""
            echo "-----------------------------------------------------------------------------------------------------------"
            printf "%-40s    %-22s  %-100s\n" "Carpeta" "Usuario/Grupo" "Permisos"
            echo "-----------------------------------------------------------------------------------------------------------"

            find "$TARGET" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
                getfacl -p "$dir" 2>/dev/null | grep "^user" | while IFS=: read -r _ who perms; do
                    # Mostrar solo si es el usuario seleccionado o si es propietario y coincide con el usuario
                    owner=$(stat -c '%U' "$dir")
                    if [ "$who" == "$USER" ] || { [ -z "$who" ] && [ "$USER" == "$owner" ]; }; then
                        readable_perms=$(translate_perms "$perms")
                        label="Usuario ${who:-Propietario}"
                        printf "%-40s | %-20s | %-35s\n" "$dir" "$label" "$readable_perms"
                    fi
                done
            done | column -t -s '|'

            # Pedir los nuevos permisos
            while true; do
                echo ""
                echo -e "${amarillo}Solo lectura =${borra_colores} r-x ${amarillo}Lectura escritura =${borra_colores} rwx ${amarillo}Sin acceso =${borra_colores} ---"
                read -rp "Ingresa los nuevos permisos (99 = atras): " PERMS
                if [ $PERMS = "99" ]; then
                    return
                fi

                if [[ "$PERMS" =~ ^[r-][w-][x-]$ ]]; then
                    break
                fi
                echo -e "${rojo}Formato de permisos invalido.${borra_colores}"; sleep 2
            done

            # Mostrar carpetas para seleccionar
            echo -e "${azul}\nSelecciona las carpetas donde aplicar permisos (ej: 1 2 3):${borra_colores}"; echo ""
            echo "0) Toda la carpeta raiz y subcarpetas incluyendo ficheros"
            mapfile -t SUBFOLDERS < <(find "$TARGET" -mindepth 1 -maxdepth 1 -type d)
            echo ""
            for i in "${!SUBFOLDERS[@]}"; do
                echo "$((i+1))) ${SUBFOLDERS[$i]}"
            done

            # Pedir selecciￃﾳn con validaciￃﾳn
            while true; do
                echo ""
                read -rp "Ingresa los numeros separados por espacios: " FOLDER_CHOICES
                if [[ "$FOLDER_CHOICES" == "0" ]]; then
                    FOLDERS=("$TARGET")
                    break
                fi

                VALID=true
                FOLDERS=()
                for num in $FOLDER_CHOICES; do
                    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#SUBFOLDERS[@]}" ]; then
                        VALID=false
                        break
                    fi
                    FOLDERS+=("${SUBFOLDERS[$((num-1))]}")
                done

                if $VALID; then
                    break
                else
                    echo -e "${rojo}Entrada invalida.${amarillo} Ingresa solo numeros validos separados por espacios o 0 para seleccionar todos.${borra_colores}"
                fi
            done

            # Preguntar recursividad
            read -rp "Aplicar permisos recursivamente a subcarpetas y archivos? (s/n): " REC

            # Aplicar permisos a todas las carpetas seleccionadas
            for FOLDER in "${FOLDERS[@]}"; do
                if [[ "$REC" =~ ^[sS]$ ]]; then
                    setfacl -R -m u:"$USER":"$PERMS" "$FOLDER"
                else
                    setfacl -m u:"$USER":"$PERMS" "$FOLDER"
                fi

                if [ $? -eq 0 ]; then
                    echo -e "${verde}Permisos aplicados correctamente a:${borra_colores} $FOLDER"
                else
                    echo -e "${rojo}Error al aplicar permisos en:${borra_colores} $FOLDER"
                fi
            done
            ;;

        99)
            break
            ;;

        *)
            echo ""
            echo -e "${rojo}Opcion invalida.${borra_colores}"; sleep 2
            ;;
    esac
done

}

#funcion de crear o borrar usuarios
crearborrarusuarios(){
#!/bin/bash

# Colores
verde="\e[32m"
rojo="\e[31m"
azul="\e[34m"
borra_colores="\e[0m"

listarrecursoscompartidoyusuarios(){
awk '
BEGIN {
    azul = "\033[34m"
    reset = "\033[0m"
    print azul "Recurso compartido\tUsuarios del recurso" reset
    print azul "------------------\t--------------------" reset
}
/^\[.*\]$/ {
    if (share != "") {
        print share "\t" (valid ? valid : "")
    }
    share = substr($0, 2, length($0)-2)
    valid = ""
}
/^[ \t]*valid users/ {
    # Quitar "valid users =" y dejar solo los nombres
    sub(/^[ \t]*valid users[ \t]*=[ \t]*/, "", $0)
    valid = $0
}
END {
    if (share != "") {
        print share "\t" (valid ? valid : "")
    }
}
' $SMB_CONF | column -t -s $'\t'
}

SMB_CONF="/etc/samba/smb.conf"

#valida que este el recurso compartido
echo ""
listarrecursoscompartidoyusuarios
echo ""
read -p "Dime el nombre del recurso compartido en samba: " SHARE_NAME
if ! grep -q "^\[$SHARE_NAME\]" "$SMB_CONF"; then
        echo ""
        echo -e "${rojo}El recurso compartido ${borra_colores}$SHARE_NAME ${rojo}no existe en${borra_colores} $SMB_CONF"; sleep 3
        return
    fi

gestionar_usuarios() {
    while true; do
        clear
        menu_info
        echo ""
        echo -e "${verde}GESTIÓN DE USUARIOS${borra_colores}"
        echo ""
        #select opcion in "Crear usuario(s)" "Borrar usuario(s)" "Salir"; do
        echo -e " ${azul}  1)${borra_colores} Crear usuarios(s)"
        echo -e " ${azul}  2)${borra_colores} Borrar usuarios(s)"
        echo -e " ${azul} 99)${borra_colores} Atras"
        echo ""
        read -p "Selecciona una opcion del menu: " opcion
            case $opcion in
                1)
                    crear_usuario
                    break
                    ;;
                2)
                    borrar_usuario
                    break
                    ;;
                99)
                    return
                    ;;
                *)
                    echo -e "${rojp}Selecciona una opción válida${borra_colores}"; sleep 2
                    ;;
            esac
        #done
    done
}

crear_usuario() {
while true; do
    clear
    menu_info
    echo ""
    echo -e "${verde}CREACION DE USUARIOS${borra_colores}"
    echo ""
    echo -e "${azul}Lista de usuarios actuales${borra_colores}"; echo ""
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd

    echo ""
read -p "Introduce los nombres de usuario separados por espacio: " -a usuarios

# Función para validar nombres de usuario
validar_usuario() {
  local user=$1
  if [[ ! $user =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    echo " Nombre de usuario inválido: '$user'"
    return 1
  fi
  if id "$user" &>/dev/null; then
    echo " El usuario '$user' ya existe."
    return 1
  fi
  return 0
}


# Bucle para crear usuarios
for user in "${usuarios[@]}"; do
  echo "---- Creando usuario '$user' ----"
  validar_usuario "$user" || continue

  read -s -p "Introduce la contraseña para '$user': " password
  echo
  read -s -p "Confirma la contraseña para '$user': " password2
  echo

  if [[ "$password" != "$password2" ]]; then
    echo " Las contraseñas no coinciden. Saltando usuario '$user'."
    continue
  fi

  read -p "¿Deseas que '$user' tenga acceso de login al sistema? (s/n): " login
  if [[ "$login" =~ ^[sS]$ ]]; then
    useradd -m "$user"
  else
    useradd -M -s /usr/sbin/nologin "$user"
  fi

  # Establecer contraseña Linux
  echo "$user:$password" | chpasswd

  # Crear usuario Samba con la misma contraseña
  (echo "$password"; echo "$password") | smbpasswd -a -s "$user"
  smbpasswd -e "$user"

  # Asignar permisos ACL a la carpeta compartida
  setfacl -R -m u:"$user":--- "/srv/$SHARE_NAME"
  setfacl -R -d -m u:"$user":--- "/srv/$SHARE_NAME"

  echo " Usuario '$user' creado con éxito (Linux + Samba)."
  echo " ACL aplicados en '/srv/$SHARE_NAME'."
done

echo " Todos los usuarios procesados correctamente."
read p
break


#    echo ""
#    actualizar_valid_users "Añadir" "$usuarios"
    sudo systemctl reload smbd
#    echo -e "${verde}Usuarios creados con éxito.${borra_colores}"
done
}

borrar_usuario() {
    clear
    menu_info
    echo -e "${rojo}BORRAR USUARIOS${borra_colores}"
    echo ""
    echo "Usuarios disponibles en el sistema:"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
    echo ""

    read -p "Ingrese los nombres de los usuarios a borrar (separados por espacios): " usuarios

    for usuario in $usuarios; do
        if ! id "$usuario" &>/dev/null; then
            echo -e "${rojo}El usuario $usuario no existe. Se omite.${borra_colores}"
            continue
        fi

        sudo userdel -r "$usuario"
        sudo smbpasswd -x "$usuario"

        echo -e "${verde}Usuario $usuario eliminado.${borra_colores}"
    done

    actualizar_valid_users "Quitar" "$usuarios"
    sudo systemctl reload smbd
    sleep 1; read p
}

actualizar_valid_users() {
    accion="$1"
    usuarios="$2"

    if ! grep -q "^\[$SHARE_NAME\]" "$SMB_CONF"; then
        echo -e "${rojo}El share [$SHARE_NAME] no existe en $SMB_CONF.${borra_colores}"
        return
    fi

    current_line=$(awk -v share="[$SHARE_NAME]" '
        $0 == share {flag=1; next}
        /^\[/ {flag=0}
        flag && /^ *valid users *=/ {print; exit}
    ' "$SMB_CONF")

    existing_users=$(echo "$current_line" | sed 's/^[ \t]*valid users[ \t]*=[ \t]*//')

    if [[ "$accion" == "Añadir" ]]; then
        all_users=$(echo "$existing_users $usuarios" | tr ' ' '\n' | sort -u | xargs)
    else
        all_users="$existing_users"
        for u in $usuarios; do
            all_users=$(echo "$all_users" | tr ' ' '\n' | grep -v -x -F "$u" | xargs)
        done
    fi

    if [[ -z "$current_line" ]]; then
        sed -i "/\[$SHARE_NAME\]/a valid users = $all_users" "$SMB_CONF"
    else
        sed -i "/^\s*valid users\s*=/c\    valid users = $all_users" "$SMB_CONF"
    fi
}

gestionar_usuarios

}

borraconfiguracionsamba(){

SMB_CONF="/etc/samba/smb.conf"

# Si se pasa una ruta alternativa al smb.conf
if [ -n "$1" ]; then
    SMB_CONF="$1"
fi

# Comprobar que el archivo existe
if [ ! -f "$SMB_CONF" ]; then
    echo ""
    echo "${rojo}No se encontró el archivo${borra_colores} $SMB_CONF"
    sleep 3
fi

# Obtener los nombres de los recursos compartidos (excepto [global])
mapfile -t SHARES < <(grep -E '^\[[^]]+\]' "$SMB_CONF" | sed -E 's/^\[|\]$//g' | grep -vi '^global$')

if [ ${#SHARES[@]} -eq 0 ]; then
    echo ""
    echo -e "${amarillo}No se encontraron recursos compartidos en${borra_colores} $SMB_CONF"
    sleep 3
fi

echo ""
echo -e "${azul}Recursos compartidos definidos en${borra_colores} $SMB_CONF:"
echo -e ""
i=1
for share in "${SHARES[@]}"; do
    echo -e "${azul}$i)${borra_colores} $share"
    ((i++))
done
echo ""
echo -e "${amarillo} Ten en cuenta que si esta habilitado el recurso [homes]${borra_colores}"
echo -e "${amarillo} en la configuracion de samba en /etc/samba/smb.conf${borra_colores}"
echo -e "${amarillo} puede ser que se muestre el home de algun usuario.${borra_colores}"
echo ""
read -p "Introduce el número del recurso que quieres eliminar (o 99 para ir atras): " SELECCION

if [ "$SELECCION" -eq 99 ] 2> /dev/null; then
    return
fi

# Validar selección
if ! [[ "$SELECCION" =~ ^[0-9]+$ ]]; then
    echo ""
    echo -e "${rojo}Selección no válida (no es un número)${borra_colores}"
    sleep 3
    return
fi

# Validar rango
if [ "$SELECCION" -lt 1 ] || [ "$SELECCION" -gt "${#SHARES[@]}" ]; then
    echo ""
    echo -e "${rojo}Selección no válida (fuera de rango)${borra_colores}"
    sleep 3
    return
fi

SHARE_A_BORRAR="${SHARES[$((SELECCION-1))]}"




#if [ "$SELECCION" -lt 1 ] || [ "$SELECCION" -gt "${#SHARES[@]}" ]; then
#    echo ""
#    echo -e "${rojo}Selección no válida${borra_colores}"
#    sleep 3
#    return
#fi

SHARE_A_BORRAR="${SHARES[$((SELECCION-1))]}"

echo ""
echo -e "${amarillo}Vas a eliminar el recurso compartido:${borra_colores} $SHARE_A_BORRAR"
echo -e "${amarillo}Si lo borras creara una copia de seguridad automatica${borra_colores}"
echo ""
read -p "¿ Estas seguro ? (s/N): " CONFIRMAR

if [[ ! "$CONFIRMAR" =~ ^[sS]$ ]]; then
    echo ""
    echo -e "${amarillo}No se borra nada${borra_colores}"
    sleep 3
    return
fi

# Crear copia de seguridad
BACKUP="$SMB_CONF.bak_$(date +%Y%m%d_%H%M%S)"
cp "$SMB_CONF" "$BACKUP"
echo ""
echo -e "${verde}Copia de seguridad creada:${borra_colores} $BACKUP"

# Obtener línea inicial del bloque
LINEA_INICIO=$(grep -n "^\[$SHARE_A_BORRAR\]" "$SMB_CONF" | cut -d: -f1)

# Obtener línea del siguiente bloque o final del archivo
LINEA_SIGUIENTE=$(grep -n "^\[" "$SMB_CONF" | awk -F: -v start="$LINEA_INICIO" '$1 > start {print $1; exit}')

if [ -z "$LINEA_SIGUIENTE" ]; then
    # Si no hay siguiente bloque, eliminar hasta el final
    sed -i "${LINEA_INICIO},\$d" "$SMB_CONF"
else
    # Eliminar desde la línea de inicio hasta justo antes del siguiente bloque
    sed -i "${LINEA_INICIO},$((LINEA_SIGUIENTE-1))d" "$SMB_CONF"
fi

echo -e "${verde}Recurso${borra_colores} $SHARE_A_BORRAR ${verdes}eliminado del archivo${borra_colores}"

# Mostrar los recursos restantes
echo
echo -e "${azul}Recursos restantes:${borra_colores}"
grep -E '^\[[^]]+\]' "$SMB_CONF" | sed -E 's/^\[|\]$//g' | grep -vi '^global$'

#borra el fichero de estado de la configuracion samba
echo ""
read -p "Deseas borrar el estado? (s/n) " sn
if [[ "$sn" =~ ^[sS]$ ]]; then
    sudo rm -r $estado_config
else
    echo ""
    echo -e "${verde}El estado NO se ha borrado${borra_colores}"
    sleep 3
fi

}

clear
menu_info
conexion
if [ $conexion = "SI" ]; then
    actualizar_script
    if [ $actualizado = "SI" ]; then
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="SI"
            export actualizado="SI"
        else
            echo ""
        fi
    else
        software_necesario
        if [ $software = "SI" ]; then
            export software="SI"
            export conexion="NO"
            export actualizado="No se ha podido comprobar la actualizacion del script"
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
    else
        echo ""
    fi
fi

# ========================
# Comprobar root
# ========================
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${rojo}Error:${amarillo} este script debe ejecutarse con sudo o como root.${borra_colores}"
    echo ""; read p
    ctrl_c
fi

# ========================
# Menￃﾺ principal
# ========================

while true; do
    clear
    menu_info
    echo ""
    echo -e " ${azul}MENU PRINCIPAL${borra_colores}"
    echo ""

    if [ -f "$estado_config" ]; then
        echo -e " ${verde}Estado:${borra_colores} Configuración inicial completada,${verde} Ya tienes acceso a los menus 2,3,4${borra_colores}"
    else
        echo -e " ${rojo}Estado:${borra_colores} Configuración inicial pendiente,${amarillo} NO tienes acceso a los menus 2,3,4${borra_colores}"
    fi

    echo ""
    echo -e "  ${verde}Info Ip server${borra_colores} $(hostname -I)"
    echo ""
    echo -e " ${azul} 1)${borra_colores} Crear usuarios, carpetas y permisos Samba (Configuracion inicial)"
    echo -e " ${azul} 2)${borra_colores} Modificar permisos ACL de las carpetas comparitdas por samba"
    echo -e " ${azul} 3)${borra_colores} Crear borrar usuarios samba y del sistema"
    echo -e " ${azul} 4)${borra_colores} Borrar la configuracion de samba, NO borra datos del disco y usuarios."
    echo -e " ${azul} 5)${borra_colores} Listar tu fichero de configuracion de samba."
    echo -e " ${azul} 6)${borra_colores} Listar los usuarios de samba."
    echo -e " ${azul}99)${borra_colores} Salir"
    echo ""
    read -rp " Elige una opcion: " opcion

    case "$opcion" in
        1) crear_total ;;

        2) if [ -f "$estado_config" ]; then
            permisos_acl
           else
            echo ""
            echo -e "${rojo}No puedes acceder a esta opción.${borra_colores}"
            echo -e "${amarillo}Primero ejecuta la opción 1 para configurar Samba.${borra_colores}"
            sleep 4
          fi ;;

        3) if [ -f "$estado_config" ]; then
            crearborrarusuarios
           else
            echo ""
            echo -e "${rojo}No puedes acceder a esta opción.${borra_colores}"
            echo -e "${amarillo}Primero ejecuta la opción 1 para configurar Samba.${borra_colores}"
            sleep 4
          fi ;;

        4) if [ -f "$estado_config" ]; then
            borraconfiguracionsamba
           else
            echo ""
            echo -e "${rojo}No puedes acceder a esta opción.${borra_colores}"
            echo -e "${amarillo}Primero ejecuta la opción 1 para configurar Samba.${borra_colores}"
            sleep 4
          fi ;;

        5) echo "listado de 555555555"; read p ;;

        6)  #listado de usuarios de samba
            usuarios=$(sudo pdbedit -L | cut -d: -f1)
            # Comprobar si la lista está vacía
            if [ -z "$usuarios" ]; then
                echo ""
                echo -e "${amarillo} No hay usuarios registrados en Samba.${borra_colores}"; sleep 3
            else
                echo ""
                echo -e "${azul} Usuarios Samba encontrados:${borra_colores}"
                echo ""
                echo -e "${verde}$usuarios ${borra_colores}"
                echo ""
                read -p " Pulsa una tecla para continuar" pause
            fi
            ;;

        99) ctrl_c ;;
        *) echo ""; echo -e "${rojo} Opcion del menu invalida.${borra_colores}"; sleep 2 ;;
    esac
done
