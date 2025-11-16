<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project is a tiny RISC-V SoC built specifically for TinyTapeout.
Inside the chip, a PicoRV32 CPU runs a small firmware program stored in ROM. The CPU reads the buttons, updates the brightness level, and controls two peripherals:

PWM Generator

Produces a pulse-width-modulated output with 10 brightness levels (0–9).

The firmware writes to a MMIO register to set the duty cycle.

The PWM signal appears on uo_out[7] and drives the decimal-point LED on the 7-seg display.

7-Segment Display Driver

The CPU writes the current brightness value (0–9) to a display register.

A hardware 7-segment decoder converts that number to {a,b,c,d,e,f,g} patterns on uo_out[6:0].

Optional extra (if enabled):

A segment animator can flash or rotate the display when the user enables animation from buttons.

## How to test

You can test the project directly on the TinyTapeout demo board or in simulation:

Hardware Test Steps

Reset the system

Press the reset button on the TT board (system starts with brightness = 0).

Increase brightness

Press ui_in[0] (INC button).

The number on the 7-segment display increases.

The LED dot (driven by PWM) becomes brighter.

Decrease brightness

Press ui_in[1] (DEC button).

The number decreases and the LED becomes dimmer.

Observe the outputs

uo_out[6:0] → Shows the brightness level (0–9).

uo_out[7] → PWM output controlling the LED dot intensity.

Simulation Test (optional)

Run the Verilog testbench to see PWM waveform and changes in display output.

Use GTKWave to view:

duty_level

pwm_out

seg_out[6:0]

CPU MMIO writes

## External hardware

Your design uses only standard TinyTapeout demo board components.
No additional external hardware is required.

Included hardware:

On-board 7-segment LED display

Segments driven by outputs uo_out[0]–uo_out[6].

Decimal-point LED driven by uo_out[7] (PWM).

On-board push buttons

Mapped to ui_in[0] (INC) and ui_in[1] (DEC).

On-board clock generator & reset button

Used directly by the design.

No PMODs, no extra sensors, and no external power circuits are needed.
