#!/bin/bash

DEST=/var/geonode/geonode
OVERRIDES=/var/geonode-overrides
CATALINA_SH=/var/lib/tomcat8/bin/catalina.sh

service apache2 start
$CATALINA_SH start

if [ -d "$OVERRIDES" ]; then
  $CATALINA_SH start
  while true; do
    inotifywait -mr "$OVERRIDES" | while read line; do
      rsync -a "$OVERRIDES" "$DEST"
    done
  done
else
  $CATALINA_SH run
fi

