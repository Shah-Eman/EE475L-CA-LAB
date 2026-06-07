`timescale 1ns/1ns

// Lab 11 - top-level integration test.
//
// Runs the full FPGA top (processor + seven-segment driver) with a small
// display-divider tap (DISP_TAP = 1) so the digit multiplexer cycles
// quickly in simulation. After the sort completes, the test walks one full
// refresh cycle and verifies that, while each anode is active, the segment
// bus shows the correct digit:
//
//   display 0 -> 3, display 1 -> 5, display 2 -> 7, display 3 -> 9,
//   displays 4..7 -> 0 (blank value).
module lab11_top_tb;

    logic clk, reset;
    parameter CLK_PERIOD = 20;

    logic an0, an1, an2, an3, an4, an5, an6, an7;
    logic segA, segB, segC, segD, segE, segF, segG;

    integer errors = 0;
    integer seen [0:7];

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    lab11_top #(
        .IMEM_FILE ("program/imem.hex"),
        .DMEM_FILE ("program/dmem.hex"),
        .ARR_BASE  (12'h000),
        .DISP_TAP  (1)
    ) dut (
        .clk   (clk),
        .reset (reset),
        .an0 (an0), .an1 (an1), .an2 (an2), .an3 (an3),
        .an4 (an4), .an5 (an5), .an6 (an6), .an7 (an7),
        .segA (segA), .segB (segB), .segC (segC), .segD (segD),
        .segE (segE), .segF (segF), .segG (segG)
    );

    // Reference seven-segment encoder (must match seven_seg_display).
    function [6:0] seg_of;
        input [3:0] v;
        begin
            case (v)
                4'h0: seg_of = 7'b000_0001;
                4'h1: seg_of = 7'b100_1111;
                4'h2: seg_of = 7'b001_0010;
                4'h3: seg_of = 7'b000_0110;
                4'h4: seg_of = 7'b100_1100;
                4'h5: seg_of = 7'b010_0100;
                4'h6: seg_of = 7'b010_0000;
                4'h7: seg_of = 7'b000_1111;
                4'h8: seg_of = 7'b000_0000;
                4'h9: seg_of = 7'b000_0100;
                default: seg_of = 7'b000_0001;
            endcase
        end
    endfunction

    logic [6:0] segs;
    assign segs = {segA, segB, segC, segD, segE, segF, segG};

    // Expected digit value for each physical display position.
    logic [3:0] expected [0:7];

    task check_digit;
        input integer pos;
        input         active;     // anode is active-low
        begin
            if (active == 1'b0) begin
                seen[pos] = seen[pos] + 1;
                if (segs !== seg_of(expected[pos])) begin
                    $display("  [FAIL] display %0d: segs=%b, expected %b (digit %0d)",
                             pos, segs, seg_of(expected[pos]), expected[pos]);
                    errors = errors + 1;
                end
            end
        end
    endtask

    integer i;
    initial begin
        expected[0] = 4'd3; expected[1] = 4'd5; expected[2] = 4'd7;
        expected[3] = 4'd9; expected[4] = 4'd0; expected[5] = 4'd0;
        expected[6] = 4'd0; expected[7] = 4'd0;
        for (i = 0; i < 8; i = i + 1) seen[i] = 0;

        reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // Let the processor finish sorting.
        repeat (300) @(posedge clk);

        // Walk several full refresh cycles and check every digit slot.
        repeat (400) begin
            @(posedge clk);
            check_digit(0, an0);
            check_digit(1, an1);
            check_digit(2, an2);
            check_digit(3, an3);
            check_digit(4, an4);
            check_digit(5, an5);
            check_digit(6, an6);
            check_digit(7, an7);
        end

        $display("==== lab11_top display results ====");
        for (i = 0; i < 8; i = i + 1) begin
            if (seen[i] == 0) begin
                $display("  [FAIL] display %0d never driven", i);
                errors = errors + 1;
            end else
                $display("  display %0d shows digit %0d (%0d samples)",
                         i, expected[i], seen[i]);
        end

        if (errors == 0)
            $display("RESULT: lab11_top PASSED (displays show sorted array 3 5 7 9)");
        else
            $display("RESULT: lab11_top FAILED (%0d errors)", errors);
        $finish;
    end

endmodule
