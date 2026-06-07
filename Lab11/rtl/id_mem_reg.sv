module id_mem_reg (
    input  logic        clk,
    input  logic        rst,
    input  logic        valid_in,
    input  logic [31:0] pc_plus4_in,
    input  logic [31:0] imm_in,
    input  logic [31:0] alu_out_in,
    input  logic [31:0] rs2_in,
    input  logic [4:0]  rd_in,
    input  logic        reg_wr_in,
    input  logic        mem_wr_in,
    input  logic [1:0]  result_mux_in,
    output logic        valid_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] imm_out,
    output logic [31:0] alu_out_out,
    output logic [31:0] rs2_out,
    output logic [4:0]  rd_out,
    output logic        reg_wr_out,
    output logic        mem_wr_out,
    output logic [1:0]  result_mux_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out      <= 1'b0;
            pc_plus4_out   <= 32'd0;
            imm_out        <= 32'd0;
            alu_out_out    <= 32'd0;
            rs2_out        <= 32'd0;
            rd_out         <= 5'd0;
            reg_wr_out     <= 1'b0;
            mem_wr_out     <= 1'b0;
            result_mux_out <= 2'b00;
        end else begin
            valid_out      <= valid_in;
            pc_plus4_out   <= pc_plus4_in;
            imm_out        <= imm_in;
            alu_out_out    <= alu_out_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            reg_wr_out     <= reg_wr_in;
            mem_wr_out     <= mem_wr_in;
            result_mux_out <= result_mux_in;
        end
    end

endmodule
