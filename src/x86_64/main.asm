global start

section .text
bits 32

start:
  mov esp, top                    ; Store stack top address into ESP register

  call check_multiboot            ; Subroutine to confirm successful multiboot2 load
  call check_cpu_id               ; Subroutine to check if CPU ID is supported
  call check_long_mode            ; Subroutine to check if the "Long Mode" is supported

  mov dword [0xb8000], 0x2f4b2f4f ; Write & print "OK" in video memory
  hlt                             ; Freeze the CPU

check_multiboot:                  ; Check if the "Magic Number" is stored in the EAX register when boot is complete
  cmp eax, 0x36d76289             ; Compare the value in the EAX register with the "Magic Number"
  jne .no_multiboot               ; Jump-not-equal: jump to "no_multiboot" label if the previous check fails
  ret                             ; Return from the subroutine

.no_multiboot:
  mov al, "M"                     ; Set error code into AL register for "No Multiboot" error message
  jmp error                       ; Jump to "error" subroutine to display "No Multiboot" error message

check_cpu_id:                     ; Attempt to flip the ID bit of the flags register to check if the CPU ID is available
  pushfd                          ; Copy the flags into the EAX register by pushing the flags register onto the stack
  pop eax                         ; Popping off the stack into the EAX register
  mov ecx, eax                    ; Make a copy in the ECX register to compare if the bits are successfully flipped
  xor eax, 1 << 21                ; Perform a XOR operation to flip ID bit (21) on the EAX register
  push eax                        ; Copy back to the flags register by pushing onto the stack...
  popfd                           ; ...and popping into the flags register

  pushfd                          ; Copy the flags back into the EAX register by pushing the flags register onto the stack
  pop eax                         ; Popping off the stack into the EAX register
  push ecx                        ; Transfer the value at ECX back into the flags register...
  popfd                           ; ...so the flags remain as whatever they were before the "check_cpu_id" call

  cmp eax, ecx                    ; Compare values in EAX and ECX registers
  je .no_cpu_id                   ; If they match, the CPU did not allow to flip the ID bit, so the CPU ID is not available
  ret                             ; Return from the subroutine

.no_cpu_id:
  mov al, "C"                     ; Set error code into AL register for "No CPU ID" error message
  jmp error                       ; Jump to "error" subroutine to display "No CPU ID" error message

check_long_mode:                  ; Check if CPU ID supports extended processor info
  mov eax, 0x80000000             ; Move "Magic Number" into the EAX register
  cpuid                           ; Run CPU ID instruction (takes EAX register as an implicit argument)
  cmp eax, 0x80000001             ; Compare if the value stored back in the EAX register is greater than the initial "Magic Number"
  jb .no_long_mode                ; Jump to "no_long_mode" label if the previous check fails

  mov eax, 0x80000001             ; Set a different value into the EAX register to check if "Long Mode" is supported
  cpuid                           ; Run CPU ID instruction (store a value into the EDX register)
  test edx, 1 << 29               ; Test if the LM bit (29) is set so the "Long Mode" is available
  jz .no_long_mode                ; Jump to "no_long_mode" label if the previous check fails
  ret                             ; Otherwise, return successfully from the subroutine

.no_long_mode:
  mov al, "L"                     ; Set error code into AL register for "No Long Mode" error message
  jmp error                       ; Jump to "error" subroutine to display "No Long Mode" error message

error:                            ; Print "ERR: <ERROR_CODE>" in video memory
  mov dword [0xb8000], 0x4f524f45 ; Print 4 bytes in video memory
  mov dword [0xb8004], 0x4f3a4f52 ; Print 4 bytes in video memory
  mov dword [0xb8008], 0x4f204f20 ; Print 4 bytes in video memory
  mov byte  [0xb800a], al         ; Print 1 byte for the <ERROR_CODE> (ASCII letter in the AL register)
  hlt                             ; Freeze the CPU with the error message on screen

section .bss                      ; BSS section contains statically allocated variables

bottom:                           ; Stack top
  resb 4096 * 4                   ; Reserve 16KB of memory
top:                              ; Stack bottom
