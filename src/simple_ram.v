// simple_ram.v
`default_nettype none
module simple_ram #(
    parameter WORDS = 1024
) (
    input  wire        clk,
    input  wire [11:0] addr,
    input  wire [31:0] wdata,
    input  wire        wen,
    output reg  [31:0] rdata
);
    reg [31:0] mem [0:WORDS-1];
    always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
    end
endmodule
`default_nettype wire
