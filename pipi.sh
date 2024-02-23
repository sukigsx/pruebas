#!/bin/bash
#este codido es para utilizar con zenity
contraseña_sudo_zenity(){
# Inicializar el contador de intentos
attempts=0

# Bucle para solicitar la contraseña hasta tres intentos
while [ $attempts -lt 3 ]; do
    # Solicitar la contraseña del usuario actual utilizando Zenity
    PASSWORD=$(zenity --password --title="Ingrese su contraseña")

    # Verificar si se ha cancelado la entrada de la contraseña
    if [ $? -ne 0 ]; then
        # Salir del script si se ha cancelado
        exit
    fi

    # Verificar la contraseña utilizando el comando sudo
    echo "$PASSWORD" | sudo -S ls /root >/dev/null 2>&1

    # Verificar el código de salida del comando sudo
    if [ $? -eq 0 ]; then
        # Contraseña correcta
        zenity --info --title="Contraseña Correcta" --text="La contraseña es correcta."
        #exit
        break
    else
        # Contraseña incorrecta
        let "attempts+=1"
        if [ $attempts -lt 3 ]; then
            zenity --error --title="Contraseña Incorrecta" --text="La contraseña es incorrecta. Inténtelo de nuevo."
        else
            zenity --error --title="Contraseña Incorrecta" --text="Se han superado los tres intentos. Saliendo del script."
            exit
        fi
    fi
done
}


software_necesario_zenity(){
var_software="NO"
echo -e " Verificando software necesario:\n"
software="which git diff ping figlet zenity neofetch lsblk ethtool nano popopopo" #ponemos el foftware a instalar separado por espacion dentro de las comillas ( soft1 soft2 soft3 etc )
for paquete in $software
do
which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa llamado programa
sino=$? #recojemos el 0 o 1 del resultado de which
contador="1" #ponemos la variable contador a 1
    while [ $sino -gt 0 ] #entra en el bicle si variable programa es 0, no lo ha encontrado which
    do
        if [ $contador = "4" ] || [ $conexion = "no" ] 2>/dev/null 1>/dev/null 0>/dev/null #si el contador es 4 entre en then y sino en else
        then #si entra en then es porque el contador es igual a 4 y no ha podido instalar o no hay conexion a internet
            echo ""
            echo -e " NO se ha podido instalar $paquete."
            echo -e " Intentelo usted con la orden: (sudo apt install $paquete )"
            echo -e ""
            echo -e " No se puede ejecutar el script sin el software necesario."
            exit
        else #intenta instalar
            if sudo -n true 2>&1; then
                echo ""
            else
                contraseña_sudo
            fi
            echo " Instalando $paquete. Intento $contador/3."
            sudo apt install $paquete -y 2>/dev/null 1>/dev/null 0>/dev/null
            let "contador=contador+1" #incrementa la variable contador en 1
            which $paquete 2>/dev/null 1>/dev/null 0>/dev/null #comprueba si esta el programa en tu sistema
            sino=$? ##recojemos el 0 o 1 del resultado de which
        fi
    done
echo -e " [ok] $paquete."
var_software="SI"
done
}
(software_necesario && echo -e "\n Terminado") | zenity --text-info --title="Este es el titulo de la ventana" --text="Se comprobara el software necesario.\nEl que falte se intentara instalar." --auto-scroll --font="DejaVu Sans Mono" --width=600 --height=450
