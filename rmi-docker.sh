#!/bin/bash

# Linux: tac
# Darwin: tail -r
function reverse {
  perl -e 'print reverse <>' ${@+"$@"}
}

docker images | grep fabric |
while read image tag id; do
  echo $image:$tag
done | reverse | xargs docker rmi
