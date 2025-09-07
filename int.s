; Copyright (c) 2020-2025 Limine
; SPDX-License-Identifier: BSD-2-Clause
; stub to switch to real mode, issue a bios interrupt, return back to protected mode
; void rm_int(int int_no, struct rm_regs* in_regs, struct rm_regs* out_regs)

    section .real
    global rm_int
rm_int:
    mov al, byte [esp + 4]
    mov byte [.int_no], al

    mov eax, dword [esp + 8]
    mov dword [.in_regs], eax

    mov eax, dword [esp + 12]
    mov dword [.out_regs], eax

    sgdt [.gdt]
    sidt [.idt]
    lidt [.rm_idt]

    push ebx                    ; non caller-saved gprs
    push esi
    push edi
    push ebp

    jmp 0x08:.bits16

    bits 16
.bits16:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov eax, cr0
    and al, 0xfe                ; disable PE bit
    mov cr0, eax

    jmp 0x00:.setcs

.setcs:
    xor ax, ax
    mov ss, ax

    mov dword [ss:.esp], esp
    mov esp, dword [ss:.in_regs]
    pop gs
    pop fs
    pop es
    pop ds
    popfd
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, dword [ss:.esp]

    sti

    db 0xcd
.int_no:
    db 0

    cli

    mov dword [ss:.esp], esp
    mov esp, dword [ss:.out_regs]
    lea esp, [esp + 10*4]
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    pushfd
    push ds
    push es
    push fs
    push gs
    mov esp, dword [ss:.esp]

    o32 lgdt [ss:.gdt]
    o32 lidt [ss:.idt]

    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 0x18:.bits32

    bits 32
.bits32:
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    pop ebp
    pop edi
    pop esi
    pop ebx

    ret

    align 16
.esp:       dd 0
.out_regs:  dd 0                ; ptr
.in_regs:   dd 0                ; ptr
.gdt:       dq 0
.idt:       dq 0
.rm_idt:    dw 0x3ff
            dd 0
