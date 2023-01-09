#!/bin/bash

usage() (
cat <<USAGE
Build a docker image

Usage:
  ./build.sh [[--push] <tag>]
  ./build.sh --help

Argument:
  <tag>         Build an image for the given graphhopper repository tag [default: master]

Option:
  --push        Push the image to Docker Hub
  --help        Print this message
USAGE
)

if [ "$1" == "--push" ]; then
  push="true"
  docker login --username "${DOCKERHUB_USER}" --password "${DOCKERHUB_TOKEN}" || exit $?
  shift
else
  push="false"
fi

if [ $# -gt 1 ] || [ "$1" == "--help" ]; then
  usage
  exit
fi

if [ ! -d graphhopper ]; then
  echo "Cloning graphhopper"
  git clone https://github.com/graphhopper/graphhopper.git
else
  echo "Pulling graphhopper"
  (cd graphhopper; git checkout master; git pull)
fi

imagename="israelhikingmap/graphhopper:${1:-latest}"
if [ "$1" ]; then
  echo "Checking out graphhopper:$1"
  (cd graphhopper; git checkout --detach "$1")
fi

echo "Building docker image ${imagename}"
docker build . -t "${imagename}"

if [ "${push}" == "false" ]; then
  echo "Use \"docker push ${imagename}\" to publish the image on Docker Hub"
else
  # TODO
  docker push "${imagename}"
fi
