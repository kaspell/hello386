; loader.asm
bits 16

KERN_START_ADDR equ 0x00100000
SECOND_STAGE_START_ADDR equ 0x7e00

org SECOND_STAGE_START_ADDR


section .text
start:
        cli
.wait:
        in al, 0x64
        test al, 2
        jnz .wait
        mov al, 0xd1
        out 0x64, al
.wait2:
        in al, 0x64
        test al, 2
        jnz .wait2
        mov al, 0xdf
        out 0x60, al

        lgdt [gdt_desc]

        mov eax, cr0
        or eax, 1
        mov cr0, eax

        jmp CODE_SEG:protected_mode_start


bits 32

protected_mode_start:
        mov ax, DATA_SEG
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        mov esp, stack_top

        cld
        mov esi, kern_img_start
        mov edi, KERN_START_ADDR
        mov ecx, KERN_BYTES_COUNT
        rep movsb

        jmp KERN_START_ADDR


section .data
align 8

gdt_start:
        db 0x00
        db 0x00
        db 0x00
        db 0x00
        db 0x00
        db 0x00
        db 0x00
        db 0x00
gdt_code:
        db 0xff                 ; Limit
        db 0xff                 ; Limit
        db 0x00                 ; Base
        db 0x00                 ; Base
        db 0x00                 ; Base
        db 0x9a                 ; Access Byte
        db 0xcf                 ; Flags and Limit
        db 0x00                 ; Base
gdt_data:
        db 0xff                 ; Limit
        db 0xff                 ; Limit
        db 0x00                 ; Base
        db 0x00                 ; Base
        db 0x00                 ; Base
        db 0x92                 ; Access Byte
        db 0xcf                 ; Flags and Limit
        db 0x00                 ; Base
gdt_end:

gdt_desc:
        dw gdt_end - gdt_start - 1
        dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


kern_img_start:
        incbin "kernel.bin"
kern_img_end:

KERN_BYTES_COUNT equ kern_img_end - kern_img_start


section .bss

stack_bottom:
    resb 4096
stack_top: