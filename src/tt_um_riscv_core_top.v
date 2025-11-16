// ---------------------------------------------------------
// TinyTapeout Top-Level: RISC-V Core + GPIO + PWM + 7-seg
// ---------------------------------------------------------

module tt_um_riscv_core_top (
    input  wire        clk,       // TinyTapeout clock
    input  wire        rst_n,     // TinyTapeout reset (active low)
    input  wire [7:0]  ui_in,     // unused
    output wire [7:0]  uo_out,    // outputs: PWM + 7seg
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);

    wire reset = ~rst_n;

    // -------------------------------
    // Internal signals
    // -------------------------------
    wire [31:0] cpu_addr;
    wire [31:0] cpu_wdata;
    wire [31:0] cpu_rdata;
    wire        cpu_wstrb;
    wire        cpu_valid;
    wire        cpu_ready;

    // -------------------------------
    // ROM (firmware.hex)
    // -------------------------------
    rv_rom rom (
        .clk(clk),
        .addr(cpu_addr[7:2]),
        .data(cpu_rdata_rom)
    );

    // -------------------------------
    // Simple RAM
    // -------------------------------
    simple_ram ram (
        .clk(clk),
        .we(cpu_wstrb & (cpu_addr[31:12] == 20'h00001)),
        .addr(cpu_addr[7:2]),
        .d_in(cpu_wdata),
        .d_out(cpu_rdata_ram)
    );

    // -------------------------------
    // GPIO register block
    // -------------------------------
    wire [7:0] gpio_out;

    gpio_reg gpio (
        .clk(clk),
        .reset(reset),
        .addr(cpu_addr[7:0]),
        .wdata(cpu_wdata),
        .we(cpu_wstrb & (cpu_addr[31:12] == 20'h00002)),
        .gpio_out(gpio_out),
        .rdata(cpu_rdata_gpio)
    );

    // -------------------------------
    // Read data mux
    // -------------------------------
    assign cpu_rdata =
        (cpu_addr[31:12] == 20'h00000) ? cpu_rdata_rom  :
        (cpu_addr[31:12] == 20'h00001) ? cpu_rdata_ram  :
        (cpu_addr[31:12] == 20'h00002) ? cpu_rdata_gpio :
                                         32'h00000000;

    assign cpu_ready = cpu_valid;

    // -------------------------------
    // PWM generator
    // -------------------------------
    pwm_generator pwm (
        .clk(clk),
        .reset(reset),
        .duty(gpio_out),
        .pwm_out(pwm_out)
    );

    // -------------------------------
    // 7-seg display animator
    // -------------------------------
    wire [6:0] seg7;

    seg7_animator anim (
        .clk(clk),
        .reset(reset),
        .value(gpio_out[3:0]),
        .seg(seg7)
    );

    // -------------------------------
    // Output mapping
    // -------------------------------
    assign uo_out = {pwm_out, seg7};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
