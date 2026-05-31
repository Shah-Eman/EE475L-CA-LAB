`include "opcode.vh"

module DATAPATH (
    input  logic        clk,
    input  logic [31:0] instr,
    input  logic [31:0] mem_rdata,
    input  logic [31:0] pc_plus4,
    output logic        mem_wr,
    output logic [31:0] alu_out,
    output logic [31:0] rs2_data,
    output logic [1:0]  alu_op,
    output logic        reg_wr,
    output logic        imm_sel,
    output logic [1:0]  result_mux,
    output logic        is_branch,
    output logic        is_jump,
    output logic        branch_taken
);

    logic [31:0] rdata1, rdata2, alu_b, wb_data, imm_val, alu_result;
    logic [3:0]  alu_ctrl;
    logic        zero_flag;
    logic [2:0]  funct3;

    assign funct3   = instr[14:12];
    assign alu_b    = imm_sel ? imm_val : rdata2;
    assign rs2_data = rdata2;
    assign alu_out  = alu_result;

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
        .wr_en    (reg_wr),
        .rs1      (instr[19:15]),
        .rs2      (instr[24:20]),
        .rd       (instr[11:7]),
        .wr_data  (wb_data),
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
        if (is_branch) begin
            case (funct3)
                `FNC_BEQ: branch_taken = zero_flag;
                `FNC_BNE: branch_taken = ~zero_flag;
                default:  branch_taken = 1'b0;
            endcase
        end
    end

    always_comb begin
        unique case (result_mux)
            2'b00:   wb_data = alu_result;
            2'b01:   wb_data = mem_rdata;
            2'b10:   wb_data = pc_plus4;
            2'b11:   wb_data = imm_val;
            default: wb_data = alu_result;
        endcase
    end

endmodule
