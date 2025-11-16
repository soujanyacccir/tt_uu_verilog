// rv_rom.v
`default_nettype none
module rv_rom #(
    parameter WORDS = 4096
) (
    input  wire         clk,
    input  wire [11:0]  addr,   // word address
    output reg  [31:0]  rdata
);
    reg [31:0] mem [0:WORDS-1];
    initial begin
        $readmemh("firmware.hex", mem);
    end

    always @(posedge clk) begin
        rdata <= mem[addr];
    end
endmodule
`default_nettype wire
