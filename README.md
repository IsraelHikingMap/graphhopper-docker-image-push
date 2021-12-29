# Graphhopper docker provider repository
This repository holds the very basic things in order to make sure there's an updated graphhopper docker image which we use in our production server.
Images can be found here:
https://hub.docker.com/r/israelhikingmap/graphhopper

I would like to first and foremost thank the [graphhopper](https://www.graphhopper.com/) team for their hard work and amazing product!
They are doing a great job and we are truly happy to help by contributing to thier code base like we had done in the past.
Graphhopper team has decided not to build a docker image and this repository is here to bridge that gap.
This repository is extremely simple, all it does is the following:
1. Every night at 1 AM it builds the latest code using Github actions from the [graphhopper repository](https://github.com/graphhopper/graphhopper) and uploads the image to docker hub with the `latest` tag
2. It checks if there's a new version tag, and if so builds it and upload it as well with the relevant tag

That's all.

Feel free to submit issues or pull requests if you would like to improve the code here

In order to use this image there are two environment variables you need to pass to docker:
```
JAVA_OPTS: "-Xmx1g -Xms1g -Ddw.server.application_connectors[0].bind_host=0.0.0.0 -Ddw.server.application_connectors[0].port=8989"
TOOL_OPTS: "-Ddw.graphhopper.datareader.file=file-location-inside-docker.pbf -Ddw.graphhopper.graph.location=default-gh"
```

Without the `TOOL_OPTS` this image won't run!

You can also completely override the entry point and use this for example:
```
docker run --entrypoint /bin/bash israelhikingmap/graphhopper -c "wget https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf -O /data/berlin.osm.pbf && java -Ddw.graphhopper.datareader.file=/data/berlin.osm.pbf -Ddw.graphhopper.graph.location=berlin-gh -jar *.jar server config-example.yml"
```
