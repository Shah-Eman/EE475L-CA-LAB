// Lab 11 instruction memory.
// Word indexed (memory[addr[11:2]]). When INIT_FILE is non-empty the
// memory is preloaded with the insertion-sort program via $readmemh,
// which also initialises the block RAM on the FPGA.
module instr_mem #(
    parameter INIT_FILE = ""
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] memory [1024];

    initial begin
        for (int i = 0; i < 1024; i++)
            memory[i] = 32'h0000_0013;          // NOP (addi x0,x0,0)
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, memory);
    end

    assign instr = memory[addr[11:2]];

endmodule
