kernel_sources 		 := $(shell find src/kernel -name *.c)
kernel_objects 		 := $(patsubst src/kernel/%.c, build/kernel/%.o, $(kernel_sources))

x86_64_c_sources 	 := $(shell find src/x86_64 -name *.c)
x86_64_c_objects 	 := $(patsubst src/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_sources))

x86_64_asm_sources := $(shell find src/x86_64/asm -name *.asm)
x86_64_asm_objects := $(patsubst src/x86_64/asm/%.asm, build/x86_64/asm/%.o, $(x86_64_asm_sources))

x86_64_objects 		 := $(kernel_objects) $(x86_64_c_objects) $(x86_64_asm_objects)

$(kernel_objects): build/kernel/%.o : src/kernel/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/interfaces -ffreestanding $(patsubst build/kernel/%.o, src/kernel/%.c, $@) -o $@

$(x86_64_c_objects): build/x86_64/%.o : src/x86_64/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/interfaces -ffreestanding $(patsubst build/x86_64/%.o, src/x86_64/%.c, $@) -o $@

$(x86_64_asm_objects): build/x86_64/asm/%.o : src/x86_64/asm/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/asm/%.o, src/x86_64/asm/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(x86_64_objects)
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_objects) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso
