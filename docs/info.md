# TinyTapeout RISC-V Mini SoC

This project implements a very small RISC-V SoC designed specifically for TinyTapeout.  
It contains:

- Minimal RV32I CPU interface (replaceable with PicoRV32)
- 8-bit GPIO register
- PWM output (brightness control)
- 7-segment LED output
- Internal ROM + small RAM

Works fully with automatic GitHub CI flow of TinyTapeout.

---

## How it Works

### Architecture
The PicoRV32/Fake CPU generates:
- address  
- write data  
- valid  
- write strobe  

These signals access:

1. **ROM (0x00000000)** — contains firmware.hex  
2. **RAM (0x00001000)** — small data memory  
3. **GPIO block (0x00002000)** — drives PWM + 7-seg

The GPIO register value goes to:
- PWM → `uo_out[7]`
- 7-segment encoder → `uo_out[6:0]`

---

## How to Test

### Simulation
```sh
iverilog -o sim.out ../src/*.v tb_top.v
vvp sim.out
gtkwave wave.vcd
