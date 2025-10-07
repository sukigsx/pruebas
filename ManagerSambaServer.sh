#!/bin/bash

# ================================================
# SCRIPT DE CONFIGURACIÓN DE SAMBA AUTOMATIZADO
# v2.0 - MBBSistemas
# ================================================

# -------- COLORES --------
rojo="\e[0;31m\033[1m"
verde="\e[;32m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
rosa="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
borra_colores="\033[0m\e[0m"

# -------- VARIABLES GLOBALES --------
ruta_ejecucion=$(dirname "$(readlink -f "$0")")
version="2.0"
conexion="Sin comprobar"
software="Sin comprobar"
actualizado="No se ha podido comprobar la actualización del script"
estado_config="/etc/samba/.config_inicial_ok"

# -------- FUNCIONES DE INFORMACIÓN --------
menu_info() {
echo ""
echo -e "${rosa}            _    _                  ${azul}   Nombre del script${borra_colores}  $0 "
echo -e "${rosa}  ___ _   _| | _(_) __ _ _____  __  ${azul}   Descripción${borra_colores} Software de configuración/creación usuarios y permisos Samba"
echo -e "${rosa} / __| | | | |/ / |/ _\\ / __\\ \/ /  ${azul}   Versión            =${borra_colores} $version"
echo -e "${rosa} \\__ \\ |_| |   <| | (_| \\__ \\>  <   ${azul}   Conexión Internet  =${borra_colores} $conexion"
echo -e "${rosa} |___/\\__,_|_|\\_\\_|\\__, |___/_/\\_\\  ${azul}   Software necesario =${borra_colores} $software"
echo -e "${rosa}                  |___/             ${azul}   Actualizado        =${borra_colores} $actualizado"
echo ""
echo -e "${azul} Contacto:${borra_colores} scripts@mbbsistemas.com | https://repositorio.mbbsistemas.es"
echo ""
}

# -------- FUNCIONES DE COMPROBACIÓN --------
conexion_internet() {
if ping -c1 google.com &>/dev/null; then
    conexion="SI"
    echo -e " Conexión a internet = ${verde}SI${borra_colores}"
else
    conexion="NO"
    echo -e " Conexión a internet = ${rojo}NO${borra_colores}"
fi
}

software_necesario() {
echo ""
echo " Comprobando software necesario..."
sleep 1
paquetes=(samba samba-common smbclient acl)
faltan=()
for pkg in "${paquetes[@]}"; do
    if ! dpkg -l | grep -qw "$pkg"; then
        faltan+=("$pkg")
    fi
done

if [ ${#faltan[@]} -gt 0 ]; then
    echo -e " ${amarillo}Faltan paquetes:${borra_colores} ${faltan[*]}"
    read -rp " ¿Deseas instalarlos? (s/n): " r
    if [[ $r =~ ^[sS]$ ]]; then
        apt update && apt install -y "${faltan[@]}"
        software="Instalado"
    else
        software="Incompleto"
    fi
else
    software="Instalado"
fi
}

# -------- FUNCIÓN: CREAR CONFIGURACIÓN COMPLETA DE SAMBA --------
crear_total() {
clear
menu_info
echo ""
echo -e "${azul}>>> Creación completa de Samba...${borra_colores}"
sleep 1

# Crear carpeta compartida
read -rp " Introduce el nombre de la carpeta compartida (ejemplo: compartido): " carpeta
mkdir -p /srv/samba/"$carpeta"
chmod 770 /srv/samba/"$carpeta"
chown root:"$carpeta"

# Crear grupo
groupadd "$carpeta" 2>/dev/null

# Configurar Samba
if ! grep -q "[$carpeta]" /etc/samba/smb.conf; then
cat <<EOF >> /etc/samba/smb.conf

[$carpeta]
    path = /srv/samba/$carpeta
    browsable = yes
    read only = no
    valid users = @$carpeta
    create mask = 0660
    directory mask = 0770
EOF
fi

# Reiniciar Samba
systemctl restart smbd

# Crear usuario
read -rp " Introduce el nombre del usuario Samba: " usuario
useradd -m -G "$carpeta" "$usuario"
passwd "$usuario"
smbpasswd -a "$usuario"

echo ""
echo -e "${verde}Configuración inicial completada correctamente.${borra_colores}"

# Marcar configuración como completada
echo "Configuración inicial completada el $(date)" | sudo tee "$estado_config" > /dev/null
sudo chmod 600 "$estado_config"
sleep 2
}

# -------- FUNCIÓN: MODIFICAR PERMISOS ACL --------
permisos_acl() {
clear
menu_info
echo ""
echo -e "${azul}>>> Modificación de permisos ACL${borra_colores}"
read -rp " Nombre de la carpeta compartida: " carpeta
if [ -d /srv/samba/"$carpeta" ]; then
    read -rp " Usuario a añadir: " usuario
    setfacl -m u:"$usuario":rwx /srv/samba/"$carpeta"
    echo -e "${verde}Permisos actualizados correctamente.${borra_colores}"
else
    echo -e "${rojo}La carpeta no existe.${borra_colores}"
fi
sleep 2
}

# -------- FUNCIÓN: CREAR/BORRAR USUARIOS --------
crearborrarusuarios() {
clear
menu_info
echo ""
echo -e "${azul}>>> Crear o borrar usuarios Samba${borra_colores}"
echo ""
echo " 1) Crear usuario"
echo " 2) Borrar usuario"
read -rp " Elige una opción: " opcion

case "$opcion" in
    1)
        read -rp " Nombre del usuario: " usuario
        useradd -m "$usuario"
        passwd "$usuario"
        smbpasswd -a "$usuario"
        echo -e "${verde}Usuario creado correctamente.${borra_colores}"
        ;;
    2)
        read -rp " Nombre del usuario: " usuario
        smbpasswd -x "$usuario"
        userdel -r "$usuario"
        echo -e "${verde}Usuario eliminado.${borra_colores}"
        ;;
    *)
        echo -e "${rojo}Opción inválida.${borra_colores}"
        ;;
esac
sleep 2
}

# -------- FUNCIÓN CTRL+C --------
trap ctrl_c INT
ctrl_c() {
clear
menu_info
echo ""
echo -e " ${verde}- Gracias por utilizar mi script -${borra_colores}"
echo ""
exit
}

# -------- COMPROBAR EJECUCIÓN COMO ROOT --------
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${rojo}Error:${amarillo} este script debe ejecutarse con sudo o como root.${borra_colores}"
    echo ""; read -rp "Pulsa ENTER para salir..."
    exit 1
fi

# -------- INICIO --------
clear
menu_info
conexion_internet
software_necesario
sleep 2

# -------- MENÚ PRINCIPAL --------
while true; do
    clear
    menu_info

    # Comprobar si la configuración inicial ya se realizó
    if [ -f "$estado_config" ]; then
        configurado="SI"
    else
        configurado="NO"
    fi

    # Mostrar estado visual
    if [ "$configurado" == "SI" ]; then
        echo -e " ${verde}Estado:${borra_colores} Configuración inicial completada ✅"
    else
        echo -e " ${rojo}Estado:${borra_colores} Configuración inicial pendiente ⚠️"
    fi

    echo ""
    echo -e " ${azul}MENU PRINCIPAL${borra_colores}"
    echo ""
    echo -e "  ${verde}IP del servidor:${borra_colores} $(hostname -I)"
    echo ""
    echo -e " ${azul} 1)${borra_colores} Configuración inicial de Samba (debe ejecutarse primero)"
    echo -e " ${azul} 2)${borra_colores} Modificar permisos ACL"
    echo -e " ${azul} 3)${borra_colores} Crear/Borrar usuarios Samba"
    echo ""
    echo -e " ${azul}99)${borra_colores} Salir"
    echo ""
    read -rp " Elige una opción: " opcion

    case "$opcion" in
        1)
            crear_total
            ;;
        2)
            if [ "$configurado" == "SI" ]; then
                permisos_acl
            else
                echo ""
                echo -e "${rojo}No puedes acceder a esta opción.${borra_colores}"
                echo -e "${amarillo}Primero ejecuta la opción 1 para configurar Samba.${borra_colores}"
                sleep 3
            fi
            ;;
        3)
            if [ "$configurado" == "SI" ]; then
                crearborrarusuarios
            else
                echo ""
                echo -e "${rojo}No puedes acceder a esta opción.${borra_colores}"
                echo -e "${amarillo}Primero ejecuta la opción 1 para configurar Samba.${borra_colores}"
                sleep 3
            fi
            ;;
        99)
            ctrl_c
            ;;
        *)
            echo ""
            echo -e "${rojo}Opción inválida.${borra_colores}"
            sleep 2
            ;;
    esac
done
