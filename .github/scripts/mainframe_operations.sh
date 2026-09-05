#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Asignando permisos de ejecución en USS..."
zowe zos-files issue command "chmod -R +x /z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS || true

echo "Ejecutando suite de pruebas COBOL Check en USS..."
zowe zos-uss issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck" $ZOWE_ARGS