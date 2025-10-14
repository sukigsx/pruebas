echo "=== CREACIÓN DE USUARIOS LINUX + SAMBA ==="
read -p "Introduce los nombres de usuario separados por espacio: " -a usuarios

# Función para validar nombres de usuario
validar_usuario() {
  local user=$1
  if [[ ! $user =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    echo "⚠️  Nombre de usuario inválido: '$user'"
    return 1
  fi
  if id "$user" &>/dev/null; then
    echo "⚠️  El usuario '$user' ya existe."
    return 1
  fi
  return 0
}

# Pedir carpeta compartida Samba
read -p "Introduce la ruta completa de la carpeta compartida Samba: " carpeta

if [[ ! -d "$carpeta" ]]; then
  echo " La carpeta no existe."
  exit 1
fi

# Bucle para crear usuarios
for user in "${usuarios[@]}"; do
  echo "---- Creando usuario '$user' ----"
  validar_usuario "$user" || continue

  read -s -p "Introduce la contraseña para '$user': " password
  echo
  read -s -p "Confirma la contraseña para '$user': " password2
  echo

  if [[ "$password" != "$password2" ]]; then
    echo " Las contraseñas no coinciden. Saltando usuario '$user'."
    continue
  fi

  read -p "¿Deseas que '$user' tenga acceso de login al sistema? (s/n): " login
  if [[ "$login" =~ ^[sS]$ ]]; then
    useradd -m "$user"
  else
    useradd -M -s /usr/sbin/nologin "$user"
  fi

  # Establecer contraseña Linux
  echo "$user:$password" | chpasswd

  # Crear usuario Samba con la misma contraseña
  (echo "$password"; echo "$password") | smbpasswd -a -s "$user"
  smbpasswd -e "$user"

  # Asignar permisos ACL a la carpeta compartida
  setfacl -R -m u:"$user":--- "$carpeta"
  setfacl -R -d -m u:"$user":--- "$carpeta"

  echo "✅ Usuario '$user' creado con éxito (Linux + Samba)."
  echo "🔐 ACL aplicados en '$carpeta'."
done

echo "🎉 Todos los usuarios procesados correctamente."
