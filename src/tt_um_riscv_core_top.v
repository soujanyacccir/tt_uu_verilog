module tt_um_riscv_core_top (
    input  wire [7:0]  ui_in,     // user input → used as data
    output wire [7:0]  uo_out,    // GPIO out
    input  wire [7:0]  uio_in,    // used (bit0 = write enable)
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe,
    input  wire        ena,       // used
    input  wire        clk,
    input  wire        rst_n
);

    // -------------------------------
    // SIMPLE GPIO REGISTER
    // -------------------------------
    wire [7:0] gpio_out;

    gpio_reg gpio_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .we       (uio_in[0] & ena),  // write enable from user input
        .wdata    (ui_in),            // write data from external pins
        .rdata    (),                 // unused but connected
        .gpio_out (gpio_out)
    );

    // -------------------------------
    // PWM GENERATOR
    // -------------------------------
    wire pwm_sig;

    pwm_generator pwm_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .duty    (gpio_out),
        .pwm_out (pwm_sig)
    );

    // -------------------------------
    // 7-SEGMENT DISPLAY
    // -------------------------------
    wire [6:0] seg7;

    counter_to_7seg seg_inst (
        .val   (gpio_out[3:0]),
        .seg   (seg7)
    );

    // -------------------------------
    // OUTPUTS
    // -------------------------------
    assign uo_out  = gpio_out;
    assign uio_out = {pwm_sig, seg7};
    assign uio_oe  = 8'hFF;   // drive all outputs

endmodule
