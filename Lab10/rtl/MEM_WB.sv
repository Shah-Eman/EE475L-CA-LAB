module MEM_WB (
    input  logic        clk,
    input  logic        valid,
    input  logic [31:0] alu_out,
    input  logic [31:0] rs2_data,
    input  logic [31:0] pc_plus4,
    input  logic [31:0] imm_val,
    input  logic [4:0]  rd,
    input  logic        reg_wr,
    input  logic        mem_wr,
    input  logic [1:0]  result_mux,
    output logic        reg_wr_en,
    output logic [4:0]  reg_wr_addr,
    output logic [31:0] reg_wr_data
);

    logic [31:0] mem_rdata, wb_data;

    data_mem Data_Mem (
        .clk     (clk),
        .wr_en   (valid && mem_wr),
        .addr    (alu_out),
        .wr_data (rs2_data),
        .rd_data (mem_rdata)
    );

    always_comb begin
        unique case (result_mux)
            2'b00:   wb_data = alu_out;
            2'b01:   wb_data = mem_rdata;
            2'b10:   wb_data = pc_plus4;
            2'b11:   wb_data = imm_val;
            default: wb_data = alu_out;
        endcase
    end

    assign reg_wr_en   = valid && reg_wr;
    assign reg_wr_addr = rd;
    assign reg_wr_data = wb_data;

endmodule
