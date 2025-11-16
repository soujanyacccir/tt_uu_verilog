module simple_ram (
    input  wire        clk,
    input  wire        we,
    input  wire [5:0]  addr,
    input  wire [31:0] d_in,
    output reg  [31:0] d_out
);

    reg [31:0] mem[0:63];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= d_in;
        d_out <= mem[addr];
    end
endmodule
