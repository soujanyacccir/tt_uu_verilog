module counter_to_7seg (
    input  wire [3:0] val,
    output wire [6:0] seg
);

assign seg = 7'b0000000; // dummy combinational (replace if needed)

endmodule
