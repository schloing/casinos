; %include "bs_gdt.s"
; start 32 bit protected mode

[bits 16]

switch_pm:
    mov bx, LOAD_GDT    ; load gdt message
    call print

    mov ax, 0x2401      ; activate a20 line using bios
    int 0x15

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
  
    jmp CODE_SEG:start_pm

[bits 32]

start_pm:
    mov ax, DATA_SEG

    jmp CODE_SEG:.reload_cs

.reload_cs:
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM

LOAD_GDT: db "loading the GDT", 0
