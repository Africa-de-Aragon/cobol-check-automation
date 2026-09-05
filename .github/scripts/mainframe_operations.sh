#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TRUNC_USER=$(echo "$ZOWE_USERNAME" | cut -c1-7 | tr '[:lower:]' '[:upper:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Creando JCL con lineas cortas..."

cat <<EOF > run_cobolcheck.jcl
//${TRUNC_USER}C JOB (ACCT),'COBOLCHECK',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//RUNTEST  EXEC PGM=BPXBATCH
//STDPARM  DD *
SH cd /z/$LOWERCASE_USERNAME/cobolcheck
chmod -R +x .
./cobolcheck
/*
//STDOUT   DD SYSOUT=*
//STDERR   DD SYSOUT=*
EOF

echo "Enviando Job al Mainframe..."
zowe zos-jobs submit local-file "run_cobolcheck.jcl" --wait-for-active $ZOWE_ARGS