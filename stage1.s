    bits 16
    section .text
    org 0x7c00

_start:
    call main

bootdrive      equ 0x80
memmap_amt_ent equ 0x8000
memmap_addr    equ 0x8004
stage2_addr    equ 0xf000

diskread:
    mov cx, 5                   ; retry counter
.attempt:
    cmp cx, 0
    je .done
    mov ah, 0x42                ; extended read
    mov dl, bootdrive
    lea si, [dapack]
    int 0x13
    jc .failed
    jmp .done
.failed:
    dec cx
    jmp .attempt
.done:
    ret

memory_map_e820:
    mov di, memmap_addr
    xor ebx, ebx
    xor bp, bp
    mov edx, 0x0534d4150
    mov eax, 0xe820
    mov [es:di + 20], dword 1
    mov ecx, 24
    int 0x15
    jc .failed
    test ebx, ebx
    je .failed
.loop:
    mov eax, 0xe820
    mov edx, 0x0534D4150
    mov [es:di + 20], dword 1
    mov ecx, 24
    int 0x15
    jc .failed
    cmp cl, 20
    jb .notext
    test byte [es:di + 20], 1
    je .skipent
.notext:
    mov ecx, [es:di + 8]
    or ecx, [es:di + 12]
    jz .skipent
    inc bp
    add di, 24
.skipent:
    test ebx, ebx
    jne .loop
.done:
    mov [es:memmap_amt_ent], bp
    clc
    ret
.failed:
    stc
    ret

main:                           ; noreturn
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
   
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xffff
    sti

    cmp dl, bootdrive
    mov [bootdrive], dl
    je hdd_boot
    jmp $                       ; no floppies allowed

hdd_boot:
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, bootdrive
    int 0x13
    cmp bx, 0xaa55
    je .hdd_confirmed
    jmp $                       ; no edd
.hdd_confirmed:

load_stage2:
    call memory_map_e820

    mov word [dapack.sectors], 10
    mov word [dapack.lba], 1
    mov word [dapack.segment], 0
    mov word [dapack.offset], stage2_addr
    call diskread               ; stage 2 -> 0xf000

load_gdt:
    cli
    lgdt [gdt]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    jmp 0x18:.setcs

    bits 32
.setcs:
    call stage2_addr
    jmp $

    section .data

    ; global descriptor table
    align 16
gdt:
    dw .end - .start - 1
    dd .start

.start:
    dq 0x0000000000000000

.code16:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x9a         ; rx
    db 0x00
    db 0x00

.data16:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x92         ; rw
    db 0x00
    db 0x00

.code32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x9a         ; rx
    db 0xcf
    db 0x00

.data32:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x92         ; rw
    db 0xcf
    db 0x00

.end:

    ; disk address packet
    align 16
dapack:
    db 0x10
    db 0x00
.sectors:
    dw 1
.offset:
    dw 0x7e00
.segment:
    dw 0
.lba:
    dd 1, 0

times 510-($-$$) db 0
dw 0xaa55
