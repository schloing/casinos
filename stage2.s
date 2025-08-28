    .section .text
    .code16
    .global _stage2_start
    .att_syntax noprefix

_stage2_start:
    call stage2_main
    hlt

.extern stage2_main