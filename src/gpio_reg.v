module gpio_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  addr,
    input  wire [31:0] wdata,
    input  wire        we,
    output reg  [7:0]  gpio_out,
    output reg  [31:0] rdata
);

    always @(posedge clk) begin
        if (reset) begin
            gpio_out <= 8'h00;
        end else if (we) begin
            if (addr == 8'h00)
                gpio_out <= wdata[7:0];
        end
    end

    always @(*) begin
        if (addr == 8'h00)
            rdata = {24'h0, gpio_out};
        else
            rdata = 32'h00000000;
    end
endmodule
