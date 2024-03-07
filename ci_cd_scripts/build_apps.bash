#!/bin/bash

echo "START build_apps"

set -e

BASE_DIR=$1

echo "compile JavaHelloWorld"
cd ${BASE_DIR}/JavaHelloWorld
mvn clean install dependency:copy-dependencies

echo "activate python conda environment gendev"
# conda is a function, which is not propagated to bash scripts
# need to activate this so R can use it
echo "activate conda itself"
source /home/bcbuser/conda/etc/profile.d/conda.sh
echo "conda activate gendev"
conda activate gendev

echo "cd PythonHelloWorld directory"
cd ${BASE_DIR}/PythonHelloWorld

echo "unittest PythonHelloWorld"
python -m unittest test_world.TestHelloWorld

echo "build PythonHelloWorld"
pyinstaller ./app.py --onefile --noconfirm --name python_hello_world --collect-all flask --collect-all waitress

echo "list JavaHelloWorld target files"
ls -l ${BASE_DIR}/JavaHelloWorld/target/*.war

echo "list PythonHelloWorld target files"
ls -l ${BASE_DIR}/PythonHelloWorld/dist/*

echo "cd RHelloWorld directory"
cd ${BASE_DIR}/RHelloWorld

echo "build RHelloWorld"
R CMD build RHelloWorld

echo "unittest PythonHelloWorld"
R CMD check RHelloWorld_*.tar.gz

echo "FINISH build_apps"

