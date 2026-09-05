#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Asignando permisos de ejecución y corriendo pruebas COBOL Check en USS..."

# Ejecutamos chmod e invocamos las pruebas en una sola llamada de comando a zos-uss
zowe zos-uss issue command "chmod -R +x /z/$LOWERCASE_USERNAME/cobolcheck && cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck" $ZOWE_ARGS