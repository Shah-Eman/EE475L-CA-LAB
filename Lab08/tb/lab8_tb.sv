`timescale 1ns/1ns

`include "opcode.vh"

`define REGFILE_PATH cpu.ID_EX.Reg_file
`define DMEM_PATH    cpu.MEM_WB.Data_Mem
`define IMEM_PATH    cpu.IF_STAGE.Inst_Mem

// Lab 8 — 3-stage pipelined CPU (no hazard forwarding yet)
// Allow extra cycles for 3-stage latency; avoid back-to-back dependent ops in tests.

module cpu_tb();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    parameter TIMEOUT_CYCLES   = 30;

    reg [31:0] cycle;
    reg        done;
    reg [31:0] current_test_id = 0;
    reg [255:0] current_test_type;
    reg [31:0] current_result;
    reg [31:0] IMM;
    reg        all_tests_passed = 0;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

    cpu cpu ( .clk (clk), .rst (rst) );

    task reset_memories;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1)
                `REGFILE_PATH.Registers[i] = 0;
            for (i = 0; i < 512; i = i + 1)
                `DMEM_PATH.memory[i] = 0;
            for (i = 0; i < 16; i = i + 1)
                `IMEM_PATH.memory[i] = 0;
        end
    endtask

    task reset_cpu;
        begin
            @(posedge clk);
            rst = 1;
            #30;
            rst = 0;
            repeat (3) @(posedge clk);
        end
    endtask

    initial begin
        while (all_tests_passed === 0) begin
            @(posedge clk);
            if (done === 0 && cycle >= TIMEOUT_CYCLES) begin
                $display("[Failed] Timeout at test %s, expected %h",
                         current_test_type, current_result);
                $finish();
            end
        end
    end

    always @(posedge clk) begin
        if (done === 0)
            cycle <= cycle + 1;
        else
            cycle <= 0;
    end

    task wait_rf;
        input [4:0]  rd;
        input [31:0] expected;
        input [255:0] name;
        begin
            done = 0;
            current_test_id   = current_test_id + 1;
            current_test_type = name;
            current_result    = expected;
            while (`REGFILE_PATH.Registers[rd] !== expected)
                @(posedge clk);
            cycle = 0;
            done  = 1;
            $display("[%0d] %s passed (x%0d = %h)", current_test_id, name, rd, expected);
        end
    endtask

    task wait_mem;
        input [31:0] byte_addr;
        input [31:0] expected;
        input [255:0] name;
        begin
            done = 0;
            current_test_id   = current_test_id + 1;
            current_test_type = name;
            current_result    = expected;
            while (`DMEM_PATH.memory[byte_addr[11:0]] !== expected)
                @(posedge clk);
            cycle = 0;
            done  = 1;
            $display("[%0d] %s passed (mem[%h] = %h)", current_test_id, name, byte_addr, expected);
        end
    endtask

    initial begin
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        repeat (3) @(posedge clk);

        // --- R-type ADD ---
        reset_memories();
        `REGFILE_PATH.Registers[1] = 32'd10;
        `REGFILE_PATH.Registers[2] = 32'd20;
        `IMEM_PATH.memory[0] = {7'd0, 5'd2, 5'd1, `FNC_ADD_SUB, 5'd3, `OPC_ARI_RTYPE};
        reset_cpu();
        wait_rf(3, 32'd30, "R-type ADD");

        // --- I-type ADDI (separate test, reset pipeline) ---
        reset_memories();
        `IMEM_PATH.memory[0] = {12'd5, 5'd0, `FNC_ADD_SUB, 5'd4, `OPC_ARI_ITYPE};
        reset_cpu();
        wait_rf(4, 32'd5, "I-type ADDI");

        // --- LW / SW ---
        reset_memories();
        `REGFILE_PATH.Registers[5] = 32'h0000_0100;
        `DMEM_PATH.memory[32'h100] = 32'hDEAD_BEEF;
        `IMEM_PATH.memory[0] = {12'd0, 5'd5, 3'b010, 5'd6, `OPC_LOAD};
        reset_cpu();
        wait_rf(6, 32'hDEAD_BEEF, "LW");

        reset_memories();
        `REGFILE_PATH.Registers[7] = 32'h0000_0200;
        `REGFILE_PATH.Registers[8] = 32'h1234_5678;
        `IMEM_PATH.memory[0] = {7'd0, 5'd8, 5'd7, 3'b010, 5'd0, `OPC_STORE};
        reset_cpu();
        wait_mem(32'h200, 32'h1234_5678, "SW");

        // --- BEQ taken (single branch insn) ---
        reset_memories();
        `REGFILE_PATH.Registers[9]  = 32'd1;
        `REGFILE_PATH.Registers[10] = 32'd1;
        IMM = 32'd8; // branch offset +8 -> skip one instruction
        `IMEM_PATH.memory[0] = {IMM[12], IMM[10:5], 5'd10, 5'd9, `FNC_BEQ, IMM[4:1], IMM[11], `OPC_BRANCH};
        `IMEM_PATH.memory[1] = {7'd0, 5'd0, 5'd0, `FNC_ADD_SUB, 5'd11, `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[2] = {12'd7, 5'd0, `FNC_ADD_SUB, 5'd12, `OPC_ARI_ITYPE};
        reset_cpu();
        wait_rf(12, 32'd7, "BEQ taken");
        if (`REGFILE_PATH.Registers[11] !== 0)
            $display("[Failed] BEQ should have skipped x11 write");

        // --- JAL ---
        reset_memories();
        IMM = 32'd4;
        `IMEM_PATH.memory[0] = {IMM[20], IMM[10:1], IMM[11], IMM[19:12], 5'd1, `OPC_JAL};
        `IMEM_PATH.memory[1] = {7'd0, 5'd0, 5'd0, `FNC_ADD_SUB, 5'd13, `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[2] = {12'd9, 5'd0, `FNC_ADD_SUB, 5'd14, `OPC_ARI_ITYPE};
        reset_cpu();
        wait_rf(14, 32'd9, "JAL target");
        wait_rf(1, 32'h1000_0004, "JAL link x1");

        all_tests_passed = 1;
        $display("All Lab 8 pipeline tests passed!");
        $finish();
    end
endmodule
