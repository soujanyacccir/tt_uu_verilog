module fake_cpu (
    input  wire clk,
    input  wire reset,
    output reg  valid,
    output reg  [31:0] addr,
    output reg  [31:0] wdata,
    output reg  wstrb
);

    reg [7:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count  <= 0;
            valid  <= 0;
            wstrb  <= 0;
            addr   <= 0;
            wdata  <= 0;
        end else begin
            count <= count + 1;

            // every few cycles write to GPIO
            if (count[2:0] == 3'b000) begin
                valid <= 1;
                wstrb <= 1;
                addr  <= 32'h00002000;
                wdata <= count;
            end else begin
                valid <= 0;
                wstrb <= 0;
            end
        end
    end
endmodule
