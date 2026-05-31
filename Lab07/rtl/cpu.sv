`include "opcode.vh"

module cpu (
    input logic clk,
    input logic rst
);

    logic [31:0] pc_curr, pc_plus4, pc_next, imm_val;
    logic [31:0] instr, mem_rdata, alu_out, rs2_data;
    logic [1:0]  alu_op, result_mux;
    logic        mem_wr, reg_wr, imm_sel, is_branch, is_jump, branch_taken, take_pc_jump;

    assign pc_plus4 = pc_curr + 32'd4;

    assign take_pc_jump = is_jump || (is_branch && branch_taken);
    assign pc_next      = take_pc_jump ? (pc_curr + imm_val) : pc_plus4;

    pc pc_reg (
        .clk     (clk),
        .rst     (rst),
        .next_pc (pc_next),
        .curr_pc (pc_curr)
    );

    MEMORY MEMORY (
        .clk        (clk),
        .mem_wr     (mem_wr),
        .pc_addr    (pc_curr),
        .dmem_addr  (alu_out),
        .dmem_wdata (rs2_data),
        .instr      (instr),
        .dmem_rdata (mem_rdata)
    );

    DATAPATH DATAPATH (
        .clk           (clk),
        .instr         (instr),
        .mem_rdata     (mem_rdata),
        .pc_plus4      (pc_plus4),
        .mem_wr        (mem_wr),
        .alu_out       (alu_out),
        .rs2_data      (rs2_data),
        .alu_op        (alu_op),
        .reg_wr        (reg_wr),
        .imm_sel       (imm_sel),
        .result_mux    (result_mux),
        .is_branch     (is_branch),
        .is_jump       (is_jump),
        .branch_taken  (branch_taken)
    );

    imm_gen imm_for_branch (
        .instr_word (instr),
        .imm_out    (imm_val)
    );

endmodule
