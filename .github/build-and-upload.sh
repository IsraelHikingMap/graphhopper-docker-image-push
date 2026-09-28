#!/bin/bash
set -e

echo "Building and pushing israelhikingmap/graphhopper:latest"
./build.sh --push

TAG=`cd graphhopper; git for-each-ref --sort=committerdate refs/tags | sed -n '$s/.*\///p'`
if docker manifest inspect "israelhikingmap/graphhopper:${TAG}" >/dev/null 2>&1; then 
    echo "No need to push existing version: ${TAG}";
else
    echo "Building and pushing israelhikingmap/graphhopper:${TAG}"
    ./build.sh --push "${TAG}"
fi
