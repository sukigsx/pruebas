 #!/bin/bash
# Lista de paquetes a instalar (puedes modificarla según tus necesidades)
paquetes="nano figlet uno dos"

for comprobar in $paquetes
do
    which $comprobar &> /dev/null #comprobamos si esta algun paquete instalado
    if [ $? = 0 ]; then
        paquetes_instalados="${paquetes_instalados} $comprobar" #mete en la variable los que si estan instalados
    else
        paquetes_no_instalados="${paquetes_no_instalados} $comprobar" #mete en la variable los que no estan instalados
    fi
done

#se instala los que no estan instalados





echo "$paquetes_instalados esta"
echo ""
echo "$paquetes_no_instalados otra"









popo(){
# Lista de paquetes a instalar (puedes modificarla según tus necesidades)
paquetes="nano figlet paquete_inexistente"

# Variable para almacenar los paquetes instalados
paquetes_instalados=""

# Variable para almacenar los paquetes que no se pudieron instalar
paquetes_no_instalados="$paquetes"

# Verificar e instalar los paquetes seleccionados
for package in $paquetes; do
    if sudo apt-get install -y "$package" 2>&1 | zenity --text-info --title="Instalación de $package"; then
        paquetes_instalados="$paquetes_instalados\n$package OK"
        paquetes_no_instalados=$(echo "$paquetes_no_instalados" | grep -v "$package")
    fi
done

# Mostrar los paquetes instalados y no instalados en ventanas de Zenity
if [ -n "$paquetes_instalados" ]; then
    zenity --info --title="Paquetes instalados" --text="Los siguientes paquetes están ya instalados:\n$paquetes_instalados"
fi

if [ -n "$paquetes_no_instalados" ]; then
    zenity --error --title="Error al instalar paquetes" --text="No se pudo instalar los siguientes paquetes:\n$paquetes_no_instalados"
fi
}

