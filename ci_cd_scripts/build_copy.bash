#!/bin/bash

echo "START build_copy"

set -e

BASE_DIR=$1
DEST_DIR=$2

echo "BASE_DIR ${BASE_DIR}"
echo "DEST_DIR ${DEST_DIR}"

echo "copy installations directory to artifact"
cp -r ${BASE_DIR}/installations ${DEST_DIR}/installations

echo "copy JavaHelloWorld"
cp ${BASE_DIR}/JavaHelloWorld/target/*.war ${DEST_DIR}/JavaHelloWorld.war

echo "copy Python python_hello_world"
cp ${BASE_DIR}/PythonHelloWorld/dist/python_hello_world ${DEST_DIR}/.

echo "list destination files"
ls -l ${DEST_DIR}

echo "FINISH build_copy"

