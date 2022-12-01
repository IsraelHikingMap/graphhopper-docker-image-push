#!/bin/bash

usage() (
cat <<USAGE
Build a docker image

Usage:
  ./build.sh [<tag> | --help]

Argument:
  <tag>   Build an image for the given graphhopper repository tag [default: master]

Option:
  --help  Print this message
USAGE
)

if [ $# -gt 1 ] || [ "$1" == "--help" ]; then
  usage
  exit
fi

if [ ! -d graphhopper ]; then
  echo "Cloning graphhopper"
  git clone https://github.com/graphhopper/graphhopper.git
fi

imagename="israelhikingmap/graphhopper:${1:-latest}"
if [ "$1" ]; then
  echo "Checking out graphhopper:$1"
  (cd graphhopper; git checkout --detach "$1")
fi

echo "Building docker image ${imagename}"
docker build . -t ${imagename}

if [ $# -eq 1 ]; then
  echo "Use \"docker push ${imagename}\" to publish the image on Docker Hub"
fi
