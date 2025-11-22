; start.asm
bits 32

extern kmain


section .text
global _start
_start:
        mov esp, stack_top
        call kmain


section .bss
align 16

resb 4096
stack_top: