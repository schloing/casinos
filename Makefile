STAGE2_CC_ARGS := -fno-pic -fno-builtin -ffreestanding -std=gnu99 -m16 -march=i386 -nostdinc -nostdlib
BOOT_OBJDUMP_ARGS := -Maddr16,data16 -m i386 
QEMU_CPU_FEATS := base,fpu,sse,sse2,sse3,monitor,cx8,aes
# QEMU_FLAGS := -display curses 
BUILD_DIR := build

default: $(BUILD_DIR) $(BUILD_DIR)/diskimage.dd

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/stage1.o: stage1.s
	as --32 $^ -o $@

$(BUILD_DIR)/stage2_entry.o: stage2.s
	as --32 $^ -o $@

$(BUILD_DIR)/stage2.o: stage2.c
	gcc $(STAGE2_CC_ARGS) -c $^ -o $@

$(BUILD_DIR)/stage2.bin: $(BUILD_DIR)/stage2_entry.o $(BUILD_DIR)/stage2.o
	ld -m elf_i386 -T stage2.ld -o $@ $^

$(BUILD_DIR)/stage2.bin.gz: $(BUILD_DIR)/stage2.bin
	gzip -9 -c $^ > $@
	objcopy -I binary -O elf32-i386 -B i386 $@ $(BUILD_DIR)/stage2.bin.o

$(BUILD_DIR)/decompress.o: decompress.c
	gcc $(STAGE2_CC_ARGS) -c $^ -o $(BUILD_DIR)/decompress_unlinked.elf 
	ld -m elf_i386 -T decompress.ld -o $@ $(BUILD_DIR)/decompress_unlinked.elf

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/decompress.o $(BUILD_DIR)/stage2.bin.gz $(BUILD_DIR)/stage1.o
	ld -m elf_i386 -T boot.ld -Map=boot.map -o $@

$(BUILD_DIR)/diskimage.dd: $(BUILD_DIR)/boot.bin
	dd if=/dev/zero of=$@ bs=1048576 count=16
	dd if=$^ of=$@ conv=notrunc bs=512 count=2

.PHONY: all clean run remote debug dump decompile

all: $(BUILD_DIR) $(BUILD_DIR)/diskimage.dd

run: $(BUILD_DIR)/diskimage.dd
	qemu-system-i386 $(QEMU_FLAGS) -hda $^ -cpu $(QEMU_CPU_FEATS)

remote: $(BUILD_DIR)/diskimage.dd
	qemu-system-i386 -s -S $(QEMU_FLAGS) -hda $^ -cpu $(QEMU_CPU_FEATS)

debug: $(BUILD_DIR)/diskimage.dd
	gdb -ex "target remote localhost:1234"

dump: $(BUILD_DIR)/diskimage.dd
	hexdump -C $^
	file $^
	ls -la $^

decompile: $(BUILD_DIR)/diskimage.dd
	objdump -D -b binary -m i386 -Maddr16,data16 $^

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
