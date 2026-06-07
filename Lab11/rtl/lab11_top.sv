// Lab 11 FPGA top level.
//
// Wires the 3-stage pipelined processor (running the insertion-sort
// program) to the eight-digit seven-segment display. After the processor
// finishes sorting, the four array words sit in data memory; their low
// nibbles are driven onto the four right-most displays so the sorted
// array (3 5 7 9 for the default input 9 3 7 5) is shown on the board.
//
// Parameters let simulation override the file paths and speed up the
// display refresh; the synthesis defaults match the lab board.
module lab11_top #(
    parameter IMEM_FILE = "imem.hex",
    parameter DMEM_FILE = "dmem.hex",
    parameter ARR_BASE  = 12'h000,
    parameter DISP_TAP  = 17
)(
    input  logic clk,
    input  logic reset,
    output logic an0, an1, an2, an3, an4, an5, an6, an7,
    output logic segA, segB, segC, segD, segE, segF, segG
);

    logic [31:0] arr0, arr1, arr2, arr3;

    cpu #(
        .IMEM_FILE (IMEM_FILE),
        .DMEM_FILE (DMEM_FILE),
        .ARR_BASE  (ARR_BASE)
    ) CPU (
        .clk       (clk),
        .rst       (reset),
        .arr_word0 (arr0),
        .arr_word1 (arr1),
        .arr_word2 (arr2),
        .arr_word3 (arr3)
    );

    // Map the four sorted values (low nibble of each word) to the four
    // right-most digits; blank the remaining displays with 0.
    logic [3:0] num [7:0];
    always_comb begin
        num[0] = arr0[3:0];
        num[1] = arr1[3:0];
        num[2] = arr2[3:0];
        num[3] = arr3[3:0];
        num[4] = 4'd0;
        num[5] = 4'd0;
        num[6] = 4'd0;
        num[7] = 4'd0;
    end

    seven_seg_display #(.TAP(DISP_TAP)) DISPLAY (
        .num   (num),
        .reset (reset),
        .clk   (clk),
        .an0   (an0), .an1 (an1), .an2 (an2), .an3 (an3),
        .an4   (an4), .an5 (an5), .an6 (an6), .an7 (an7),
        .segA  (segA), .segB (segB), .segC (segC), .segD (segD),
        .segE  (segE), .segF (segF), .segG (segG)
    );

endmodule
