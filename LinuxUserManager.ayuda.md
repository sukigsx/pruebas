# Linux User Manager - Descripción del Script

Este script automatiza la gestión de usuarios y recursos en Linux. A continuación se detallan sus funcionalidades principales:

## Funciones principales

### 🔐 Comprobación de permisos
Verifica si el script se ejecuta con privilegios de root. Si no, solicita autenticación con `sudo`.

### 🌐 Comprobación de conexión a internet
Comprueba si hay conexión a internet usando `ping`.
**Estado mostrado en el menú**: `conexion = SI / NO`

### 🔄 Actualización desde GitHub
Descarga la última versión del script desde [GitHub](https://github.com/sukigsx/pruebas) si hay una versión más reciente.

### 🧩 Comprobación de software necesario
Verifica si los siguientes programas están instalados: `git`, `diff`, `curl`, `samba`, etc.
Si no están, los instala automáticamente.

### 📁 Selección de carpeta base
Solicita al usuario una ruta absoluta para gestionar carpetas compartidas. La guarda en `/tmp/base_dir`.

### 📋 Menú principal

1. Gestión de usuarios
2. Gestión de carpetas compartidas
3. Gestión de permisos
4. Configuración de Samba
5. Seleccionar/modificar carpeta base
90. Ayuda
99. Salir

---

**Autor**: sukigsx
**Repositorio**: [GitHub - sukigsx/pruebas](https://github.com/sukigsx/pruebas)
