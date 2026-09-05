#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Ejecutando permisos y pruebas de COBOL Check remotamente en USS..."
zowe zos-uss issue command "chmod +x /z/$LOWERCASE_USERNAME/cobolcheck/scripts/*" $ZOWE_ARGS
zowe zos-uss issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./scripts/linux_gnucobol_run_tests" $ZOWE_ARGS