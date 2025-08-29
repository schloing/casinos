# casinoboot

## memory structure
0x7c00: bootloader load address
0x7e00: vbe info structure
0x8000: bios memmap # entries  
0x8004: bios memmap  
0x9000: 16-bit stack pointer  
0x10000: stage2 load address  
0x90000: 32-bit stack pointer  
0xffffffff80000000: minimum executable load address  

## creating mbr disk image
```bash
dd if=/dev/zero of=test.dd bs=1M count=16
parted test.dd --script mklabel msdos
parted test.dd --script mkpart primary 1MiB 5MiB
parted test.dd --script mkpart primary 5MiB 100%
fdisk -l test.dd
```

## todo
- [ ] properly parse mbr partition table
- [ ] locate kernel on disk
- [ ] parse ELF, VADDR
- [ ] search and respond to limine requests
- [ ] uefi, gpt support
- [ ] boot menu customization, config file parsing, editing, previewing

## read
- [limine boot protocol](https://github.com/limine-bootloader/limine-protocol/blob/trunk/PROTOCOL.md)
- [minimal limine compatible kernel](https://github.com/limine-bootloader/limine-c-template-x86-64/blob/trunk/kernel/src/main.c)
- https://wiki.osdev.org/MBR_(x86)
