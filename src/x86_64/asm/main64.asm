global long_mode_start
extern main

section .text
bits 64

long_mode_start: ; Load 0 into the data segment registers
  mov ax, 0
  mov ss, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  call main      ; Call main function in src/kernel/main.c
  hlt            ; Freeze the CPU
