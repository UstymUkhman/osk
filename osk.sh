#!/bin/bash

usage () {
  echo $'\n'"Usage: $0 [-b] [-r] [-k]";
  exit 1;
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -b|--build)
      docker build ./ -t osk;
      break
      ;;

    -r|--run)
      docker run --rm -it -d --name osk -v $(pwd):/root/env osk;
      docker exec -it osk bash;
      break
      ;;

    -k|--kill)
      docker container kill osk;
      break
      ;;

    *)
      usage;
      exit 1
      ;;
  esac
done
