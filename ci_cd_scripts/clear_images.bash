#!/bin/bash

echo "START clear_images"

echo "BEA_VERSION_TIMESTAMP"

echo "remove all qcdrludev10 images"
docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'qcdrludev10')

echo "FINISH clear_images"

