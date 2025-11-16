// SPDX-License-Identifier: MIT
module tt_um_riscv_core_top (
    input  wire        clk,       // TinyTapeout clock
    input  wire        rst_n,     // TinyTapeout reset (active low)
    input  wire        ena,       // NEW: enable signal required by TT
    input  wire [7:0]  ui_in,     // unused inputs for now
    output wire [7:0]  uo_out,    // output pins
    input  wire [7:0]  uio_in,    // not used
    output wire [7:0]  uio_out,   // not used
    output wire [7:0]  uio_oe     // set to zero (input-only)
);

    //----------------------------------------------------------------------
    // Internal reset
    //----------------------------------------------------------------------
    wire reset = ~rst_n;

    //----------------------------------------------------------------------
    // RISC-V CPU I/O memory map signals
    //----------------------------------------------------------------------
    wire [31:0] gpio_out;
    wire [31:0] cpu_addr;
    wire [31:0] cpu_wdata;
    wire        cpu_wen;
    wire [31:0] cpu_rdata;

    //----------------------------------------------------------------------
    // ROM
    //----------------------------------------------------------------------
    rv_rom rom_inst (
        .clk   (clk),
        .addr  (cpu_addr[9:2]),
        .data  (cpu_rdata)
    );

    //----------------------------------------------------------------------
    // GPIO register (drives PWM + 7-seg)
    //----------------------------------------------------------------------
    gpio_reg gpio_inst (
        .clk      (clk),
        .reset    (reset),
        .addr     (cpu_addr[3:2]),
        .wdata    (cpu_wdata),
        .wen      (cpu_wen),
        .gpio_out (gpio_out)
    );

    //----------------------------------------------------------------------
    // PWM generator
    //----------------------------------------------------------------------
    wire pwm_out;
    pwm_generator pwm_inst (
        .clk   (clk),
        .reset (reset),
        .duty  (gpio_out[7:0]),
        .pwm   (pwm_out)
    );

    //----------------------------------------------------------------------
    // 7-segment display
    //----------------------------------------------------------------------
    wire [6:0] seg_out;
    counter_to_7seg seg_inst (
        .value (gpio_out[3:0]),
        .seg   (seg_out)
    );

    //----------------------------------------------------------------------
    // Outputs (uo_out[0]=PWM, uo_out[7:1]=7-seg)
    //----------------------------------------------------------------------
    assign uo_out[0]   = pwm_out;
    assign uo_out[7:1] = seg_out;

    //----------------------------------------------------------------------
    // uio = unused
    //----------------------------------------------------------------------
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

endmodule
