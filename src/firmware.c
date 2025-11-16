/* firmware.c
 * Simple RISC-V firmware to poll buttons and update PWM/display
 */
#include <stdint.h>

#define MMIO_PWM_DUTY  (*(volatile uint32_t*)0x10000000)
#define MMIO_DISPLAY   (*(volatile uint32_t*)0x10000004)
#define MMIO_ANIM      (*(volatile uint32_t*)0x10000008)
#define MMIO_BUTTONS   (*(volatile uint32_t*)0x1000000C)

static inline void delay(volatile int n) {
    while (n--) { asm volatile("nop"); }
}

int main() {
    uint32_t duty = 0;
    uint32_t prev_buttons = 0;

    MMIO_PWM_DUTY = duty;
    MMIO_DISPLAY  = duty;
    MMIO_ANIM     = 0;

    while (1) {
        uint32_t buttons = MMIO_BUTTONS & 0x3;
        if ((buttons & 1) && !(prev_buttons & 1)) {
            if (duty < 9) duty++;
        }
        if ((buttons & 2) && !(prev_buttons & 2)) {
            if (duty > 0) duty--;
        }
        prev_buttons = buttons;
        MMIO_PWM_DUTY = duty;
        MMIO_DISPLAY  = duty;
        delay(100000);
    }
    return 0;
}
