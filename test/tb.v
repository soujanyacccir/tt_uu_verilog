// test/tb.v
`timescale 1ns/1ps

module tb;

    // Clock and reset
    reg clk = 0;
    reg rst_n = 0;

    // DUT I/Os (match your top header exactly)
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena;

    // Instantiate DUT
    tt_um_riscv_core_top dut (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .ena    (ena),
        .clk    (clk),
        .rst_n  (rst_n)
    );

    // Clock: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    integer i;
    initial begin
        // Waveform
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // Initialize signals
        ui_in  = 8'h00;
        uio_in = 8'h00;
        ena    = 1'b0;

        // Reset pulse
        rst_n = 0;
        repeat (10) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // Enable writes
        ena = 1'b1;

        // Write a few values to GPIO using uio_in[0] as write enable
        // Each write: set ui_in, pulse uio_in[0] high for one cycle
        for (i = 0; i < 12; i = i + 1) begin
            ui_in = i;                // data to be written
            uio_in = 8'b00000001;     // write enable asserted
            @(posedge clk);
            uio_in = 8'b00000000;     // deassert
            // wait a few cycles so PWM/7seg can animate
            repeat (10) @(posedge clk);
        end

        // Toggle enable off/on to exercise ena path
        ena = 0;
        ui_in = 8'hAA;
        uio_in = 8'b00000001;
        @(posedge clk);
        uio_in = 8'b00000000;
        repeat (5) @(posedge clk);

        ena = 1;
        ui_in = 8'h55;
        uio_in = 8'b00000001;
        @(posedge clk);
        uio_in = 8'b00000000;
        repeat (10) @(posedge clk);

        $display("TEST FINISHED");
        $finish;
    end

    // Optional: monitor outputs to console for quick textual check
    initial begin
        $display("Time  ui_in  uo_out  uio_out");
        $monitor("%0t  %02h    %02h    %02h", $time, ui_in, uo_out, uio_out);
    end

endmodule
