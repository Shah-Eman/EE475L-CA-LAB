`timescale 1ns/1ns

// Lab 11 - functional verification of the insertion-sort program running
// on the 3-stage pipelined processor.
//
// The processor is built with its memories pre-loaded from the assembled
// hex files (program/imem.hex, program/dmem.hex). After enough cycles for
// the sort to finish, the four array words (exposed on the cpu debug
// outputs and read back from data memory) must be in ascending order.
module insertion_sort_tb;

    logic clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;

    logic [31:0] arr0, arr1, arr2, arr3;
    integer errors = 0;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

    cpu #(
        .IMEM_FILE ("program/imem.hex"),
        .DMEM_FILE ("program/dmem.hex"),
        .ARR_BASE  (12'h000)
    ) cpu (
        .clk       (clk),
        .rst       (rst),
        .arr_word0 (arr0),
        .arr_word1 (arr1),
        .arr_word2 (arr2),
        .arr_word3 (arr3)
    );

    task check;
        input [31:0] got;
        input [31:0] exp;
        input [127:0] name;
        begin
            if (got === exp)
                $display("  [PASS] %0s = %0d", name, got);
            else begin
                $display("  [FAIL] %0s = %0d, expected %0d", name, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        rst = 1;
        repeat (3) @(posedge clk);
        rst = 0;

        $display("Initial array : [%0d, %0d, %0d, %0d]", arr0, arr1, arr2, arr3);

        // Run long enough for the sort + pipeline drain to complete.
        repeat (300) @(posedge clk);

        $display("==== insertion_sort results ====");
        $display("Sorted array  : [%0d, %0d, %0d, %0d]", arr0, arr1, arr2, arr3);

        check(arr0, 32'd3, "arr[0]");
        check(arr1, 32'd5, "arr[1]");
        check(arr2, 32'd7, "arr[2]");
        check(arr3, 32'd9, "arr[3]");

        // Cross-check the raw data-memory words too.
        check(cpu.MEM_WB.Data_Mem.memory[0],  32'd3, "mem[0x0]");
        check(cpu.MEM_WB.Data_Mem.memory[4],  32'd5, "mem[0x4]");
        check(cpu.MEM_WB.Data_Mem.memory[8],  32'd7, "mem[0x8]");
        check(cpu.MEM_WB.Data_Mem.memory[12], 32'd9, "mem[0xC]");

        if (errors == 0)
            $display("RESULT: insertion_sort PASSED (array sorted ascending)");
        else
            $display("RESULT: insertion_sort FAILED (%0d errors)", errors);
        $finish;
    end

endmodule
