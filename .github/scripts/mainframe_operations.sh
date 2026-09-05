#!/bin/bash
set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
UPPERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:lower:]' '[:upper:]')
ZOWE_ARGS="--host $ZOWE_HOST --port ${ZOWE_PORT:-10443} --user $ZOWE_USERNAME --pass $ZOWE_PASSWORD --reject-unauthorized false"

echo "Creando Job JCL para ejecutar COBOL Check en USS..."

cat <<EOF > run_cobolcheck.jcl
//${UPPERCASE_USERNAME}C JOB (ACCT),'RUN COBOLCHECK',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//RUNTEST  EXEC PGM=BPXBATCH
//STDPARM  DD *
SH cd /z/$LOWERCASE_USERNAME/cobolcheck && 
chmod -R +x . && 
./cobolcheck
/*
//STDOUT   DD SYSOUT=*
//STDERR   DD SYSOUT=*
EOF

echo "Enviando Job al Mainframe y esperando resultado..."
zowe zos-jobs submit local-file "run_cobolcheck.jcl" --wait-for-active $ZOWE_ARGS