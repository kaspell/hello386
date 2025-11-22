KERN_SRC ?= C

OUT := os.img

BOOT := ./boot.asm
LOADER := ./loader.asm
START := ./start.asm

BOOT_BIN := $(BOOT:.asm=.bin)
LOADER_BIN := $(LOADER:.asm=.bin)

START_OBJ := $(START:.asm=.o)
KERNEL_OBJ := kernel.o

BOOTLOADER_SRC := $(BOOT) $(LOADER)
BOOTLOADER_BIN := $(BOOT_BIN) $(LOADER_BIN)

CRATE_NAME := rs_kern
RUST_KERNEL_LIB := target/i386-elf/release/lib$(CRATE_NAME).a

KERNEL_ELF := kernel.elf
KERNEL_BIN := kernel.bin

LINKER_SCRIPT := linker.ld

OBJ := $(START_OBJ) $(KERNEL_OBJ)


CC := x86_64-elf-gcc
LD := x86_64-elf-ld
AS := nasm
OBJCOPY := x86_64-elf-objcopy
QEMU := qemu-system-x86_64

CFLAGS := -m32 -ffreestanding -nostdlib -Wall -Wextra -c
LDFLAGS := -m elf_i386 -T linker.ld
QFLAGS := -fda


build: $(OUT)

.PHONY: clean
clean:
	rm -f $(OBJ) $(BOOTLOADER_BIN) $(KERNEL_ELF) $(KERNEL_BIN) $(OUT)
	cargo clean

run: $(OUT)
	$(QEMU) $(QFLAGS) $(OUT)

$(OUT): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	cat $(BOOTLOADER_BIN) $(KERNEL_BIN) >$(OUT)

$(BOOTLOADER_BIN): $(BOOT) $(LOADER) $(KERNEL_BIN)
	$(AS) -f bin $(BOOT) -o $(BOOT_BIN)
	$(AS) -f bin $(LOADER) -o $(LOADER_BIN)

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

ifeq ($(KERN_SRC), rust)
$(KERNEL_ELF): $(OBJ) $(LINKER_SCRIPT) $(RUST_KERNEL_LIB) 
	$(LD) $(LDFLAGS) -o $(KERNEL_ELF) $(OBJ) $(RUST_KERNEL_LIB) 
else
$(KERNEL_ELF): $(OBJ) $(LINKER_SCRIPT)
	$(LD) $(LDFLAGS) -o $(KERNEL_ELF) $(OBJ)
endif

$(RUST_KERNEL_LIB):
	cargo build --release

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

%.o: %.asm
	$(AS) -f elf32 $< -o $@