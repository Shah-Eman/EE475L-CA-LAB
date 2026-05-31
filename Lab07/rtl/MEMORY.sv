module MEMORY (
    input  logic        clk,
    input  logic        mem_wr,
    input  logic [31:0] pc_addr,
    input  logic [31:0] dmem_addr,
    input  logic [31:0] dmem_wdata,
    output logic [31:0] instr,
    output logic [31:0] dmem_rdata
);

    instr_mem Inst_Mem (
        .addr  (pc_addr),
        .instr (instr)
    );

    data_mem Data_Mem (
        .clk     (clk),
        .wr_en   (mem_wr),
        .addr    (dmem_addr),
        .wr_data (dmem_wdata),
        .rd_data (dmem_rdata)
    );

endmodule
