// Lab 11 data memory.
// Byte-address indexed (memory[addr[11:0]]), so the four-element array
// lives at byte addresses 0x0, 0x4, 0x8, 0xC. When INIT_FILE is set the
// unsorted array is preloaded with $readmemh (@<byte-addr> records),
// which also initialises the block RAM on the FPGA.
//
// The dbg_word* outputs continuously expose the four array words so the
// top level can drive the seven-segment displays without disturbing the
// processor's normal load/store port.
module data_mem #(
    parameter INIT_FILE  = "",
    parameter ARR_BASE   = 12'h000          // byte address of arr[0]
)(
    input  logic        clk,
    input  logic        wr_en,
    input  logic [31:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    output logic [31:0] dbg_word0,
    output logic [31:0] dbg_word1,
    output logic [31:0] dbg_word2,
    output logic [31:0] dbg_word3
);

    logic [31:0] memory [512];

    initial begin
        for (int i = 0; i < 512; i++)
            memory[i] = '0;
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, memory);
    end

    always @(posedge clk) begin
        if (wr_en)
            memory[addr[11:0]] <= wr_data;
    end

    assign rd_data   = memory[addr[11:0]];

    assign dbg_word0 = memory[ARR_BASE + 12'd0];
    assign dbg_word1 = memory[ARR_BASE + 12'd4];
    assign dbg_word2 = memory[ARR_BASE + 12'd8];
    assign dbg_word3 = memory[ARR_BASE + 12'd12];

endmodule
