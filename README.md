# OSK #

*Operating System Kernel*

# Docker #

### Build Image ###

`./osk.sh -b` or:
  - `docker build ./ -t osk`

### Run Container ###

`./osk.sh -r` or:
  - `docker run --rm -it -v "%cd%":/root/env osk` on *Windows*
  - `docker run --rm -it -v "$pwd":/root/env osk` on *Linux* or *MacOS*

### Kill Container ###

`./osk.sh -k` or:
  - `docker container kill osk`
