#!/bin/bash

#colores
#ejemplo: echo -e "${verde} La opcion (-e) es para que pille el color.${borra_colores}"
#which git diff ping apt curl awk

ruta_ejecucion=$(dirname "$(readlink -f "$0")")
export version="2.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualizacion del script"

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
    echo -e "${amarillo}La carpeta principal se creará en (${borra_colores}/home y el nombre que quieras${amarillo})${borra_colores}"
    echo -e "${verde}Listado de las carpetas de tu /home por si ya tienes una que quieres utilizar${borra_colores}"
    echo ""
    ls /home/
    echo ""

    # Validar que recurso_compartido no esté vacío
    while true; do
        read -p "Ingresa el nombre del recurso compartido (Servidor_smb): " recurso_compartido
        if [ -n "$recurso_compartido" ]; then
            break
        else
            echo ""
            echo -e "${rojo}El nombre del recurso compartido no puede estar vacío. Intenta de nuevo.${borra_colores}"; sleep 2
        fi
    done
    echo ""
    echo -e "Ingrese las carpetas a crear dentro de /home/$recurso_compartido (separadas por espacio, por ejemplo: Descargas Video Photo)"
    read -p "Si el recurso compartido ya tiene las carpetas, presiona Enter: " carpetas
    echo ""

    echo -e "${verde}Carpeta de recurso compartido =${borra_colores} /home/$recurso_compartido"

    if [ -z "$carpetas" ]; then
        echo -e "${verde}Carpetas dentro de /home/$recurso_compartido =${borra_colores} $(for dir in /home/$recurso_compartido/*/; do basename "$dir"; done | tr '\n' ' ')"
    else
        echo -e "${verde}Carpetas dentro de /home/$recurso_compartido =${borra_colores} $carpetas"
    fi

    echo ""
    read -p "¿Es correcto? (s/n): " sn
    if [[ "$sn" == "s" || "$sn" == "S" ]]; then
        # Crear las carpetas
        for carpeta in $carpetas; do
            sudo mkdir -p /home/$recurso_compartido/$carpeta
        done
        echo ""
        echo -e "${verde}Carpetas creadas con éxito${borra_colores}"
        break
    else
        echo -e "${rojo}No se crea nada ni se modifica,"; read p
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
    carpetas=$(ls /home/$recurso_compartido)

    # Iterar sobre los usuarios y carpetas para asignar permisos
    for usuario in "${usuarios[@]}"; do
        for carpeta in $carpetas; do
            while true; do
                echo ""
                echo -e "${azul}Qué permisos desea asignar a${borra_colores} $usuario ${azul}en la carpeta${borra_colores} $carpeta${azul}? (rwx = Control Total, rx = Solo lectura, - = Sin acceso)${borra_colores}"
                read -p "Permisos para $usuario en /compartido/$carpeta: " permisos

                # Validar permisos
                if [[ "$permisos" == "rwx" ]]; then
                    sudo setfacl -R -m u:$usuario:rwx /home/$recurso_compartido/$carpeta
                    break
                elif [[ "$permisos" == "rx" ]]; then
                    sudo setfacl -R -m u:$usuario:rx /home/$recurso_compartido/$carpeta
                    break
                elif [[ "$permisos" == "-" ]]; then
                    sudo setfacl -R -m u:$usuario:--- /home/$recurso_compartido/$carpeta
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
    clear; echo "Configuramos el servidor de samba"; echo ""
    SAMBA_CONF="/etc/samba/smb.conf"
    # Bloque de configuraciￃﾳn a aￃﾱadir
    CONFIG="[$recurso_compartido]
    path = /home/$recurso_compartido
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
read -p "Pulsa una tecla para continuar" p;
crear_carpetas
read -p "Pulsa una tecla para continuar" p;
asignar_permisos
read -p "Pulsa una tecla para continuar" p;
configurar_samba
echo "Proceso completado con Exito."

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
while true; do
    read -rp "Ingresa la ruta absoluta de la carpeta compartida: " TARGET
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

            find "$TARGET" -type d | while IFS= read -r dir; do
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
            # Cambiar permisos ACL
            # ========================
            clear
            menu_info
            echo -e "\n${verde}MODIFICACION DE PERMISOS ACL POR USUARIO${borra_colores}"

            # Obtener lista de usuarios con ACL
            USERS=$(find "$TARGET" -type d -exec getfacl -p {} \; 2>/dev/null | \
                    grep '^user:' | cut -d: -f2 | sort -u | grep -v '^$')

            if [ -z "$USERS" ]; then
                read -rp "No hay usuarios con ACL. Ingresa el nombre del usuario: " USER
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

            find "$TARGET" -type d | while IFS= read -r dir; do
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
                read -rp "Ingresa los nuevos permisos (r, w, x - ej: rwx, r--): " PERMS
                if [[ "$PERMS" =~ ^[r-][w-][x-]$ ]]; then
                    break
                fi
                echo -e "${rojo}Formato de permisos invalido.${borra_colores}"; sleep 2
            done

            # Mostrar carpetas para seleccionar
            echo -e "\nSelecciona las carpetas donde aplicar permisos (ej: 1 2 3):"
            echo "0) Toda la carpeta raiz y subcarpetas incluyendo ficheros"
            echo ""
            mapfile -t SUBFOLDERS < <(find "$TARGET" -type d)
            echo ""
            for i in "${!SUBFOLDERS[@]}"; do
                echo "$((i+1))) ${SUBFOLDERS[$i]}"
            done

            # Pedir selecciￃﾳn con validaciￃﾳn
            while true; do
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
                    echo "Entrada invalida. Ingresa solo nￃﾺmeros vￃﾡlidos separados por espacios o 0 para toda la raￃﾭz."
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
                    echo "Permisos aplicados correctamente a: $FOLDER"
                else
                    echo "Error al aplicar permisos en: $FOLDER"
                fi
            done
            ;;

        99)
            echo -e "\nSaliendo..."
            break
            ;;

        *)
            echo "Opcion invalida."
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
        echo -e "${verde}CREACIÓN DE USUARIOS${borra_colores}"
        echo ""
        echo -e "${azul}Lista de usuarios actuales${borra_colores}"
        awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
        echo ""

        read -p "Ingrese los nombres de los usuarios a crear (separados por espacios, o 'ok' para terminar): " usuarios
        if [ "$usuarios" == "ok" ]; then
            break
        fi

        for usuario in $usuarios; do
            if [[ -z "$usuario" ]]; then
                echo -e "${rojo}El nombre de usuario no puede estar vacío.${borra_colores}"
                sleep 1
                continue
            elif [[ ! "$usuario" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo -e "${rojo}Solo letras, números y guiones bajos permitidos en $usuario.${borra_colores}"
                sleep 1
                continue
            fi

            read -s -p "Ingrese la contraseña para $usuario: " pass
            echo
            read -p "Desea que $usuario tenga acceso al login del sistema? (s/n): " login

            if [ "$login" == "n" ]; then
                sudo useradd -m -s /sbin/nologin "$usuario"
            else
                sudo useradd -m -s /bin/bash "$usuario"
            fi

            echo "$usuario:$pass" | sudo chpasswd
            printf "$pass\n$pass\n" | sudo smbpasswd -a -s "$usuario"

            sudo setfacl -R -m u:$usuario:--- /home/$recurso_compartido

            echo -e "${verde}Usuario $usuario creado correctamente.${borra_colores}"
            sleep 1
        done

        actualizar_valid_users "Añadir" "$usuarios"
        sudo systemctl reload smbd
    done
}

borrar_usuario() {
    clear
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
    sleep 1
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
    echo -e "  ${verde}Info Ip server${borra_colores} $(hostname -I)"
    echo ""
    echo -e " ${azul} 1)${borra_colores} Crear usuarios, carpetas y permisos Samba (Recomendado solo la primera vez)"
    echo -e " ${azul} 2)${borra_colores} Modificar permisos ACL de las carpetas comparitdas por samba"
    echo -e " ${azul} 3)${borra_colores} Crear borrar usuarios samba y del sistema"
    echo ""
    echo -e " ${azul}99)${borra_colores} Salir"
    echo ""
    read -rp " Elige una opcion: " opcion

    case "$opcion" in
        1) crear_total ;;
        2) permisos_acl ;;
        3) crearborrarusuarios ;;
        99) ctrl_c ;;
        *) echo ""; echo -e "${rojo} Opcion del menu invalida.${borra_colores}"; sleep 2 ;;
    esac
done
