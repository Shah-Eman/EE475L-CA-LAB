module data_mem (
    input  logic        clk,
    input  logic        wr_en,
    input  logic [31:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data
);

    logic [31:0] memory [512];

    initial begin
        for (int i = 0; i < 512; i++)
            memory[i] = '0;
    end

    always_ff @(posedge clk) begin
        if (wr_en)
            memory[addr[11:0]] <= wr_data;
    end

    assign rd_data = memory[addr[11:0]];

endmodule
