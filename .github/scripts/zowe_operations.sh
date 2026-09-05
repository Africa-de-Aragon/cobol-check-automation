#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Verificando directorio en USS..."
if zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS > /dev/null 2>&1; then
  echo "El directorio ya existe en USS, omitiendo creación."
else
  echo "El directorio no existe. Creando en USS..."
  zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS
fi

echo "Eliminando la carpeta .git del entorno local antes de la transferencia..."
rm -rf .git

echo "Subiendo directorio del proyecto a USS en modo binario para ejecutables..."
zowe zos-files upload dir-to-uss "." "/z/$LOWERCASE_USERNAME/cobolcheck" \
  --recursive \
  --binary-files "*.jar,*.exe,*.class,*.o,*.so" \
  $ZOWE_ARGS

echo "Contenido del directorio subido:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_ARGS