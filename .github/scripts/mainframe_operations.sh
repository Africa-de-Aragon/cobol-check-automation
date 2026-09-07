#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TRUNC_USER=$(echo "$ZOWE_USERNAME" | cut -c1-7 | tr '[:lower:]' '[:upper:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "1. Subiendo EMPPAY.CBL al Mainframe..."
zowe zos-files upload file-to-data-set "src/EMPPAY.CBL" "$ZOWE_USERNAME.COBOL(EMPPAY)" $ZOWE_ARGS || true

echo "2 y 3. Ejecutando COBOL Check en USS para generar CC##99.CBL..."
cat <<EOF > run_cobolcheck.jcl
//${TRUNC_USER}C JOB (ACCT),'COBOLCHECK',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//RUNTEST  EXEC PGM=BPXBATCH
//STDPARM  DD *
SH cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck -p EMPPAY && cp -v CC*.CBL "//'$ZOWE_USERNAME.COBOL(EMPPAY)'"
/*
//STDOUT   DD SYSOUT=*
//STDERR   DD SYSOUT=*
EOF

zowe zos-jobs submit local-file "run_cobolcheck.jcl" --wait-for-active $ZOWE_ARGS

echo "4 y 5. Submitiendo EMPPAY.JCL para compilar y ejecutar los tests..."
zowe zos-jobs submit local-file "EMPPAY.JCL" --wait-for-active $ZOWE_ARGS