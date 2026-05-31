`timescale 1ns/1ps
`include "opcode.vh"
`include "alu_ops.vh"

module alu_controller_tb;

    logic [1:0] alu_op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_ctrl;

    alu_controller dut (.alu_op(alu_op), .funct3(funct3), .funct7(funct7), .alu_ctrl(alu_ctrl));

    int pass_count = 0;
    int fail_count = 0;

    task check_expect(input string name, input logic [3:0] exp);
        if (alu_ctrl !== exp) begin
            $display("[FAIL] %s: expected %b, got %b", name, exp, alu_ctrl);
            fail_count++;
        end else begin
            $display("[PASS] %s", name);
            pass_count++;
        end
    endtask

    initial begin
        alu_op = 2'b00; funct3 = 3'b010; funct7 = `FNC7_0; #1;
        check_expect("LOAD/STORE ADD", `ALU_ADD);

        alu_op = 2'b01; funct3 = `FNC_BEQ; #1;
        check_expect("BEQ SUB", `ALU_SUB);
        alu_op = 2'b01; funct3 = `FNC_BLT; #1;
        check_expect("BLT SLT", `ALU_SLT);
        alu_op = 2'b01; funct3 = `FNC_BLTU; #1;
        check_expect("BLTU SLTU", `ALU_SLTU);

        alu_op = 2'b10;
        funct3 = `FNC_ADD_SUB; funct7 = `FNC7_0; #1; check_expect("R ADD", `ALU_ADD);
        funct3 = `FNC_ADD_SUB; funct7 = `FNC7_1; #1; check_expect("R SUB", `ALU_SUB);
        funct3 = `FNC_AND;     funct7 = `FNC7_0; #1; check_expect("R AND", `ALU_AND);
        funct3 = `FNC_OR;      funct7 = `FNC7_0; #1; check_expect("R OR",  `ALU_OR);
        funct3 = `FNC_XOR;     funct7 = `FNC7_0; #1; check_expect("R XOR", `ALU_XOR);
        funct3 = `FNC_SLL;     funct7 = `FNC7_0; #1; check_expect("R SLL", `ALU_SLL);
        funct3 = `FNC_SRL_SRA; funct7 = `FNC7_0; #1; check_expect("R SRL", `ALU_SRL);
        funct3 = `FNC_SRL_SRA; funct7 = `FNC7_1; #1; check_expect("R SRA", `ALU_SRA);
        funct3 = `FNC_SLT;     funct7 = `FNC7_0; #1; check_expect("R SLT", `ALU_SLT);
        funct3 = `FNC_SLTU;    funct7 = `FNC7_0; #1; check_expect("R SLTU", `ALU_SLTU);

        alu_op = 2'b11;
        funct3 = `FNC_ADD_SUB; #1; check_expect("I ADDI", `ALU_ADD);
        funct3 = `FNC_XOR;     #1; check_expect("I XORI",  `ALU_XOR);
        funct3 = `FNC_SLL;     funct7 = `FNC7_0; #1; check_expect("I SLLI", `ALU_SLL);
        funct3 = `FNC_SRL_SRA; funct7 = `FNC7_1; #1; check_expect("I SRAI", `ALU_SRA);

        repeat (30) begin
            alu_op = $urandom_range(0, 3);
            funct3 = $urandom();
            funct7 = $urandom() ? `FNC7_1 : `FNC7_0;
            #1;
            if (^alu_ctrl === 1'bx) begin
                $display("[FAIL] X on alu_ctrl");
                fail_count++;
            end else
                pass_count++;
        end

        $display("\nALU Controller TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "ALU controller tests failed");
        $finish;
    end

endmodule
