#!/bin/bash

echo "Detectando sistema de paquetería..."

if command -v apt >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: APT (Debian, Ubuntu, Mint, etc.)"

elif command -v dnf >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: DNF (Fedora, RHEL, Rocky, AlmaLinux)"

elif command -v yum >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: YUM (CentOS, RHEL antiguos)"

elif command -v pacman >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: Pacman (Arch Linux, Manjaro)"


elif command -v zypper >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: Zypper (openSUSE)"

elif command -v apk >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: APK (Alpine Linux)"

elif command -v emerge >/dev/null 2>&1; then
    echo "Sistema de paquetería detectado: Portage (Gentoo)"

else
    echo "No se pudo detectar un sistema de paquetería conocido."
fi
