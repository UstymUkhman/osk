#!/bin/bash

usage () {
  echo $'\n'"Usage: $0 [-b] [-r]";
  exit 1;
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -r|--run)
      echo $(docker run --rm -it -v $(pwd):/root/env osk)
      exit 0
      ;;

    -b|--build)
      echo $(docker build ./ -t osk)
      break
      ;;

    *)
      usage
      exit 1
      ;;
  esac
done
