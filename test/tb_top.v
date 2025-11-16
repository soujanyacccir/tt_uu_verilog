// tb_top.v - quick functional simulation using fake_cpu
`timescale 1ns/1ps
`default_nettype none
module tb_top;
    reg clk;
    reg rst_n;
    wire [7:0] ui_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // tie unused inputs low, btns pinned in gpio_reg reads from ui_in[1:0]
    reg [7:0] ui_in_r = 8'b0;
    assign ui_in = ui_in_r;

    // instantiate top but replace picorv32 with fake_cpu by editing top (or instantiate fake_cpu externally).
    // For simplicity, create a small wrapper top that connects fake_cpu to gpio_reg directly in test.
    // NOTE: This tb expects you to instantiate a test-specific top or modify tt_um_pwm_rv_top to allow fake_cpu.
    initial begin
        $display("Testbench: please instantiate project-specific wrapper that connects fake_cpu to gpio_reg for simulation");
        $finish;
    end
endmodule
`default_nettype wire
