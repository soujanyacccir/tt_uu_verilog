// tt_um_riscv_core_top.v
`default_nettype none

`include "counter_to_7seg.v"
`include "pwm_generator.v"
`include "seg7_animator.v"
`include "rv_rom.v"
`include "gpio_reg.v"

module tt_um_riscv_core_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // CPU memory interface (picorv32 style)
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

`ifdef USE_FAKE_CPU
    // Simulation-only tiny fake CPU (drives MMIO writes)
    fake_cpu cpu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)
    );
`else
    // Real PicoRV32 core (you must provide picorv32.v in src/)
    picorv32 picorv32_core (
        .clk      (clk),
        .resetn   (rst_n),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );
`endif

    // ROM (0x0000_0000) instance (reads firmware.hex)
    // Access handled by gpio_reg (mem_rdata/mem_ready)
    // Instantiate ROM separately if you want direct reads: we provide rv_rom for completeness.

    // GPIO/MMIO peripheral instance — provides registers and readback
    wire [3:0] pwm_duty_reg;
    wire [3:0] display_val_reg;
    wire [1:0] anim_reg;
    gpio_reg gpio (
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready),
        .btns(ui_in[1:0]),
        .pwm_duty_reg(pwm_duty_reg),
        .display_val_reg(display_val_reg),
        .anim_reg(anim_reg)
    );

    // peripherals
    wire pwm_sig;
    wire [6:0] seg7;
    wire [6:0] seg7_animated;

    counter_to_7seg decoder (.count_i(display_val_reg), .seg_o(seg7) );

    pwm_generator pwm_inst(
        .duty_level_i(pwm_duty_reg),
        .clk_i(clk),
        .rst_i(~rst_n),
        .pwm_sig_o(pwm_sig)
    );

    seg7_animator anim_inst(
        .clk_i(clk),
        .rst_i(~rst_n),
        .mode_i(anim_reg[1]),
        .seg_o(seg7_animated)
    );

    wire [6:0] seg_out = (anim_reg[0]) ? seg7_animated : seg7;

    // Drive outputs: uo_out[7]=PWM, uo_out[6:0]=seg_out
    assign uo_out = { pwm_sig, seg_out };
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule

`default_nettype wire
