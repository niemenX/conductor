#!/bin/sh
# startup.sh - startup script for the server docker image

echo "Starting Conductor server"

# Start the server
cd /app/libs
echo "Property file: $CONFIG_PROP"

if [ -n "$CONFIG_DB" ];
  then
    echo "Replace DB=$CONFIG_DB";
    sed -i "s/^\(db\s*=\s*\).*$/\1$CONFIG_DB/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT DB";
fi
if [ -n "$CONFIG_HOSTS" ];
  then
    sed -i "s/^\(workflow\.dynomite\.cluster\.hosts\s*=\s*\).*$/\1$CONFIG_HOSTS/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT HOSTS";
fi
if [ -n "$CONFIG_CLUSTER_NAME" ];
  then
    sed -i "s/^\(workflow\.dynomite\.cluster\.name\s*=\s*\).*$/\1$CONFIG_CLUSTER_NAME/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT CLUSTER NAME";
fi
if [ -n "$CONFIG_NAMESPACE_PREFIX" ];
  then
    sed -i "s/^\(workflow\.namespace\.prefix\s*=\s*\).*$/\1$CONFIG_NAMESPACE_PREFIX/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NAMESPACE PREFIX";
fi
if [ -n "$CONFIG_ELASTICSEARCH_URL" ];
  then
    sed -i "s/^\(workflow\.elasticsearch\.url\s*=\s*\).*$/\1$CONFIG_ELASTICSEARCH_URL/" /app/config/$CONFIG_PROP
  else
    sed -i "/workflow\.elasticsearch\.url\=.*/d" /app/config/$CONFIG_PROP
fi
if [ -n "$CONFIG_ELASTICSEARCH_INDEX" ];
  then
    sed -i "s/^\(workflow\.elasticsearch\.index\.name\s*=\s*\).*$/\1$CONFIG_ELASTICSEARCH_INDEX/" /app/config/$CONFIG_PROP
  else
    sed -i "/workflow\.elasticsearch\.index\.name\=.*/d" /app/config/$CONFIG_PROP
fi
if [ -n "$CONFIG_LOAD_SAMPLE" ];
  then
    sed -i "s/^\(loadSample\s*=\s*\).*$/\1$CONFIG_LOAD_SAMPLE/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT LOAD SAMPLE";
fi

if [ -n "$CONFIG_NATS_URL" ];
  then
    sed -i "s,^\(io\.nats\.streaming\.url\s*=\s*\).*$,\1$CONFIG_NATS_URL," /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NATS URL";
fi

if [ -n "$CONFIG_NATS_CLUSTER" ];
  then
    sed -i "s/^\(io\.nats\.streaming\.cluster\s*=\s*\).*$/\1$CONFIG_NATS_CLUSTER/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NATS CLUSTER";
fi


if [ -n "$CONFIG_NATS_CLIENTID" ];
  then
    sed -i "s/^\(io\.nats\.streaming\.clientId\s*=\s*\).*$/\1$CONFIG_NATS_CLIENTID/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NATS CLIENTID";
fi


if [ -n "$CONFIG_NATS_QGROUP" ];
  then
    sed -i "s/^\(io\.nats\.streaming\.qGroup\s*=\s*\).*$/\1$CONFIG_NATS_QGROUP/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NATS QGROUP";
fi


if [ -n "$CONFIG_NATS_DURABLENAME" ];
  then
    sed -i "s/^\(io\.nats\.streaming\.durableName\s*=\s*\).*$/\1$CONFIG_NATS_DURABLENAME/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT NATS DURABLENAME";
fi

if [ -n "$CONFIG_ADDITIONAL_MODULES" ];
  then
    sed -i "s/^\(conductor\.additional\.modules\s*=\s*\).*$/\1$CONFIG_ADDITIONAL_MODULES/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT ADDITIONAL MODULES";
fi

if [ -n "$CONFIG_ES_VERSION" ];
  then
   sed -i "s/^\(workflow\.elasticsearch\.version\s*=\s*\).*$/\1$CONFIG_ES_VERSION/" /app/config/$CONFIG_PROP
  else
    echo "DEFAULT ES VERSION(2)";
fi

export config_file=

if [ -z "$CONFIG_PROP" ];
  then
    echo "Using an in-memory instance of conductor";
    export config_file=/app/config/config-local.properties
  else
    echo "Using '$CONFIG_PROP'";
    export config_file=/app/config/$CONFIG_PROP
fi

cat $config_file

java -jar conductor-server-*-all.jar $config_file