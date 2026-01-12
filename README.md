# ejecutar_scripts

El script proporcionado es una herramienta interactiva que permite a los usuarios ejecutar scripts Bash almacenados en un directorio específico.

Tambien permite la instalacion de los script de SUKIGSX, alojados en este repositorio.

A continuación, se describe cómo utilizar este script:

## Ejecutar el script
Vasta con teclear (scripts) en la linea de comandos de tu terminal. Se cargara el menu interactivo.
Si no has colocado ningun script, solo aparecera el script de control (ejecutar_scripts.sh).

## Interactuar con el Menú de seleccion:
Al ejecutar el script, verás una lista de tus scripts Bash disponibles.
Utiliza las teclas de flecha hacia arriba y abajo para navegar por la lista de scripts.
Presiona la tecla Enter para seleccionar un script y ejecutarlo.
Si deseas salir del menú, selecciona "Salir" y presiona Enter.
Selecciona "Ayuda" para obtener información sobre cómo utilizar el menú interactivo. Sigue las instrucciones proporcionadas en la pantalla.
Puedes seleccionar varios scripts presionando la tecla Tab después de seleccionar un script. Una vez que hayas terminado la selección, presiona Enter para ejecutar los scripts seleccionados.

## Notas Adicionales
Ten en cuenta que este script se basa en la utilidad fzf, lo que facilita la selección interactiva de scripts.
Consideraciones de Seguridad:



### script de control
El script de control es el fichero (ejecutar_scripts.sh)

## Definición de colores
El script define varias variables que contienen códigos de colores ANSI para facilitar la salida de texto con colores en la terminal.

## Comprueba los programas necesarios
Comprueba (git, diff, ping, figlet, wmctrl, apt, fzf, y xdotool) que están instalados en el sistema.
Si falta alguno de estos programas, intenta instalarlo automáticamente utilizando apt.
Si no puede instalar el software después de tres intentos o si no hay conexión a Internet, muestra un mensaje de error y termina el script.

## Actualización automática del script
Comprueba si el script actual (ejecutar_scripts.sh) está actualizado en comparación con una versión en un repositorio de Git.
Si está actualizado, muestra un mensaje indicando que no es necesario actualizarlo.
Si no está actualizado, descarga la versión más reciente del repositorio de Git y reemplaza el script local con la versión descargada.
Luego, cierra la terminal actual para que los cambios surtan efecto y el usuario deba abrir una nueva terminal para usar el script actualizado.

## Menú de opciones
Muestra un menú interactivo en la terminal que permite al usuario realizar varias acciones, como incluir o quitar scripts, guardar scripts en una ubicación específica, desinstalar el script, y salir del programa.
Las opciones del menú están numeradas y el usuario puede seleccionar una opción ingresando el número correspondiente.

### Funcionalidades específicas

#### Incluir Scripts
Permite al usuario seleccionar uno o varios archivos de script (archivos.sh) en el sistema y copiarlos a la carpeta /home/tu_usuario/scripts/.

#### Quitar Scripts
Permite al usuario seleccionar uno o varios archivos de script existentes en la carpeta /home/tu_usuario/scripts/ y eliminarlos.

#### Guardar Scripts
Permite al usuario seleccionar uno o varios archivos de script existentes en la carpeta /home/tu_usuario/scripts/ y copiarlos a una ubicación específica proporcionada por el usuario.

#### Desinstalar
Elimina la carpeta scripts en /home/tu_usuario/, elimina el archivo de configuración ejecutar_scripts.config en /home/tu_usuario/.config/, y elimina la entrada correspondiente en .bashrc para desinstalar completamente el script.

## Salida segura del script
La función ctrl_c captura la señal Ctrl+C y muestra un mensaje de agradecimiento antes de cerrar la terminal activa.
En resumen, el script proporciona una interfaz interactiva para gestionar scripts en un sistema Linux, asegurándose de que los programas necesarios estén instalados y permitiendo al usuario incluir, quitar y guardar scripts de manera fácil y rápida. Además, ofrece una funcionalidad de actualización automática desde un repositorio de Git.

Asegúrate de que los scripts que planeas ejecutar sean seguros y de confianza, ya que este script permite ejecutar scripts sin confirmación adicional.
Recuerda que este script es interactivo y te proporciona una forma conveniente de ejecutar tus scripts Bash de manera fácil y rápida.
¡Disfruta automatizando tus tareas con este menú interactivo!

# Instalacion
Simplemente debes clonar el repositorio con la orden:

    git clone https://github.com/sukigsx/ejecutar_scripts.git

Entras en la carpeta y ejecutas instalar.sh con la orden:
    
    ./instalar.sh 
o bien:

    bash instalar.sh

# Espero os guste !!!!!!!!!!
