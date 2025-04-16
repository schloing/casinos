    .text
    .code16

call _start

.global diskread
    .type   diskread, @function
diskread:
    pusha
    movb $0x42, %ah
    lea dapack, %si
    movb $.drive, %dl
    int $0x13
    jc diskread.failed
    jmp diskread.done
diskread.failed:
    lea str_err_diskread, %si
    call print
diskread.done:
    popa
    ret

    .global print
    .type   print, @function
print:
    pusha
    mov $0x0e, %ah
print.next:
    lodsb
    testb %al, %al
    je print.done
    int $0x10
    jmp print.next
print.done:
    popa
    ret

    .global hexprint
    .type   hexprint, @function
hexprint:
    pusha
    movw %ax, %bx
    movw $hexprint_buffer, %di
    movb $4, %cl
hexprint.next:
    rolw $4, %bx
    movb %bl, %al
    andb $0x0F, %al
    cmpb $10, %al
    jl hexprint.number
    addb $'A' - 10, %al
    jmp hexprint.done
hexprint.number:
    addb $'0', %al
hexprint.done:
    stosb
    decb %cl
    jnz hexprint.next
    movb $0, %al
    stosb
    lea hexprint_buffer, %si
    call print
    lea str_newline, %si
    call print
    popa
    ret

    .global _start
    .type   _start, @function
_start:
    lea str_hello, %si
    call print
    movw $1, .sectors
    movw $0x7e00, .transfer
    call diskread
    movw $0x7e00, %bx
    jmp *%bx

    .data
    .global .drive
    .set .drive, 0x80

str_hello:        .asciz "casinos stage 1\n\r"
str_err_diskread: .asciz "disk read failed\n\r"
str_newline:      .asciz "\n\r"

    .align 16
hexprint_buffer:   .space 5

    .global dapack
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


