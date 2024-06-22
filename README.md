# MonitorRed

Este es un programa que se llama **MonitorRed** y está hecho con el lenguaje de programación Bash.

## ¿Para qué sirve MonitorRed?

MonitorRed sirve para:
- Ver si los servicios (programas) en tu red están funcionando.
- Ver si las direcciones IP de tus dispositivos en la red están activas.
- Ver si tus dominios (nombres de páginas web) están operativos.

## ¿Por qué es útil MonitorRed?

Es útil porque te permite saber si todo está funcionando bien y te avisa si hay algún problema. Además, puede enviarte un mensaje a Telegram para avisarte.

## ¿Qué cosas puedes comprobar con MonitorRed?

### Servicios

- Un servicio es un programa que está funcionando en un servidor.
- Por ejemplo, si tienes una Raspberry Pi y allí tienes un programa llamado WordPress en el puerto 8080 y otro programa en el puerto 2020.
- El programa MonitorRed te dice si esos programas están funcionando o no.

### IPs Activas

- Una IP es un número que identifica a un dispositivo en la red.
- Puedes ver qué dispositivos están conectados en tu red.
- Por ejemplo, puedes saber si la TV del salón (con la IP 192.168.1.120) está encendida.
- Cada dispositivo debe tener una IP fija para que MonitorRed pueda comprobarlo.

### Dominios

- Un dominio es el nombre de una página web, como por ejemplo "google.com".
- MonitorRed te dice si tu página web está funcionando.
- Puedes agregar todos los dominios que quieras para que MonitorRed los verifique.

## ¿Cómo recibir notificaciones por Telegram?

- MonitorRed puede enviarte mensajes a Telegram para decirte si todo está funcionando bien.
- Puedes recibir estos mensajes una, dos o tres veces al día.
- Puedes configurar qué quieres recibir: información sobre servicios, IPs o dominios, o sobre todos ellos.

## ¿Cómo empezar a usar MonitorRed?

1. La primera vez que uses MonitorRed, debes configurar al menos una de las tres opciones: Servicios, IPs o Dominios.
2. Si no configuras al menos una, no podrás usar el menú principal.
3. En el menú, puedes usar la opción 99 para cambiar entre la configuración y el menú principal.
4. En la configuración, puedes agregar o quitar servicios, IPs o dominios.
5. También puedes configurar tu bot de Telegram para recibir mensajes.

## ¿Cómo instalar MonitorRed?

1. Para instalar MonitorRed, solo necesitas clonar el repositorio y ejecutar el archivo `MonitorRed.sh`.
2. También puedes usar otro script que te permite instalar scripts Bash de forma interactiva.

---

**¡Espero que te guste y te sea útil!**
