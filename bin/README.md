## third-party bin

### [tinf (tiny inflate library)](https://github.com/jibsen/tinf)
- author: Joergen Ibsen
- binary: crc32.o, tinfgzip.o, tinflate.o
- compiled for casinos bootloader with `gcc -fno-pic -fno-builtin -ffreestanding -std=gnu99 -m16 -march=i386 -nostdinc -nostdlib -c [file] -o [output]`
