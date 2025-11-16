module tt_um_riscv_core_top (
    input  wire [7:0]  ui_in,     // unused
    output wire [7:0]  uo_out,    // gpio_out
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe,
    input  wire        ena,
    input  wire        clk,
    input  wire        rst_n
);

    // CPU <-> GPIO
    wire [7:0] cpu_wdata;
    wire [7:0] cpu_rdata;
    wire       cpu_wen;

    wire [7:0] gpio_out;

    // -------------------------------
    // GPIO REGISTER
    // -------------------------------
   gpio_reg gpio_inst (
    .clk       (clk),
    .rst_n     (rst_n),
    .address   (ui_in[3:0]),    // FIXED
    .wdata     (cpu_wdata),
    .we        (cpu_we),
    .rdata     (cpu_rdata)      // FIXED
);

    // -------------------------------
    // PWM generator (uses gpio_out)
    // -------------------------------
    wire pwm_sig;

    pwm_generator pwm_inst (
        .clk     (clk),
        .rst_n     (rst_n),
        .duty    (gpio_out),
        .pwm_out (pwm_sig)            // FIXED
    );

    // -------------------------------
    // 7-seg display
    // -------------------------------
    wire [6:0] seg7;

    counter_to_7seg seg_inst (
        .val   (gpio_out[3:0]),       // FIXED
        .seg   (seg7)
    );

    // -------------------------------
    // OUTPUTS
    // -------------------------------
    assign uo_out  = gpio_out;
    assign uio_out = {pwm_sig, seg7};
    assign uio_oe  = 8'hFF;

endmodule
