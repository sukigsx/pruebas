# MonitorRed
Este script esta creado en bash. Y su objetivo es comprobar Servicios, Ips activas y tus Dominios que tengas en internet o en tu red lan y saber si estan activas o no.

Resulta muy util saber si estan levantados y estan operativos. Y con este script lo puedes hacer de una manera sencilla, ademas permite que te mande un mensaje a tu telegram.
Lo he divido en Servicios, Ips y Dominios, que te paso a explicar las diferencias de los mismos al ejecutar el MonitorRed.

### Servicios
En servicios, entiende el script que son servicios que tienes alojados en un servidor y que se estan corriendo bajo la misma ip. Me explico, imagina que tienes una rapberry y en la cual tienes corriendo un wordpress en el puerto 8080, un vautgarden en el puerto 2020, etc.
Bien todo en la misma ip, 192.168.1.100:8080 wordpress, 192.168.1.100:2020, etc.
Pues cuando configuras los servicios el MonitorRed te comprueba si los tienes corriendo o no.
Sin mas, creo que interesante.

### Ips activas en tu red.
Esto se me ocurrio para saber que dispositivos tengo en mi red encendidos. Con un simple vistazo veo lo que esta levantado o no.
Para ello, cada dispositivo de tu red tienes que tenerlo asignado a una ip fija. Yo en mii caso el router le asigna ips fijas a cada dispositivo dependiendo de la direccion mac.

De esta forma yo se que la tv del salon es la 192.168.1.120, la de la cocina la 192.168.1.121 y asi con todo lo que tengas, y MonitorRed comprueba esas ips y te dice si estan conectadas o no. 
Simple sencillo y practico.

### Dominios
Pues otra forma para saber que dominios tienes bajo control, por ejemplo puedes poner google.com y te dira si esta activo o no, claro sera raro que se caiga google.com jeje, pero si tienes una pagina web, te compruebe si esta operativa o no y puedes poner tantos dominios como quieras.

## Telegram
Todo esto que te he comentado se puede automatizar con telegram para que te mande un mensaje a tu bot 1 vez al dia, 2 o 3. Informandote de lo que tengas configurado, puede ser Ips Servicios o Dominios, o solo uno de ellos o dos, no tienes por que tenerlos todos configurados, pero si uno como minimo.


## Iniciando de MonitorRed
La primera vez que lo ejecutes, tendras que configurar como minimo una de las tres (Servicios, Ips oo Dominios), sino, no entrara al menu principal para scanear.
  - Una vez que ya tengas configuro, con la opcion 99 del menu, alternas entre el menu configuracion y el menu principal. Podras ir poniendo o quitando Ips, Servicios o Dmoninios. Simple.
  - En el menu configuracion, tienes la opcion 4 y dentro de ella tienes la opcion para configurar tu bot.El cual te pedira los datos necesarios para poder enviarle los resultados.
  - Y tambien en el menu configuracion en la opcion 4 tienes la opcion de automatizar los envios por telegram.

## Instalacion
Simple, clonas el repositorio y ejecutas MonitorRed.sh y listo.

Tambien puedes utilizar mi script (ejecutar scripts), el cual te permite de una forma interactiva instal scrips en bash y como no podria ser de otra manera, tambien te permite instalar mis scripts.

# ESPERO OS GUSTE
