#!/bin/bash

usage () {
  echo $'\n'"Usage: $0 [-b] [-r] [-l] [-k]";
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

    -l|--launch)
      qemu-system-x86_64 -L /usr/share/qemu/ -cdrom dist/x86_64/kernel.iso;
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
