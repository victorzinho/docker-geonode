#!/bin/bash

DEST=/var/geonode/geonode
OVERWRITES=/var/geonode-overwrites
CATALINA_SH=/var/lib/tomcat8/bin/catalina.sh

service apache2 start

function update {
  rsync -rlpt "$OVERWRITES"/* "$DEST/"
  chown -R www-data: $DEST
}

if [ -d "$OVERWRITES" ]; then
  $CATALINA_SH start
  update
  while true; do
    inotifywait -mr "$OVERWRITES" | while read line; do
      update
    done
  done
else
  $CATALINA_SH run
fi

