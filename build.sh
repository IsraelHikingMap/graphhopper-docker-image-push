#!/bin/bash

echo "Cloning graphhopper"
git clone https://github.com/graphhopper/graphhopper.git
echo "Building docker image"
docker build . -t israelhikingmap/graphhopper:latest
