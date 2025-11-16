// fake_cpu.v - drives MMIO writes periodically for simulation
`default_nettype none
module fake_cpu (
    input wire clk,
    input wire rst_n,
    output reg        mem_valid,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg [3:0]  mem_wstrb,
    input  wire [31:0] mem_rdata,
    input  wire        mem_ready
);
    reg [31:0] counter;
    reg [3:0] duty;
    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 32'd0; mem_valid <= 0; mem_addr <= 0; mem_wdata <= 0; mem_wstrb <= 0; duty <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 32'd500000) begin
                counter <= 0;
                mem_valid <= 1;
                mem_wstrb <= 4'hF;
                mem_addr <= 32'h10000000; // PWM duty address
                mem_wdata <= {28'd0, duty};
                duty <= (duty == 9) ? 0 : duty + 1;
            end else if (mem_valid && mem_ready) begin
                mem_valid <= 0;
                mem_wstrb <= 0;
            end
        end
    end
endmodule
`default_nettype wire
