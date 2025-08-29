CC_ARGS := -fno-pic -fno-builtin -ffreestanding -fno-stack-protector -std=gnu99 -m32 -march=i386 -nostdinc -nostdlib
BOCHSRC := bochsrc.txt
BOOT_OBJDUMP_ARGS := -Maddr16,data16 -m i386 
BUILD_DIR := build

default: $(BUILD_DIR) $(BUILD_DIR)/test.dd

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/stage1.bin: stage1.s
	rm -f $@
	nasm -fbin $^ -o $@

$(BUILD_DIR)/stage2.elf: stage2.c
	gcc $(CC_ARGS) -c $^ -o $@

$(BUILD_DIR)/stage2_entry.elf: stage2.s
	fasm $^ $@

$(BUILD_DIR)/stage2.bin: $(BUILD_DIR)/stage2.elf $(BUILD_DIR)/stage2_entry.elf
	ld -m elf_i386 -T stage2.ld -o $@ $^

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin 
	cat $^ > $@

$(BUILD_DIR)/test.dd: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin
	dd if=/dev/zero of=$@ bs=1M count=16
	parted $@ --script mklabel msdos
	parted $@ --script mkpart primary 1MiB 5MiB
	parted $@ --script mkpart primary 5MiB 100%
	dd if=$(BUILD_DIR)/stage1.bin of=$@ bs=1 count=440 conv=notrunc
	printf '\x55\xAA' | dd of=$@ bs=1 seek=510 count=2 conv=notrunc
	dd if=$(BUILD_DIR)/stage2.bin of=$@ bs=1 seek=512 conv=notrunc

.PHONY: all clean run remote debug dump decompile

all: $(BUILD_DIR) $(BUILD_DIR)/test.dd

run: $(BUILD_DIR)/test.dd
	bochs -q -f $(BOCHSRC) 'display_library: sdl2'

debug: $(BUILD_DIR)/test.dd
	bochs -q -f $(BOCHSRC) 'display_library: sdl2, options="gui_debug"'

dump: $(BUILD_DIR)/test.dd
	hexdump -C $^

decompile: $(BUILD_DIR)/test.dd
	objdump -D -b binary -m i386 -Maddr16,data16 $^

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
