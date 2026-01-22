CC_ARGS := -fno-pic -fno-builtin -ffreestanding -fno-stack-protector -std=gnu99 -m32 -march=i386 -nostdlib -O0 -Iinclude/
BOCHSRC := bochsrc.txt
BOOT_OBJDUMP_ARGS := -Maddr16,data16 -m i386 
BUILD_DIR := build
CC := x86_64-elf-gcc
LD := x86_64-elf-ld

default: $(BUILD_DIR) $(BUILD_DIR)/test.dd

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/stage1.bin: stage1.s
	rm -f $@
	nasm -fbin $^ -o $@

STAGE2_SRCS := $(wildcard *.c) $(wildcard video/*.c)
STAGE2_ELFS := $(addprefix $(BUILD_DIR)/, $(notdir $(STAGE2_SRCS:.c=.elf)))

$(BUILD_DIR)/%.elf: %.c | $(BUILD_DIR)
	$(CC) $(CC_ARGS) -c $< -o $@

$(BUILD_DIR)/%.elf: video/%.c | $(BUILD_DIR)
	$(CC) $(CC_ARGS) -c $< -o $@

$(BUILD_DIR)/stage2_entry.elf: stage2.s
	nasm -felf $^ -o $@

$(BUILD_DIR)/int.elf: int.s
	nasm -felf $^ -o $@

$(BUILD_DIR)/stage2.bin: $(STAGE2_ELFS) $(BUILD_DIR)/stage2_entry.elf $(BUILD_DIR)/int.elf
	$(LD) -m elf_i386 -T stage2.ld -Map $(BUILD_DIR)/stage2.map -o $@ $^

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin 
	cat $^ > $@

$(BUILD_DIR)/test.dd: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin
	# dd if=/dev/zero of=$@ bs=1M count=16
	# parted $@ --script mklabel msdos
	# parted $@ --script mkpart primary 1MiB 5MiB
	# parted $@ --script mkpart primary 5MiB 100%
	# dd if=$(BUILD_DIR)/stage1.bin of=$@ bs=1 count=440 conv=notrunc
	# printf '\x55\xAA' | dd of=$@ bs=1 seek=510 count=2 conv=notrunc
	# dd if=$(BUILD_DIR)/stage2.bin of=$@ bs=1 seek=512 conv=notrunc
	dd if=/dev/zero of=$@ bs=1m count=16
	printf '\x00%.0s' | dd of=$@ bs=1 seek=446 count=64 conv=notrunc status=none
	# mbr linux partitions
	printf '00feffff83feffff0008000000200000' | xxd -r -p | dd of=$@ bs=1 seek=446 conv=notrunc status=none
	printf '00feffff83feffff00200000d8000000' | xxd -r -p | dd of=$@ bs=1 seek=462 conv=notrunc status=none
	# signature
	printf '\x55\xAA' | dd of=$@ bs=1 seek=510 count=2 conv=notrunc status=none
	dd if=$(BUILD_DIR)/stage1.bin of=$@ bs=1 count=440 conv=notrunc status=none
	dd if=$(BUILD_DIR)/stage2.bin of=$@ bs=1 seek=512 conv=notrunc status=none

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

decompile-32: $(BUILD_DIR)/test.dd
	objdump -D -b binary -m i386 -Maddr32,data32 $^

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
