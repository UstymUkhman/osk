@echo off
title Launch osk

qemu-system-x86_64 -L c:\\PROGRA~1\\qemu -cdrom .\\dist\\x86_64\\kernel.iso
