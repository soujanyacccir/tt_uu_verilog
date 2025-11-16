// tt_um_pwm_rv_top.v
`default_nettype none

`include "counter_to_7seg.v"   // reuse your decoder
`include "pwm_generator.v"
`include "seg7_animator.v"

module tt_um_pwm_rv_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // CPU side wires (simple memory-mapped bus)
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Instantiate picorv32 (blackbox). You must provide picorv32.v (official core).
    // Minimal port set assumed — adapt names if your picorv32 version differs.
    picorv32 picorv32_core (
        .clk      (clk),
        .resetn   (rst_n),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // Simple memory + MMIO
    wire rom_sel  = (mem_addr[31:12] == 20'h00000); // 0x0000_0000..0x0000_0FFF -> ROM
    wire mmio_sel = (mem_addr[31:12] == 20'h10000); // 0x1000_0000.. -> MMIO

    reg [31:0] rom_mem [0:4095]; // small ROM (4096 words)
    initial begin
        // firmware.hex must be placed in the project root or src and is read here
        $readmemh("firmware.hex", rom_mem);
    end

    reg [31:0] mem_rdata_r;
    reg mem_ready_r;

    // MMIO registers
    reg [3:0]  pwm_duty_reg;     // 0..9
    reg [3:0]  display_val_reg;  // 0..9
    reg [1:0]  anim_reg;         // bit0 = enable, bit1 = mode (0 flash / 1 rotate)

    // read data mux and ready handling
    always @(*) begin
        mem_rdata_r = 32'd0;
        mem_ready_r = 1'b0;
        if (mem_valid) begin
            if (rom_sel) begin
                mem_rdata_r = rom_mem[mem_addr[13:2]]; // word address
                mem_ready_r = 1'b1;
            end else if (mmio_sel) begin
                case (mem_addr[3:0])
                    4'h0: begin // PWM duty (readback)
                        mem_rdata_r = {28'd0, pwm_duty_reg};
                        mem_ready_r = 1'b1;
                    end
                    4'h4: begin // display val
                        mem_rdata_r = {28'd0, display_val_reg};
                        mem_ready_r = 1'b1;
                    end
                    4'h8: begin // anim reg
                        mem_rdata_r = {30'd0, anim_reg};
                        mem_ready_r = 1'b1;
                    end
                    4'hC: begin // buttons (ui_in)
                        mem_rdata_r = {30'd0, ui_in[1:0]}; // bit1 = DEC, bit0 = INC
                        mem_ready_r = 1'b1;
                    end
                    default: begin
                        mem_rdata_r = 32'd0;
                        mem_ready_r = 1'b1;
                    end
                endcase
            end else begin
                mem_rdata_r = 32'd0;
                mem_ready_r = 1'b1; // NOP for unmapped addresses
            end
        end
    end

    // write handling (synchronous)
    always @(posedge clk) begin
        if (!rst_n) begin
            pwm_duty_reg    <= 4'd0;
            display_val_reg <= 4'd0;
            anim_reg        <= 2'd0;
        end else begin
            // Simple single-cycle write acceptance: rely on mem_valid & mem_wstrb
            if (mem_valid && mmio_sel && |mem_wstrb) begin
                case (mem_addr[3:0])
                    4'h0: pwm_duty_reg    <= mem_wdata[3:0];
                    4'h4: display_val_reg <= mem_wdata[3:0];
                    4'h8: anim_reg        <= mem_wdata[1:0];
                endcase
            end
        end
    end

    // Tie outputs from peripherals
    wire [6:0] seg7;
    wire pwm_sig;
    wire [6:0] seg7_animated;

    // Convert display_val_reg to 7-seg
    counter_to_7seg u_decoder(.count_i(display_val_reg), .seg_o(seg7));

    // PWM generator
    pwm_generator u_pwm(
        .duty_level_i(display_val_reg), // or pwm_duty_reg — choose based on behavior; we'll use pwm_duty_reg
        .clk_i(clk),
        .rst_i(~rst_n),
        .pwm_sig_o(pwm_sig)
    );

    // Animator
    seg7_animator u_anim(
        .clk_i(clk),
        .rst_i(~rst_n),
        .mode_i(anim_reg[1]),
        .seg_o(seg7_animated)
    );

    // top-level selection between animated or static based on anim_reg[0]
    wire [6:0] seg_out = (anim_reg[0]) ? seg7_animated : seg7;

    // Drive outputs: uo_out[6:0] = seg_out; uo_out[7] = pwm_sig
    assign uo_out = { pwm_sig, seg_out }; // uo_out[7]=pwm_sig, uo_out[6:0]=seg_out
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // mem interface wiring back to picorv32
    assign mem_rdata = mem_rdata_r;
    assign mem_ready = mem_ready_r;

endmodule
