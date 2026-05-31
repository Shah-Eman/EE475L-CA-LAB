`timescale 1ns/1ps
`include "opcode.vh"
`include "alu_ops.vh"

module alu_controller_tb;

    logic [1:0] alu_op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_ctrl;

    alu_controller dut (.alu_op(alu_op), .funct3(funct3), .funct7(funct7), .alu_ctrl(alu_ctrl));

    typedef struct {
        logic [1:0] op;
        logic [2:0] f3;
        logic [6:0] f7;
        logic [3:0] exp;
        string      name;
    } test_case_t;

    test_case_t cases[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        cases.push_back('{2'b00, 3'b010, `FNC7_0, `ALU_ADD, "mem"});
        cases.push_back('{2'b01, `FNC_BEQ, `FNC7_0, `ALU_SUB, "beq"});
        cases.push_back('{2'b01, `FNC_BNE, `FNC7_0, `ALU_SUB, "bne"});
        cases.push_back('{2'b01, `FNC_BLT, `FNC7_0, `ALU_SLT, "blt"});
        cases.push_back('{2'b10, `FNC_ADD_SUB, `FNC7_0, `ALU_ADD, "add"});
        cases.push_back('{2'b10, `FNC_ADD_SUB, `FNC7_1, `ALU_SUB, "sub"});
        cases.push_back('{2'b10, `FNC_AND, `FNC7_0, `ALU_AND, "and"});
        cases.push_back('{2'b11, `FNC_ADD_SUB, `FNC7_0, `ALU_ADD, "addi"});
        cases.push_back('{2'b11, `FNC_SRL_SRA, `FNC7_0, `ALU_SRL, "srli"});
        cases.push_back('{2'b11, `FNC_SRL_SRA, `FNC7_1, `ALU_SRA, "srai"});

        foreach (cases[i]) begin
            alu_op = cases[i].op;
            funct3 = cases[i].f3;
            funct7 = cases[i].f7;
            #1;
            if (alu_ctrl !== cases[i].exp) begin
                $display("[FAIL] %s", cases[i].name);
                fail_count++;
            end else begin
                $display("[PASS] %s", cases[i].name);
                pass_count++;
            end
        end

        repeat (50) begin
            alu_op = $urandom_range(0, 3);
            funct3 = $urandom();
            funct7 = $urandom() ? `FNC7_1 : `FNC7_0;
            #1;
            if (^alu_ctrl === 1'bx) fail_count++; else pass_count++;
        end

        $display("\nLab4 ALU Controller TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "ALU controller tests failed");
        $finish;
    end

endmodule
