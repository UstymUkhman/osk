x86_64_sources  := $(shell find src/x86_64 -name *.asm)
x86_64_objects  := $(patsubst src/x86_64/%.asm, build/x86_64/%.o, $(x86_64_sources))
x86_64_assembly := $(patsubst build/x86_64/%.o, src/x86_64/%.asm, $@)

$(x86_64_objects): build/x86_64/%.o : src/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(x86_64_assembly) -o $@
	# nasm -f elf64 $(patsubst build/x86_64/%.o, src/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(x86_64_objects)
  mkdir -p dist/x86_64 && \
  x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_objects) && \
  cp dist/x86_64/kernel.bin targets/x86_64/iso/kernel.bin && \
  grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso
