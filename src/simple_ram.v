module simple_ram (
    input  wire clk,
    input  wire rst_n,
    input  wire we,
    input  wire [7:0] addr,
    input  wire [7:0] wdata,
    output reg  [7:0] rdata
);

reg [7:0] mem [0:255];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rdata <= 8'h00;
    else begin
        if (we)
            mem[addr] <= wdata;
        rdata <= mem[addr];
    end
end

endmodule
