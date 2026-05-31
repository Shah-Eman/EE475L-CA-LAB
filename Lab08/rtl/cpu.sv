module cpu (
    input logic clk,
    input logic rst
);

    logic [31:0] pc_next, pc_f, pc_plus4_f, instr_f;
    logic [31:0] if_id_pc, if_id_pc_plus4, if_id_instr;
    logic        if_id_valid, if_id_flush;

    logic        ex_valid, ex_reg_wr, ex_mem_wr;
    logic [31:0] ex_pc_plus4, ex_imm, ex_alu_out, ex_rs2;
    logic [4:0]  ex_rd;
    logic [1:0]  ex_result_mux;
    logic        ex_redirect;
    logic [31:0] ex_redirect_pc;

    logic        mem_valid, mem_reg_wr, mem_mem_wr;
    logic [31:0] mem_pc_plus4, mem_imm, mem_alu_out, mem_rs2;
    logic [4:0]  mem_rd;
    logic [1:0]  mem_result_mux;

    logic        wb_reg_wr;
    logic [4:0]  wb_rd;
    logic [31:0] wb_data;

    assign pc_next    = ex_redirect ? ex_redirect_pc : pc_plus4_f;
    assign if_id_flush = ex_redirect;

    IF_STAGE IF_STAGE (
        .clk         (clk),
        .rst         (rst),
        .pc_en       (1'b1),
        .pc_next     (pc_next),
        .pc_f        (pc_f),
        .pc_plus4_f  (pc_plus4_f),
        .instr_f     (instr_f)
    );

    if_id_reg if_id (
        .clk          (clk),
        .rst          (rst),
        .flush        (if_id_flush),
        .pc_in        (pc_f),
        .pc_plus4_in  (pc_plus4_f),
        .instr_in     (instr_f),
        .pc_out       (if_id_pc),
        .pc_plus4_out (if_id_pc_plus4),
        .instr_out    (if_id_instr),
        .valid_out    (if_id_valid)
    );

    ID_EX ID_EX (
        .clk            (clk),
        .instr          (if_id_instr),
        .pc             (if_id_pc),
        .pc_plus4       (if_id_pc_plus4),
        .valid          (if_id_valid),
        .redirect       (ex_redirect),
        .redirect_pc    (ex_redirect_pc),
        .valid_out      (ex_valid),
        .pc_plus4_out   (ex_pc_plus4),
        .imm_out        (ex_imm),
        .alu_out        (ex_alu_out),
        .rs2_out        (ex_rs2),
        .rd_out         (ex_rd),
        .reg_wr_out     (ex_reg_wr),
        .mem_wr_out     (ex_mem_wr),
        .result_mux_out (ex_result_mux),
        .reg_wr_en      (wb_reg_wr),
        .reg_wr_addr    (wb_rd),
        .reg_wr_data    (wb_data)
    );

    id_mem_reg id_mem (
        .clk            (clk),
        .rst            (rst),
        .valid_in       (ex_valid),
        .pc_plus4_in    (ex_pc_plus4),
        .imm_in         (ex_imm),
        .alu_out_in     (ex_alu_out),
        .rs2_in         (ex_rs2),
        .rd_in          (ex_rd),
        .reg_wr_in      (ex_reg_wr),
        .mem_wr_in      (ex_mem_wr),
        .result_mux_in  (ex_result_mux),
        .valid_out      (mem_valid),
        .pc_plus4_out   (mem_pc_plus4),
        .imm_out        (mem_imm),
        .alu_out_out    (mem_alu_out),
        .rs2_out        (mem_rs2),
        .rd_out         (mem_rd),
        .reg_wr_out     (mem_reg_wr),
        .mem_wr_out     (mem_mem_wr),
        .result_mux_out (mem_result_mux)
    );

    MEM_WB MEM_WB (
        .clk          (clk),
        .valid        (mem_valid),
        .alu_out      (mem_alu_out),
        .rs2_data     (mem_rs2),
        .pc_plus4     (mem_pc_plus4),
        .imm_val      (mem_imm),
        .rd           (mem_rd),
        .reg_wr       (mem_reg_wr),
        .mem_wr       (mem_mem_wr),
        .result_mux   (mem_result_mux),
        .reg_wr_en    (wb_reg_wr),
        .reg_wr_addr  (wb_rd),
        .reg_wr_data  (wb_data)
    );

endmodule
