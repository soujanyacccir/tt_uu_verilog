`timescale 1ns/1ps

module tb;

    // Clock and reset
    reg clk = 0;
    reg rst_n = 0;

    // DUT I/Os
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

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Test procedure
    integer i;

    initial begin
        // Dump waveforms
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // Init
        ui_in  = 8'h00;
        uio_in = 8'h00;
        ena    = 1'b0;

        // Reset
        rst_n = 0;
        repeat (10) @(posedge clk);
        rst_n = 1;

        // Enable
        ena = 1;

        // WRITE 12 VALUES USING uio_in[0] AS WE
        for (i = 0; i < 12; i = i + 1) begin
            ui_in  = i;
            uio_in = 8'b00000001;
            @(posedge clk);
            uio_in = 8'b00000000;
            repeat (5) @(posedge clk);
        end

        $display("TEST FINISHED");
        $finish;
    end

endmodule
