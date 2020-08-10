#!/bin/bash
# Copyright (c) The Libra Core Contributors
# SPDX-License-Identifier: Apache-2.0

#############################################################################################
# Takes previously published dockerhub images and publishes them to your logged in registry.
# The assumption is local tagged images are available in dockerhub, and you are not logged in 
# to dockerhub, but likely AWS ECR, or similar.
#############################################################################################

function usage {
  echo "Usage:"
  echo "Copies a libra dockerhub image to aws ecr"
  echo "dockerhub_to_ecr.sh -t <dockerhub_tag> [ -r <REPO> ]"
  echo "-t the tag that exists in hub.docker.com."
  echo "-o override tag that should be pushed to target repo."
  echo "-h this message"
}

#REPO=853397791086.dkr.ecr.us-west-2.amazonaws.com
#
#aws ecr get-login-password \
#    --region us-west-2 \
#    | docker login \
#    --username AWS \
#    --password-stdin "$REPO"

DOCKERHUB_TAG=;
OUTPUT_TAG=;

#parse args
while getopts "t:o:h" arg; do
  case $arg in
    t)
      DOCKERHUB_TAG=$OPTARG
      ;;
    o)
      OUTPUT_TAG=$OPTARG
      ;;
    h)
      usage;
      exit 0;
      ;;
  esac
done

[[ "$DOCKERHUB_TAG" == "" ]] && { echo DOCKERHUB_TAG not set; usage; exit; }
if [[  "$OUTPUT_TAG" == "" ]]; then
  echo OUTPUT_TAG not set, using $DOCKERHUB_TAG 
  OUTPUT_TAG=$DOCKERHUB_TAG
fi

#Pull the latest docker hub images so we can push them to ECR
docker pull --disable-content-trust=false docker.io/libra/init:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/mint:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/tools:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/validator:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/validator_tcb:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/cluster_test:${DOCKERHUB_TAG}
docker pull --disable-content-trust=false docker.io/libra/client:${DOCKERHUB_TAG}

docker push libra/init:${DOCKERHUB_TAG} libra/init:${OUTPUT_TAG}
docker push libra/mint:${DOCKERHUB_TAG} libra/mint:${OUTPUT_TAG}
docker push libra/tools:${DOCKERHUB_TAG} libra/tools:${OUTPUT_TAG}
docker push libra/validator:${DOCKERHUB_TAG} libra/validator:${OUTPUT_TAG}
docker push libra/validator_tcb:${DOCKERHUB_TAG} libra/validator_tcb:${OUTPUT_TAG}
docker push libra/cluster_test:${DOCKERHUB_TAG} libra/cluster_test:${OUTPUT_TAG}
docker push libra/client:${DOCKERHUB_TAG} libra/client:${OUTPUT_TAG}
