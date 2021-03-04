@echo off
title Run osk

docker run --rm -it -d --name osk -v "%cd%":/root/env osk
docker exec -it osk bash
