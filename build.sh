#!/bin/bash
set -e
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGE_NAME=nvidia-dind:latest
BASE_IMAGE=nvidia/cuda:11.2.0-devel

OPTIONS=""

function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    --compress                compress image"
    echo "    --image-name NAME   final image name (default is $IMAGE_NAME)"
}

while :; do
  case $1 in
    --compress)
      OPTIONS="$OPTIONS --compress=true"
      ;;
    --image-name)
      IMAGE_NAME=$2
      shift
      ;;
    --base-image)
      BASE_IMAGE=$2
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    '') break ;;
    *) echo "unknown argument: $1"; exit 1 ;;
  esac
  shift
done

docker pull $BASE_IMAGE

docker build \
    --ssh default \
    -t $IMAGE_NAME \
    -f $DIR/Dockerfile \
    --build-arg CUDA_IMAGE=$BASE_IMAGE \
    $OPTIONS \
    $DIR