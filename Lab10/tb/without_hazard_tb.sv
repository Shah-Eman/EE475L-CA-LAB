`timescale 1ns/1ns

`include "opcode.vh"

`define REGFILE_PATH cpu.ID_EX.Reg_file
`define DMEM_PATH    cpu.MEM_WB.Data_Mem
`define IMEM_PATH    cpu.IF_STAGE.Inst_Mem

// Program (no data hazard that needs a stall; only forwarding):
//   addi x1, x0, 3
//   addi x2, x0, 5
//   addi x3, x0, 6
//   sw   x1, 0x10(x0)
//   add  x4, x1, x2
//   and  x6, x2, x3
//   lw   x8, 0x10(x0)
module cpu_tb();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    integer i;
    integer errors = 0;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

    cpu cpu ( .clk (clk), .rst (rst) );

    task check_rf;
        input [4:0]  rd;
        input [31:0] expected;
        input [127:0] name;
        begin
            if (`REGFILE_PATH.Registers[rd] === expected)
                $display("  [PASS] %0s : x%0d = %0d (0x%h)", name, rd,
                         `REGFILE_PATH.Registers[rd], `REGFILE_PATH.Registers[rd]);
            else begin
                $display("  [FAIL] %0s : x%0d = 0x%h, expected 0x%h", name, rd,
                         `REGFILE_PATH.Registers[rd], expected);
                errors = errors + 1;
            end
        end
    endtask

    task check_mem;
        input [31:0] addr;
        input [31:0] expected;
        input [127:0] name;
        begin
            if (`DMEM_PATH.memory[addr[11:0]] === expected)
                $display("  [PASS] %0s : mem[0x%h] = 0x%h", name, addr,
                         `DMEM_PATH.memory[addr[11:0]]);
            else begin
                $display("  [FAIL] %0s : mem[0x%h] = 0x%h, expected 0x%h", name, addr,
                         `DMEM_PATH.memory[addr[11:0]], expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        rst = 1;
        for (i = 0; i < 32;   i = i + 1) `REGFILE_PATH.Registers[i] = 0;
        for (i = 0; i < 512;  i = i + 1) `DMEM_PATH.memory[i]       = 0;
        for (i = 0; i < 1024; i = i + 1) `IMEM_PATH.memory[i]       = 0;

        // addi x1, x0, 3
        `IMEM_PATH.memory[0] = {12'd3, 5'd0, `FNC_ADD_SUB, 5'd1, `OPC_ARI_ITYPE};
        // addi x2, x0, 5
        `IMEM_PATH.memory[1] = {12'd5, 5'd0, `FNC_ADD_SUB, 5'd2, `OPC_ARI_ITYPE};
        // addi x3, x0, 6
        `IMEM_PATH.memory[2] = {12'd6, 5'd0, `FNC_ADD_SUB, 5'd3, `OPC_ARI_ITYPE};
        // sw x1, 0x10(x0)   imm=0x10 -> imm[11:5]=0, imm[4:0]=5'b10000
        `IMEM_PATH.memory[3] = {7'b0000000, 5'd1, 5'd0, `FNC_SW, 5'b10000, `OPC_STORE};
        // add x4, x1, x2
        `IMEM_PATH.memory[4] = {7'd0, 5'd2, 5'd1, `FNC_ADD_SUB, 5'd4, `OPC_ARI_RTYPE};
        // and x6, x2, x3
        `IMEM_PATH.memory[5] = {7'd0, 5'd3, 5'd2, `FNC_AND, 5'd6, `OPC_ARI_RTYPE};
        // lw x8, 0x10(x0)
        `IMEM_PATH.memory[6] = {12'h010, 5'd0, `FNC_LW, 5'd8, `OPC_LOAD};

        // Release reset
        repeat (2) @(posedge clk);
        rst = 0;

        // Run enough cycles to drain the pipeline
        repeat (40) @(posedge clk);

        $display("==== without_hazard results ====");
        check_rf(1,  32'd3,  "addi x1");
        check_rf(2,  32'd5,  "addi x2");
        check_rf(3,  32'd6,  "addi x3");
        check_rf(4,  32'd8,  "add  x4 = x1+x2");
        check_rf(6,  32'd4,  "and  x6 = x2&x3");
        check_rf(8,  32'd3,  "lw   x8 = mem[0x10]");
        check_mem(32'h10, 32'd3, "sw   mem[0x10]");

        if (errors == 0)
            $display("RESULT: without_hazard PASSED (all checks ok)");
        else
            $display("RESULT: without_hazard FAILED (%0d errors)", errors);
        $finish();
    end
endmodule
