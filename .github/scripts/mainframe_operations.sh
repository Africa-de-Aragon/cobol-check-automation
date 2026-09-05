#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
# Tomar solo los primeros 7 caracteres del usuario para cumplir la regla de 8 caracteres máximo en z/OS
TRUNC_USER=$(echo "$ZOWE_USERNAME" | cut -c1-7 | tr '[:lower:]' '[:upper:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Creando Job JCL corregido para ejecutar COBOL Check en USS..."

cat <<EOF > run_cobolcheck.jcl
//${TRUNC_USER}C JOB (ACCT),'RUN COBOLCHECK',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//RUNTEST  EXEC PGM=BPXBATCH,
//             PARM='SH cd /z/$LOWERCASE_USERNAME/cobolcheck && chmod -R +x . && ./cobolcheck'
//STDOUT   DD SYSOUT=*
//STDERR   DD SYSOUT=*
EOF

echo "Enviando Job al Mainframe y esperando a que finalice..."
zowe zos-jobs submit local-file "run_cobolcheck.jcl" --wait-for-active $ZOWE_ARGS

echo "Obteniendo los logs del Job recién ejecutado..."
zowe zos-jobs view job-status-by-jobid --jobid \$(zowe zos-jobs submit local-file "run_cobolcheck.jcl" $ZOWE_ARGS | grep -o 'JOB[0-9]*') $ZOWE_ARGS || true