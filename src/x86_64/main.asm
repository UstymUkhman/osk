global start
extern long_mode_start

section .text
bits 32

start:
  mov esp, top                                     ; Store stack top address into ESP register

  call check_multiboot                             ; Subroutine to confirm successful multiboot2 load
  call check_cpu_id                                ; Subroutine to check if CPU ID is supported
  call check_long_mode                             ; Subroutine to check if the "Long Mode" is supported

  call setup_tables                                ; Subroutine to setup virtual memory of 4KB per page
  call enable_paging                               ; Subroutine to map virtual memory to physical memory

  lgdt [gdt64.pointer]                             ; Load the global descriptor table
  jmp gdt64.code_segment:long_mode_start           ; Load the code segment into the code selector and jump to x64 assembly code

  hlt                                              ; Freeze the CPU

check_multiboot:                                   ; Check if the "Magic Number" is stored in the EAX register when boot is complete
  cmp eax, 0x36d76289                              ; Compare the value in the EAX register with the "Magic Number"
  jne .no_multiboot                                ; Jump-not-equal: jump to "no_multiboot" label if the previous check fails
  ret                                              ; Return from the subroutine

.no_multiboot:
  mov al, "M"                                      ; Set error code into AL register for "No Multiboot" error message
  jmp error                                        ; Jump to "error" subroutine to display "No Multiboot" error message

check_cpu_id:                                      ; Attempt to flip the ID bit of the flags register to check if the CPU ID is available
  pushfd                                           ; Copy the flags into the EAX register by pushing the flags register onto the stack
  pop eax                                          ; Popping off the stack into the EAX register
  mov ecx, eax                                     ; Make a copy in the ECX register to compare if the bits are successfully flipped
  xor eax, 1 << 21                                 ; Perform a XOR operation to flip ID bit (21) on the EAX register
  push eax                                         ; Copy back to the flags register by pushing onto the stack...
  popfd                                            ; ...and popping into the flags register

  pushfd                                           ; Copy the flags back into the EAX register by pushing the flags register onto the stack
  pop eax                                          ; Popping off the stack into the EAX register
  push ecx                                         ; Transfer the value at ECX back into the flags register...
  popfd                                            ; ...so the flags remain as whatever they were before the "check_cpu_id" call

  cmp eax, ecx                                     ; Compare values in EAX and ECX registers
  je .no_cpu_id                                    ; If they match, the CPU did not allow to flip the ID bit, so the CPU ID is not available
  ret                                              ; Return from the subroutine

.no_cpu_id:
  mov al, "C"                                      ; Set error code into AL register for "No CPU ID" error message
  jmp error                                        ; Jump to "error" subroutine to display "No CPU ID" error message

check_long_mode:                                   ; Check if CPU ID supports extended processor info
  mov eax, 0x80000000                              ; Move "Magic Number" into the EAX register
  cpuid                                            ; Run CPU ID instruction (takes EAX register as an implicit argument)
  cmp eax, 0x80000001                              ; Compare if the value stored back in the EAX register is greater than the initial "Magic Number"
  jb .no_long_mode                                 ; Jump to "no_long_mode" label if the previous check fails

  mov eax, 0x80000001                              ; Set a different value into the EAX register to check if "Long Mode" is supported
  cpuid                                            ; Run CPU ID instruction (store a value into the EDX register)
  test edx, 1 << 29                                ; Test if the LM bit (29) is set so the "Long Mode" is available
  jz .no_long_mode                                 ; Jump to "no_long_mode" label if the previous check fails
  ret                                              ; Otherwise, return successfully from the subroutine

.no_long_mode:
  mov al, "L"                                      ; Set error code into AL register for "No Long Mode" error message
  jmp error                                        ; Jump to "error" subroutine to display "No Long Mode" error message

setup_tables:                                      ; Map a physical address adress to the exact same virtual address (Identity mapping)
  mov eax, table_l3                                ; Move the address of the level 3 table to the EAX register
  or eax, 0b11                                     ; Enable the present and the writable flags at the first and second bit
  mov [table_l4], eax                              ; Move the address with flags to the first entry at the level 4 table
  
  mov eax, table_l2                                ; Move the address of the level 2 table to the EAX register
  or eax, 0b11                                     ; Enable the present and the writable flags at the first and second bit
  mov [table_l3], eax                              ; Move the address with flags to the first entry at the level 3 table

  mov ecx, 0                                       ; For-loop with the counter set at 0

.loop:                                             ; For-loop label to map 2MB per page
  mov eax, 0x200000                                ; Store 2MB in the EAX register
  mul ecx                                          ; Multiply the value in the EAX register by the counter to transfer to the next page
  or eax, 0b10000011                               ; Set the present, the writable and the huge page flags
  mov [table_l2 + ecx * 8], eax                    ; Put the entry in the level 2 table with offset of the counter * 8 bytes for every entry

  inc ecx                                          ; Increment counter on each iteration
  cmp ecx, 512                                     ; Check if the whole table is mapped
  jne .loop                                        ; If not, jump to a loop lable
  ret                                              ; Return from the subroutine

enable_paging:                                     ; Enable physical address extension (PAE) for the x64 bit paging
  mov eax, table_l4                                ; Move the address of the level table 4 to the EAX register
  mov cr3, eax                                     ; Copy the value to the CR3 register

  mov eax, cr4                                     ; Copy the CR4 register to the EAX register
  or eax, 1 << 5                                   ; Enable the fifth bit for the PAE flag
  mov cr4, eax                                     ; Save changes back in the CR4 register

  mov ecx, 0xC0000080                              ; Put the "Magic Value" into the ECX register
  rdmsr                                            ; Use read module specific register instruction
  or eax, 1 << 8                                   ; Enable the "Long Mode" flag at bit 8
  wrmsr                                            ; Write back to the module specific register (EFER)

  mov eax, cr0                                     ; Copy the CR0 register to the EAX register
  or eax, 1 << 31                                  ; Enable the paging flag by enabling the 31st bit
  mov cr0, eax                                     ; Save changes back in the CR0 register
  ret                                              ; Return from the subroutine

error:                                             ; Print "ERR: <ERROR_CODE>" in video memory
  mov dword [0xb8000], 0x4f524f45                  ; Print 4 bytes in video memory
  mov dword [0xb8004], 0x4f3a4f52                  ; Print 4 bytes in video memory
  mov dword [0xb8008], 0x4f204f20                  ; Print 4 bytes in video memory
  mov byte  [0xb800a], al                          ; Print 1 byte for the <ERROR_CODE> (ASCII letter in the AL register)
  hlt                                              ; Freeze the CPU with the error message on screen

section .bss                                       ; BSS section contains statically allocated variables
align 4096                                         ; Align all page tables to 4KB

table_l4                                           ; Create a root page table (level 4 page table)...
  resb 4096                                        ; ...and reserve 4KB for it.

table_l3                                           ; Create a level 3 page table...
  resb 4096                                        ; ...and reserve 4KB for it.

table_l2                                           ; Create a level 2 page table...
  resb 4096                                        ; ...and reserve 4KB for it.

bottom:                                            ; Stack top
  resb 4096 * 4                                    ; Reserve 16KB of memory
top:                                               ; Stack bottom

section .rodata                                    ; Create a read-only data section
gdt64:                                             ; Define x64 bit global descriptor table
  dq 0                                             ; Begin with a 0 entry

.code_segment: equ $ - gdt64                       ; Lable to get the offset of the code segment in the descriptor table
  dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; Enable the executable flag in the "Code Segment"
                                                   ; Set the descriptor type to 1
                                                   ; Enable the present flag
                                                   ; Enable the 64 bit flag

.pointer:                                          ; Create a pointer to the global descriptor table
  dw $ - gdt64 - 1                                 ; Set 2 bytes for the length of the table - 1
  dq gdt64                                         ; Store the pointer itself
