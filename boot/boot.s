[org 7c00h]
[bits 16]
[global start]

dapack:     ; lba packet
    db 10h  ; size
    db 0
sectors:
    dw 4    ; number of sectors to transfer
transfer:
    dw 0    ; transfer buffer offset
    dw 0    ; transfer buffer segment
lba:
    dd 0    ; lower 32-bits of 48-bit starting LBA
    dd 0    ; upper 16-bits of 48-bit starting LBA

drive db 0

start:
    cmp dl, 80h
    jne error

    mov [drive], dl

    mov ah, 42h
    mov bx, 55aah
    mov dl, 80h
    int 13h

    jc error

    mov bx, stage2
    mov [transfer], bx
    call read_disk

read_disk:
    mov si, dapack
    mov ah, 42h
    mov dl, [drive]
    int 13h

    jc error

    ret

error: jmp $

times 510-($-$$) db 0
dw 0xaa55

block_size  db 0
inode_table dd 0

; stage1.5 like grub
stage2:
    mov ax, [superblock + 56] ; ext2 signature
    cmp ax, 0xef53            ; check if volume is ext2
    jne error

    mov ax, [superblock + 24] ; (logged) block size
    cmp ax, 0
    mov bx, 1024
    je block_size_1024        ; block size is 1024

    mov cl, al
    shl bx, cl                ; 1024 << ax gives block size
    jmp block_size_ukwn       ; block size is not 1024

block_size_1024:
    mov bx, 1024

block_size_ukwn:
    ; get inode table and a pointer to it
    mov ax, [superblock + bx + 8]
    mov [inode_table], ax

    mov [lba], ax
    mov ax, 2
    mov [sectors], ax
    
    mov ax, 1000h
    mov [transfer], ax

    call read_disk

    mov ax, 1280h             ; inode 5 is here
    mov cx, [1280h + 28]         ; count of disk sectors
    lea di, [1280h + 40]         ; direct block pointer 0

; iterate through block pointers in bootloader to get stage 2

begin_stage_two:
    mov ax, [di]              ; load block pointer 0
    shl ax, 1                 ; double it

    mov [lba], ax             ; block pointer 0
    mov bx, 5000h             ; destination address
    mov [transfer], bx        ; load inode at 5000h

    call read_disk

    add bx, 400h
	add di, 4h
	sub cx, 2h
	
    jnz begin_stage_two

enable_a20:
    mov ax, 2401h
    int 15h

%include "gdt.s"
load_gdt:
    cli
    xor ax, ax
    mov ds, ax
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 01h
    mov cr0, eax

[bits 32]
    jmp 08h:reload_cs
reload_cs:
    mov ax, 08h
    mov ds, ax
    mov ss, ax

    mov esp, 090000h
    mov eax, 5000h
    lea ebx, [eax]
    call ebx
    jmp $

times 1024-($-$$) db 0

superblock:
; link with stage 2