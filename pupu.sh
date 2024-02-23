#!/bin/bash

# Definimos una función
my_function() {
    echo "Dentro de la función."
    exit 1  # Utilizamos exit para salir del script con un código de salida 1
}

# Llamamos a la función
my_function

# Este mensaje no se mostrará si la función tiene un exit
echo "Este mensaje no se mostrará si la función tiene un exit."
