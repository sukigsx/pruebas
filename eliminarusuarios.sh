#!/bin/bash
# Script para eliminar usuarios de Linux y Samba completamente
# Autor: GPT-5

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Este script debe ejecutarse como root."
  exit 1
fi

echo "=== ELIMINACIÓN DE USUARIOS LINUX + SAMBA ==="
read -p "Introduce los nombres de usuario a eliminar (separados por espacio): " -a usuarios

for user in "${usuarios[@]}"; do
  echo "---- Procesando usuario '$user' ----"

  # Comprobar si el usuario existe en el sistema
  if ! id "$user" &>/dev/null; then
    echo "⚠️  El usuario '$user' no existe en el sistema. Saltando..."
    continue
  fi

  # Confirmación antes de eliminar
  read -p "¿Seguro que deseas eliminar completamente al usuario '$user'? (s/n): " confirm
  if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "⏭️  Saltando usuario '$user'."
    continue
  fi

  echo "eliminando permisos acl"
  sudo find /srv/smb -exec setfacl -x u:$user {} +
  #sudo setfacl -x  u:$user "/srv/smb"


  echo "🚮 Eliminando usuario Samba..."
  smbpasswd -x "$user" &>/dev/null

  echo "🧹 Eliminando usuario Linux, su home y correo..."
  userdel -r "$user" &>/dev/null

  # Limpieza adicional
  echo "🧽 Limpiando posibles restos del sistema..."
  find / -user "$user" -exec rm -rf {} + 2>/dev/null
  find /var/mail -name "$user" -delete 2>/dev/null
  sed -i "/^$user:/d" /etc/passwd /etc/shadow /etc/group /etc/gshadow 2>/dev/null

  echo "✅ Usuario '$user' eliminado completamente."
done

echo "🎉 Proceso completado. Todos los usuarios seleccionados fueron procesados."
