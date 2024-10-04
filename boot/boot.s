[org 7c00h]
[bits 16]

drive db 0

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
dw aa55h

stage2:
    mov ax, [superblock + 56] ; ext2 signature
    cmp ax, ef53h             ; check if volume is ext2
    jne error

    mov ax, [superblock + 24] ; (logged) block size
    cmp ax, 0
    je block_size_1024        ; block size is 1024

    mov bx, 1024              ; 1024 << ax gives block size
    shl bx, ax                ; get block size
    jmp block_size_ukwn

block_size_1024:
    mov bx, 2048              ; block 2

block_size_ukwn:
    mov ax, [superblock + bx + 8] ; get inode table
    mov [lba], ax             ; which lba to read
    mov bx, 1000h             ; load at 1000
    mov [transfer], bx
    mov [sectors], 2

    call read_disk



; TODO: more portable
enable_a20:
    mov ax, 2401h
    int 15h

#include "bs_gdt.s"
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
    mov b8000h 'H'
    jmp $

times 1024-($-$$) db 0

superblock:
; link with stage 2