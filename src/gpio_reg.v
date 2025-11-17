module gpio_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,
    input  wire [7:0]  wdata,
    output wire [7:0]  rdata,
    output reg  [7:0]  gpio_out
);

    assign rdata = gpio_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            gpio_out <= 8'd0;
        else if (we)
            gpio_out <= wdata;   // FULL BYTE STORE, CORRECT
    end

endmodule
