module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] memory [1024];

    assign instr = memory[addr[11:2]];

endmodule
