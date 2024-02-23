#!/bin/bash
contraseña_sudo(){
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
        exit
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
