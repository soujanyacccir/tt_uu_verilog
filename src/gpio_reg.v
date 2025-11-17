// gpio_reg.v — FIXED
`default_nettype none

module gpio_reg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       we,
    input  wire [7:0] wdata,
    output reg  [7:0] rdata,
    output reg  [7:0] gpio_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out <= 8'h00;
            rdata    <= 8'h00;
        end else begin
            if (we)
                gpio_out <= wdata;     // FULL BYTE WRITE
            rdata <= gpio_out;
        end
    end

endmodule

`default_nettype wire
