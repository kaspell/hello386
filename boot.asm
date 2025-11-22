; boot.asm
bits 16

FIRST_STAGE_START_ADDR equ 0x7c00
SECOND_STAGE_START_ADDR equ 0x7e00

org FIRST_STAGE_START_ADDR


start:
        cli
        jmp 0x0000:.init_segment_registers
.init_segment_registers:
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ss, ax
        mov sp, FIRST_STAGE_START_ADDR

        mov [BOOT_DRIVE_ID], dl
        sti

        mov ah, 0x02
        mov al, 5
        mov ch, 0
        mov cl, 2
        mov dh, 0
        mov bx, SECOND_STAGE_START_ADDR
        mov dl, [BOOT_DRIVE_ID]
        int 0x13

        jc halt

        jmp SECOND_STAGE_START_ADDR

halt:
        cli
        hlt
        jmp halt


BOOT_DRIVE_ID db 0x00

PADDING_BYTES_COUNT equ 510 - ($ - $$)
times PADDING_BYTES_COUNT db 0

db 0x55
db 0xaa