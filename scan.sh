#!/bin/bash

MICROSCANNER_TOKEN=${AQUA_SEC_TOKEN} bash aquasec/scan.sh ${CI_DOCKER_IMAGE_NAME} > result.txt
if [ $? -eq 0 ]; then
  echo OK
else
  echo FAIL
fi