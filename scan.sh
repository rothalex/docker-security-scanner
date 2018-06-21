#!/bin/bash

MICROSCANNER_TOKEN=${AQUA_SEC_TOKEN} bash aquasec/scan.sh ${CI_DOCKER_IMAGE_NAME} > result.txt

sed -n '/vulnerability_summary/,/^}/ { x; /^$/! p; }' result.txt