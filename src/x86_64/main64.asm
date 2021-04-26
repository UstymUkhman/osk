global long_mode_start

section .text
bits 64

long_mode_start:                  ; Load 0 into the data segment registers
  mov ax, 0
  mov ss, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov dword [0xb8000], 0x2f4b2f4f ; Write & print "OK" in video memory
  hlt                             ; Freeze the CPU
