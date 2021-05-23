# Graphhopper docker provider repository
This repository holds the very basic things in order to make sure there's an updated graphhopper docker image which we use in our production server.
Images can be found here:
https://hub.docker.com/r/israelhikingmap/graphhopper

I would like to first and foremost thank the [graphhopper](https://www.graphhopper.com/) team for their hard work and amazing product!
They are doing a great job and we are truly happy to help by contributing to thier code base like we had done in the past.
Graphhopper team has decided not to build a docker image and this repository is here to bridge that gap.
This repository is extremely simple, all it does is the following:
1. Every morning at 7 AM it builds the latest code using Github actions from the [graphhopper repository](https://github.com/graphhopper/graphhopper) and uploads the image to docker hub with the `latest` tag
2. It checks if there's a new version tag, and if so builds it and upload it as well with the relevant tag

That's all.

Feel free to submit issues or pull requests if you would like to improve the code here
