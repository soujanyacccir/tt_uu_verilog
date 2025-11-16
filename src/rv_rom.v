// rv_rom.v
`default_nettype none
`ifndef __RV_ROM__
`define __RV_ROM__

module rv_rom #(
    parameter WORDS = 4096
) (
    input  wire        clk,
    input  wire [11:0] addr, // word address (12 bits -> 4096 words)
    output reg  [31:0] rdata,
    input  wire        we
);

    reg [31:0] mem [0:WORDS-1];
    initial begin
        // firmware.hex must be in project root or simulation working dir
        // The hex must be in verilog format (objcopy -O verilog ...)
        $readmemh("firmware.hex", mem);
    end

    always @(posedge clk) begin
        if (we) begin
            // ROM typically not written; stub if needed
        end
        rdata <= mem[addr];
    end
endmodule

`endif
`default_nettype wire
