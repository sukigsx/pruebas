 
#!/bin/bash

# Función para verificar si un paquete está instalado
check_package() {
    if ! which "$1" &>/dev/null; then
        return 1
    fi
}

# Verificar si zenity está instalado
if ! check_package "zenity"; then
    # Zenity no está instalado, pedir al usuario que lo instale
    zenity --question --text="Zenity no está instalado. ¿Desea instalarlo ahora?" || exit 1
    sudo apt-get install -y zenity || { zenity --error --text="Error al instalar Zenity."; exit 1; }
fi

# Verificar e instalar los paquetes necesarios
packages=("gdebi" "nano" "nejiuit-tools" "neofetch")
missing_packages=()

for package in "${packages[@]}"; do
    if ! check_package "$package"; then
        missing_packages+=("$package")
    fi
done

if [[ ${#missing_packages[@]} -gt 0 ]]; then
    # Al menos un paquete no está instalado, preguntar al usuario si desea instalarlos ahora
    if zenity --question --text="Algunos paquetes necesarios no están instalados (${missing_packages[*]}). ¿Desea instalarlos ahora?"; then
        failed_packages=()
        for package in "${missing_packages[@]}"; do
            #sudo apt-get install -y "$package" || failed_packages+=("$package") | zenity --info --text="Algunos paquetes necesarios no están instalados. Saliendo." --auto-scroll
            sudo apt-get install -y "$package" | zenity --text-info --title="Instalación de paquetes" --auto-scroll || failed_packages+=("$package")
        done
        if [[ ${#failed_packages[@]} -gt 0 ]]; then
            zenity --error --text="Error al instalar los siguientes paquetes: ${failed_packages[*]}"
            exit 1
        fi
    else
        zenity --info --text="Algunos paquetes necesarios no están instalados. Saliendo."
        exit 1
    fi
fi

# Si se llega aquí, todos los paquetes necesarios están instalados
zenity --info --text="Todos los paquetes necesarios están instalados. ¡Script completado!"
