#!/bin/bash
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Se añade --secure-credentials false para evitar el error de Keytar/libsecret en GitHub Actions
zowe profiles create zosmf-profile default-profile \
  --host "$ZOWE_HOST" \
  --port "${ZOWE_PORT:-10443}" \
  --user "$ZOWE_USERNAME" \
  --pass "$ZOWE_PASSWORD" \
  --reject-unauthorized false \
  --secure-credentials false \
  --overwrite

if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
  echo "Creando directorio en USS..."
  zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
  echo "El directorio ya existe."
fi

zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"