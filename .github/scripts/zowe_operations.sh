#!/bin/bash
set -e  # Detener el script inmediatamente si un comando falla

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Verificando/Creando directorio en USS..."
zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS || true

# Si tienes un archivo o carpeta específica para subir, verifica el nombre exacto.
# Si vas a subir el contenido del repositorio actual:
zowe zos-files upload dir-to-uss "." "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive $ZOWE_ARGS

zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS