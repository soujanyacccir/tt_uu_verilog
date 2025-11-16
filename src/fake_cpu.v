// fake_cpu.v - for simulation only (drives MMIO writes to test peripherals)
`default_nettype none
module fake_cpu (
    input wire clk,
    input wire rst_n,
    // simple fake bus
    output reg        mem_valid,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg [3:0]  mem_wstrb,
    input  wire [31:0] mem_rdata,
    input  wire        mem_ready
);
    reg [31:0] counter;
    reg [3:0] step;
    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 32'd0;
            mem_valid <= 0;
            mem_addr <= 0;
            mem_wdata <= 0;
            mem_wstrb <= 0;
            step <= 0;
        end else begin
            counter <= counter + 1;
            // every N cycles write a new duty
            if (counter == 32'd1000000) begin
                counter <= 0;
                step <= step + 1;
                mem_valid <= 1;
                mem_wstrb <= 4'hF;
                mem_addr <= 32'h10000000; // PWM duty
                mem_wdata <= {28'd0, (step % 10)};
            end else if (mem_valid && mem_ready) begin
                mem_valid <= 0;
                mem_wstrb <= 0;
            end
        end
    end
endmodule
`default_nettype wire
