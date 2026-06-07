module IF_STAGE #(
    parameter RESET_PC  = 32'h1000_0000,
    parameter IMEM_FILE = ""
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        pc_en,
    input  logic [31:0] pc_next,
    output logic [31:0] pc_f,
    output logic [31:0] pc_plus4_f,
    output logic [31:0] instr_f
);

    pc #(.RESET_VAL(RESET_PC)) pc_reg (
        .clk     (clk),
        .rst     (rst),
        .pc_en   (pc_en),
        .next_pc (pc_next),
        .curr_pc (pc_f)
    );

    assign pc_plus4_f = pc_f + 32'd4;

    instr_mem #(.INIT_FILE(IMEM_FILE)) Inst_Mem (
        .addr  (pc_f),
        .instr (instr_f)
    );

endmodule
