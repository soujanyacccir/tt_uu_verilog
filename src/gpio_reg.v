module gpio_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  addr,
    input  wire [7:0]  wdata,
    input  wire        we,
    output reg  [7:0]  rdata_out,
    output reg  [7:0]  gpio_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gpio_out <= 8'h00;
        end else if (we) begin
            gpio_out <= wdata;
        end
    end

    always @(*) begin
        rdata_out = gpio_out;
    end

endmodule
