#![no_std]
#![no_main]


static mut VGA: *mut u8 = 0xb8000 as *mut u8;


fn kprint(s: &str) {
        for (idx, b) in s.bytes().enumerate() {
                let offset = 2 * idx;
                unsafe {
                        core::ptr::write_volatile(VGA.add(offset), b);
                        core::ptr::write_volatile(VGA.add(offset + 1), 0x0f);
                }
        }
}

#[no_mangle]
pub extern "C" fn kmain() -> ! {
        kprint("Hello World!");
        loop { unsafe { core::arch::asm!("hlt"); } }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
        loop {}
}