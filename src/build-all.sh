#!/usr/bin/env bash
START_TIME=$(date +%s)
for f in *.Dockerfile; do 
    NAME=elysium-${f%%.*}
    declare -l NAME
    echo "Processing $f file: $NAME"
    docker buildx build --platform linux/amd64 -f $f .
;done
END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))
echo "Finished in $ELAPSED s"
wait