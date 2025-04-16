    .text
    .code16
    
    jmp start
.hlt: hlt
jmp .hlt

start:
    lea msg_hello, %si
    call print

    cmpb $0x80, %dl
    jge .dl80
.dl80:
    movb %dl, .drive
    movb $.drive, %dl

    lea msg_hdd, %si
    call print

    cli
    cld
    ljmp $0x0000, $.initcs
.initcs:
    xorw %si, %si
    movw %si, %di
    movw %si, %es
    movw %si, %ss
    movw $.stage1_load_addr, %sp
    movw %sp, %bp

    sti

.macro macro_a20_check
    mov $0x112345, %edi
    mov $0x012345, %esi
    mov (%esi), %esi
    mov (%edi), %edi
    cmpsl
.endm

a20:
    macro_a20_check
    jne a20.set         # a20 is unset, do it ourselves
    jmp a20.finish      # a20 already set
a20.set:
    inb $0x92, %al
    testb $02, %al
    jnz a20.no92
    orb $2, %al
    andb $0xfe, %al
    outb %al, $0x92
    jmp a20.finish
a20.no92:
    movw $0x2401, %ax
    int $0x15
a20.recheck:
    macro_a20_check
    je a20.finish
    lea msg_a20, %si
a20.failed:
    lea msg_a20_fail, %si
a20.finish:
    call print

stage2:
    movb $0x41, %ah
    movw $0x55aa, %bx
    int $0x13
    jc stage2.no41
    call diskread
    jmp stage2.load
stage2.no41:
    lea err_no41, %si
    call print
stage2.load:
    cli
    cld
stage2.gdt:
    movw 4(%esp), %ax
    movw %ax, gdt
    movl 8(%esp), %eax
    movl %eax, gdt+2
    lgdt gdt

    .noreturn: hlt
        jmp .noreturn

    .data
    .extern _sboot
    .extern _sboot2a
    .extern .drive

.set .stage1_load_addr,     _sboot
.set .stage2_load_addr,     _sboot2

    .global gdt
gdt:
    .quad 0
    .quad 0x00cf9a000000ffff
    .quad 0x00cf92000000ffff

msg_hello:    .asciz "casinoboot: gambling with your hardrive\n\r"
msg_hdd:      .asciz "booting from hard drive %dl > 80\n\r"
msg_a20:      .asciz "a20 success\n\r"
msg_a20_fail: .asciz "a20 error. proceeding anyway\n\r"
msg_e820:     .asciz "e820 memory map loaded\n\r"
err_no41:     .asciz "stage2 no 41\n\r"
