module pwm_generator (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] duty,
    output reg  pwm_out
);

    reg [7:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) 
            counter <= 0;
        else 
            counter <= counter + 1;
    end

    always @(*) begin
        pwm_out = (counter < duty);
    end

endmodule
