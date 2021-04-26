section .multiboot

start:
  dd 0xe85250d6                                     ; Add data of multiboot2 "Magic Number"
  dd 0                                              ; Specify architecture of i386 protected mode
  dd end - start                                    ; Add calculated header length
  dd 0x100000000 - (0xe85250d6 + 0 + (end - start)) ; Add checksum

  dw 0                                              ; Set end tag
  dw 0                                              ; Set end tag
  dd 8                                              ; Set end tag
end:
