// gpio_reg.v
// Simple 8-bit GPIO register, synchronous write, asynchronous active-low reset.
// - we: active-high write enable (sampled on posedge clk)
// - wdata: 8-bit input data to store
// - rdata: continuous readback of stored gpio_out
// - gpio_out: stored register (also exposed)

`default_nettype none
module gpio_reg (
    input  wire        clk,
    input  wire        rst_n,    // active-low
    input  wire        we,       // write enable (sampled on posedge)
    input  wire [7:0]  wdata,    // write-data
    output wire [7:0]  rdata,    // readback
    output reg  [7:0]  gpio_out  // stored register
);

    // synchronous write, async reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out <= 8'b0;
        end else begin
            if (we)
                gpio_out <= wdata;   // store entire byte on one posedge
            else
                gpio_out <= gpio_out; // explicit for clarity (non-blocking)
        end
    end

    assign rdata = gpio_out;

endmodule
`default_nettype wire
