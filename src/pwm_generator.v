module pwm_generator (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] duty,
    output reg        pwm_out
);

reg [7:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt     <= 0;
        pwm_out <= 0;
    end else begin
        cnt <= cnt + 1;
        pwm_out <= (cnt < duty);
    end
end

endmodule
