    .text
    .code16
    .att_syntax noprefix

    .global _start
_start:
    call main

    .global diskread
    .type   diskread, @function
diskread:
    push %ax
    push %cx
    push %dx
    push %si

    mov $5, %cx
diskread.attempt:
    cmp $0, %cx
    je diskread.done
    mov $0x42, %ah
    lea dapack, %si
    mov $.drive, %dl
    int $0x13
    jc diskread.failed
    jmp diskread.done
diskread.failed:
    dec %cx
    push $str_err_diskread
    call print
    add $2, %sp
diskread.done:
    pop %ax
    pop %cx
    pop %dx
    pop %si
    mov %bp, %sp
    pop %bp
    ret

    .global print
    .type   print, @function
print:
    push %bp
    mov %sp, %bp
    push %ax
    push %si

    mov $0x0e, %ah
    mov 4(%bp), %si
print.next:
    lodsb
    test %al, %al
    je print.done
    int $0x10
    jmp print.next
print.done:
    pop %ax
    pop %si
    mov %bp, %sp
    pop %bp
    ret

    .global hexprint
    .type   hexprint, @function
hexprint:
    push %bp
    mov %sp, %bp
    push %ax
    push %bx
    push %cx
    push %di

    mov 4(%bp), %bx
    mov $hexprint_buffer, %di
    mov $4, %cl
hexprint.next:
    rolw $4, %bx
    mov %bl, %al
    and $0x0F, %al
    cmp $10, %al
    jl hexprint.number
    add $'A' - 10, %al
    jmp hexprint.done
hexprint.number:
    add $'0', %al
hexprint.done:
    stosb
    dec %cl
    jnz hexprint.next
    mov $0, %al
    stosb
    
    push $hexprint_buffer
    call print
    add $2, %sp

    push $hexprint_buffer
    call print
    add $2, %sp

    pop %ax
    pop %bx
    pop %cx
    pop %dx
    mov %bp, %sp
    pop %bp
    ret

    .global main
    .type   main, @function
main:
    cli
    ljmp $0x0000, $.initcs
.initcs:
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7c00, %sp
    mov %sp, %bp
    sti

    push $str_hello
    call print
    add $2, %sp

    mov $0x41, %ah
    mov $0x55aa, %bx
    mov $.drive, %dl
    int $0x13
    jc end

load_stage2:
    mov $0x66, %ax
    mov $_stage2_size, %eax
    mov $512, %ecx
    xor %edx, %edx
    div %ecx                # quotient -> eax, remainder -> edx
    mov %eax, .sectors
    test %edx, %edx
    je load_stage2.exact
    incw .sectors
load_stage2.exact:
    movw $1, .lba
    movw $0x7e00, .transfer
    call diskread
load_stage2.done: 
    mov $0x7e00, %bx
    jmp *%bx

end:
    push $str_err_no41
    call print
    add $2, %sp

    hlt
    ret

    .extern _stage2_size

    .global .drive
    .set .drive,       0x80
    .set .sector_size, 512

    .align 16
hexprint_buffer:       .space 5

    .global dapack
    .global .sectors
    .global .transfer
    .global .lba
    .align 16
dapack:
    .byte 0x10
    .byte 0
.sectors:
    .short 1
.transfer:
    .word 0x7e00
    .word 0
.lba:
    .long 1
    .long 0

str_hello:             .asciz "casinoboot stage1\n\r"
str_err_no41:          .asciz "INT13h extensions not supported\n\r"
str_err_diskread:      .asciz "disk read failed (might retry)\n\r"
    .global str_newline
str_newline:           .asciz "\n\r"

.fill 510 - (. - _start), 1, 0
.word 0xaa55