module reg_file #(
    parameter DW = 32,
    parameter AW = 5
)(
    input  logic            clk,
    input  logic            wr_en,
    input  logic [AW-1:0]   rs1,
    input  logic [AW-1:0]   rs2,
    input  logic [AW-1:0]   rd,
    input  logic [DW-1:0]   wr_data,
    output logic [DW-1:0]   rd_data1,
    output logic [DW-1:0]   rd_data2
);

    logic [DW-1:0] Registers [31:0];

    initial begin
        for (int i = 0; i < 32; i++)
            Registers[i] = '0;
    end

    always_ff @(posedge clk) begin
        if (wr_en && (rd != 5'd0))
            Registers[rd] <= wr_data;
    end

    assign rd_data1 = (rs1 != 5'd0) ? Registers[rs1] : {DW{1'b0}};
    assign rd_data2 = (rs2 != 5'd0) ? Registers[rs2] : {DW{1'b0}};

endmodule
