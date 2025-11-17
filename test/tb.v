`timescale 1ns/1ps

module tb;

    reg clk = 0;
    reg rst_n = 0;

    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena;

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

    always #5 clk = ~clk;

    integer i;
    initial begin
        ui_in  = 0;
        uio_in = 0;
        ena    = 0;

        rst_n = 0;
        repeat (10) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        ena = 1;

        for (i = 0; i < 12; i = i + 1) begin
            ui_in = i;
            uio_in = 8'b00000001;
            @(posedge clk);
            uio_in = 0;
            repeat (10) @(posedge clk);
        end

        $finish;
    end

endmodule
