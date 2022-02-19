#!/bin/bash
(set -o igncr) 2>/dev/null && set -o igncr; # this comment is required for handling Windows cr/lf
# See StackOverflow answer http://stackoverflow.com/a/14607651

GH_HOME=$(dirname "$0")
JAVA=$JAVA_HOME/bin/java
if [ "$JAVA_HOME" = "" ]; then
 JAVA=java
fi

vers=$($JAVA -version 2>&1 | grep "version" | awk '{print $3}' | tr -d \")
bit64=$($JAVA -version 2>&1 | grep "64-Bit")
if [ "$bit64" != "" ]; then
  vers="$vers (64bit)"
fi
echo "## using java $vers from $JAVA_HOME"

function printBashUsage {
  echo "$(basename $0): Start a Gpahhopper server."
  echo "user access at 0.0.0.0:8989 and API access at 0.0.0.0:8989/route"
  echo ""
  echo "Usage"
  echo "$(basename $0) -i | --input <file> [<parameter> ...] "
  echo "$(basename $0) --url <url> [<parameter> ...] "
  echo ""
  echo "parameters:"
  echo "--import                  only create the graph cache, to be used later for faster starts"
  echo "-c | --config <config>    specify the application configuration"
  echo "-i | --input <file>       path to the input file in the file system"
  echo "--url <url>               download input file from a url and save as data.pbf"
  echo "-o | --graph-cache <dir>  directory for graph cache output"
  echo "-p | --profiles <string>  comma separated list of vehicle profiles"
  echo "--port <port>             start web server at the given port rather than 8989"
  echo "--host <host>             specify to which host the service should be bound rather than 0.0.0.0"
  echo "-h | --help               display this message"
}

# one character parameters have one minus character'-'. longer parameters have two minus characters '--'
while [ ! -z $1 ]; do
  case $1 in
    --import) ACTION=import; shift 1;;
    -c|--config) CONFIG="$2"; shift 2;;
    -i|--input) FILE="$2"; shift 2;;
    --url) URL="$2"; shift 2;;
    -o|--graph-cache) GRAPH="$2"; shift 2;;
    -p|--profiles) GH_WEB_OPTS="$GH_WEB_OPTS -Ddw.graphhopper.graph.flag_encoders=$2"; shift 2;;
    --port) GH_WEB_OPTS="$GH_WEB_OPTS -Ddw.server.application_connectors[0].port=$2"; shift 2;;
    --host) GH_WEB_OPTS="$GH_WEB_OPTS -Ddw.server.application_connectors[0].bind_host=$2"; shift 2;;
    -h|--help) printBashUsage
        exit 0;;
    -*) echo "Option unknown: $1"
        echo
        printBashUsage
        exit 2;;
  esac
done

: "${ACTION:=server}"

if [[ "$CONFIG" == *properties ]]; then
 echo "$CONFIG not allowed as configuration. Use yml"
 exit
fi

# default init, https://stackoverflow.com/a/28085062/194609
: "${CONFIG:=config.yml}"
if [[ -f $CONFIG && $CONFIG != config.yml ]]; then
  echo "Copying non-default config file: $CONFIG"
  cp $CONFIG config.yml
fi
if [ ! -f "config.yml" ]; then
  echo "No config file was specified, using config-example.yml"
  cp config-example.yml $CONFIG
fi

if [ "$URL" != "" ]; then
  wget -S -nv -O "data.pbf" "$URL"
  FILE="data.pbf"
fi

if [ "$FILE" = "" ]; then
  echo -e "No file or url were specified."
  printBashUsage
  exit 2
fi

# DATA_DIR = directories path to the file if any (if current directory, return .)
DATADIR=$(dirname "${FILE}")
# create the directories if needed
mkdir -p $DATADIR
# BASENAME = filename (file without the directories)
BASENAME=$(basename "${FILE}")
# NAME = file without extension if any
NAME="${BASENAME%.*}"

: "${JAVA_OPTS:=-Xmx1g -Xms1g}"
: "${JAR:=$(find . -type f -name "*.jar")}"
: "${GRAPH:=$DATADIR/$NAME-gh}"

echo "## Executing $ACTION. JAVA_OPTS=$JAVA_OPTS"

exec "$JAVA" $JAVA_OPTS -Ddw.graphhopper.datareader.file="$FILE" -Ddw.graphhopper.graph.location="$GRAPH" \
        $GH_WEB_OPTS -jar "$JAR" $ACTION $CONFIG
