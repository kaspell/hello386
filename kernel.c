#include <stdint.h>


static volatile uint8_t *const VGA = (uint8_t *)0xb8000;


static void
kprint(const char *s)
{
        int idx = 0;
        for (; *s; ++s) {
                VGA[idx++] = (uint8_t)*s;
                VGA[idx++] = 0x0f;
        }
}

void
kmain(void)
{
        kprint("Hello world!");
        for (;;) { __asm__ __volatile__("hlt"); }
}