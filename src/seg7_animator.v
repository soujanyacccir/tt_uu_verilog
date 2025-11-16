module seg7_animator (
    input wire clk,
    input wire rst_n,
    input wire [3:0] val,
    output reg [6:0] seg
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        seg <= 7'b0000000;
    else begin
        case(val)
            4'h0: seg = 7'b1111110;
            4'h1: seg = 7'b0110000;
            4'h2: seg = 7'b1101101;
            4'h3: seg = 7'b1111001;
            4'h4: seg = 7'b0110011;
            4'h5: seg = 7'b1011011;
            4'h6: seg = 7'b1011111;
            4'h7: seg = 7'b1110000;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1111011;
            default: seg = 7'b0000001;
        endcase
    end
end

endmodule
