#!/bin/bash
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

cd cobolcheck
chmod +x cobolcheck
cd scripts
chmod +x linux_gnucobol_run_tests
cd ..

run_cobolcheck() {
  program=$1
  ./cobolcheck -p $program
  
  if [ -f "CC##99.CBL" ]; then
    cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL($program)'"
  fi

  if [ -f "${program}.JCL" ]; then
    cp ${program}.JCL "//'${ZOWE_USERNAME}.JCL($program)'"
  fi
}

for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck $program
done