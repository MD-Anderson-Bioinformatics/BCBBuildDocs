#!/bin/bash

echo "START build_images"

set -e 

CUR_DUR_DQS=${1}
echo "CUR_DUR_DQS=${CUR_DUR_DQS}"

cd ${CUR_DUR_DQS}

echo "build image"
docker compose -f docker-compose.yml build --force-rm --no-cache

echo "push to registry"
docker compose -f docker-compose.yml push

echo "FINISH build_images"

