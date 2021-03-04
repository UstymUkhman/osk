section .multiboot

start:
  dd 0xe85250d6                                     ; Multiboot 2
  dd 0                                              ; i386 protected mode
  dd end - start                                    ; Header length
  dd 0x100000000 - (0xe85250d6 + 0 + (end - start)) ; Checksum

  dw 0                                              ; End tag
  dw 0                                              ; End tag
  dd 8                                              ; End tag
end:
