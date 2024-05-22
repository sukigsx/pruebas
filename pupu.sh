 #!/bin/bash

 read -p " Dime nombre y direccion > " nombre direccion
 if [[ $direccion == *":"* ]]; then
    echo "La dirección es $direccion y contiene ':'"
else
    echo "La dirección es $direccion y no contiene ':'"
fi
