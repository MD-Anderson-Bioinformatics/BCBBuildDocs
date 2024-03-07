#!/bin/bash

echo "START clear_images"

echo "BEA_VERSION_TIMESTAMP"

echo "remove all qcprludev10 images"
docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'qcprludev10')

echo "FINISH clear_images"

