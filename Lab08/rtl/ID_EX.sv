`include "opcode.vh"

module ID_EX (
    input  logic        clk,
    input  logic [31:0] instr,
    input  logic [31:0] pc,
    input  logic [31:0] pc_plus4,
    input  logic        valid,
    output logic        redirect,
    output logic [31:0] redirect_pc,
    output logic        valid_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] imm_out,
    output logic [31:0] alu_out,
    output logic [31:0] rs2_out,
    output logic [4:0]  rd_out,
    output logic        reg_wr_out,
    output logic        mem_wr_out,
    output logic [1:0]  result_mux_out,
    input  logic        reg_wr_en,
    input  logic [4:0]  reg_wr_addr,
    input  logic [31:0] reg_wr_data
);

    logic [31:0] rdata1, rdata2, alu_b, imm_val, alu_result;
    logic [3:0]  alu_ctrl;
    logic [1:0]  alu_op, result_mux;
    logic [2:0]  funct3;
    logic        zero_flag, reg_wr, imm_sel, mem_wr, is_branch, is_jump, branch_taken;

    assign funct3   = instr[14:12];
    assign alu_b    = imm_sel ? imm_val : rdata2;
    assign valid_out      = valid;
    assign pc_plus4_out   = pc_plus4;
    assign imm_out        = imm_val;
    assign alu_out        = alu_result;
    assign rs2_out        = rdata2;
    assign rd_out         = instr[11:7];
    assign reg_wr_out     = valid && reg_wr;
    assign mem_wr_out     = valid && mem_wr;
    assign result_mux_out = result_mux;

    main_controller ctrl (
        .opcode     (instr[6:0]),
        .alu_op     (alu_op),
        .reg_wr     (reg_wr),
        .imm_sel    (imm_sel),
        .result_mux (result_mux),
        .mem_wr     (mem_wr),
        .is_branch  (is_branch),
        .is_jump    (is_jump)
    );

    imm_gen imm_unit (
        .instr_word (instr),
        .imm_out    (imm_val)
    );

    reg_file Reg_file (
        .clk      (clk),
        .wr_en    (reg_wr_en),
        .rs1      (instr[19:15]),
        .rs2      (instr[24:20]),
        .rd       (reg_wr_addr),
        .wr_data  (reg_wr_data),
        .rd_data1 (rdata1),
        .rd_data2 (rdata2)
    );

    alu_controller alu_ctrl_unit (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7   (instr[31:25]),
        .alu_ctrl (alu_ctrl)
    );

    alu alu_core (
        .src_a     (rdata1),
        .src_b     (alu_b),
        .op_sel    (alu_ctrl),
        .out       (alu_result),
        .zero_flag (zero_flag)
    );

    always_comb begin
        branch_taken = 1'b0;
        if (valid && is_branch) begin
            case (funct3)
                `FNC_BEQ: branch_taken = zero_flag;
                `FNC_BNE: branch_taken = ~zero_flag;
                default:  branch_taken = 1'b0;
            endcase
        end
    end

    assign redirect    = valid && (is_jump || (is_branch && branch_taken));
    assign redirect_pc = pc + imm_val;

endmodule
