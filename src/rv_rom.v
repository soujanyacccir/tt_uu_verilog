module rv_rom (
    input  wire        clk,
    input  wire [5:0]  addr,
    output reg  [31:0] data
);
    reg [31:0] mem[0:63];

    initial begin
        $readmemh("firmware.hex", mem);
    end

    always @(posedge clk)
        data <= mem[addr];
endmodule
