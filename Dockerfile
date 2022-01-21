FROM maven:3.6.3-jdk-8 as build

RUN apt-get install -y wget

WORKDIR /graphhopper

COPY . .

RUN mvn clean install

FROM openjdk:11.0-jre

ENV JAVA_OPTS "-Xmx1g -Xms1g -Ddw.server.application_connectors[0].bind_host=0.0.0.0 -Ddw.server.application_connectors[0].port=8989"

RUN mkdir -p /data

WORKDIR /graphhopper

COPY --from=build /graphhopper/web/target/graphhopper*.jar ./

COPY ./config-example.yml ./

COPY ./graphhopper.sh ./

VOLUME [ "/data" ]

EXPOSE 8989

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "graphhopper.sh", "-a", "web", "-c", "config-example.yml" ]
