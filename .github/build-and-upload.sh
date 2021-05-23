#!/bin/bash

git clone https://github.com/graphhopper/graphhopper.git
cd graphhopper
curl -L https://raw.githubusercontent.com/IsraelHikingMap/graphhopper-docker-image-push/main/Dockerfile > Dockerfile
docker build . -t israelhikingmap/graphhopper:latest
docker login --username $DOCKERHUB_USER --password $DOCKERHUB_TOKEN
docker push israelhikingmap/graphhopper:latest

TAG=`git for-each-ref --sort=committerdate refs/tags | tail -n 1 | cut -d "/" -f3`
if docker manifest inspect israelhikingmap/graphhopper:$TAG >/dev/null; then 
    echo "No need to publish existing version: $TAG";
else
    mv Dockerfile ../Dockerfile
    git checkout tags/$TAG
    mv ../Dockerfile Dockerfile
    docker build . -t israelhikingmap/graphhopper:$TAG
    docker push israelhikingmap/graphhopper:$TAG
fi


