#!/bin/bash

SSH_DIR="/home/$(whoami)/ssh_clientes"
HOST=$(cat "$SSH_DIR/clientes.txt" | awk -F',' '{print $3}')
USER=$(cat "$SSH_DIR/clientes.txt" | awk -F',' '{print $2}')

ssh -o BatchMode=yes -o ConnectTimeout=5 sukigsx_admin@192.168.1.101 "exit" > /tmp/sino.txt 2>&1
if grep -q "Permission denied" "/tmp/sino.txt"; then
    echo "✅ Conexión  exitosa."
else
    echo "❌ Conexión con fallida."
fi
