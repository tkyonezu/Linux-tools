#!/bin/bash

echo -n ">>> Remove all Docker images ? (y/n) "
read ans
if [ "$ans" = "y" ]; then
  docker images | sed 1d |
  while read img tag dmy; do
    echo "$ docker rmi $img:$tag"
    docker rmi $img:$tag
  done
fi

exit 0
