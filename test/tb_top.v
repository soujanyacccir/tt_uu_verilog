`timescale 1ns/1ps

module tb_top;

    reg clk = 0;
    reg rst_n = 0;

    // Outputs
    wire [7:0] uo_out;

    // Instantiate DUT
    tt_um_riscv_core_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .ui_in(8'h00),
        .uo_out(uo_out),
        .uio_in(8'h00),
        .uio_out(),
        .uio_oe()
    );

    // Fake CPU
    wire cpu_clk = clk;
    wire cpu_reset = ~rst_n;

    always #5 clk = ~clk;  // 100 MHz -> 10ns period (simulation only)

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);

        // Reset sequence
        rst_n = 0;
        repeat(10) @(posedge clk);
        rst_n = 1;

        // Run simulation
        repeat(500) @(posedge clk);

        $display("Simulation finished.");
        $finish;
    end

endmodule
