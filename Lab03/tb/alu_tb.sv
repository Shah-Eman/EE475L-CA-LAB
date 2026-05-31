`timescale 1ns/1ps
`include "opcode.vh"
`include "alu_ops.vh"

module alu_tb;

    logic [31:0] src_a, src_b;
    logic [3:0]  op_sel;
    logic [31:0] out;
    logic        zero_flag;

    alu dut (.src_a(src_a), .src_b(src_b), .op_sel(op_sel), .out(out), .zero_flag(zero_flag));

    int pass_count = 0;
    int fail_count = 0;

    task check(input string name, input logic [31:0] expected);
        if (out !== expected) begin
            $display("[FAIL] %s: expected %h, got %h", name, expected, out);
            fail_count++;
        end else begin
            $display("[PASS] %s", name);
            pass_count++;
        end
    endtask

    initial begin
        // Fixed directed tests
        src_a = 32'd100; src_b = 32'd200;
        op_sel = `ALU_ADD; #1; check("ADD", 32'd300);
        op_sel = `ALU_SUB; #1; check("SUB", 32'hFFFFFF9C);

        src_a = 32'hF0F0_0000; src_b = 32'h0F0F_FFFF;
        op_sel = `ALU_AND; #1; check("AND", 32'h0000_0000);
        op_sel = `ALU_OR;  #1; check("OR",  32'hFFFF_FFFF);
        op_sel = `ALU_XOR; #1; check("XOR", 32'hFFFF_FFFF);

        src_a = 32'd1; src_b = 32'd2;
        op_sel = `ALU_SLT;  #1; check("SLT",  32'd1);
        op_sel = `ALU_SLTU; #1; check("SLTU", 32'd1);

        src_a = 32'h8000_0000; src_b = 32'd1;
        op_sel = `ALU_SLL; #1; check("SLL", 32'd0);
        op_sel = `ALU_SRL; #1; check("SRL", 32'h4000_0000);
        op_sel = `ALU_SRA; #1; check("SRA", 32'hC000_0000);

        src_a = 32'd50; src_b = 32'd50;
        op_sel = `ALU_SUB; #1;
        if (zero_flag !== 1'b1) begin
            $display("[FAIL] zero_flag not set on equal operands");
            fail_count++;
        end else begin
            $display("[PASS] zero_flag");
            pass_count++;
        end

        // Randomized smoke tests
        repeat (50) begin
            src_a  = $urandom();
            src_b  = $urandom();
            op_sel = 4'($urandom_range(0, 10));
            #1;
            unique case (op_sel)
                `ALU_AND: check("RAND AND", src_a & src_b);
                `ALU_OR:  check("RAND OR",  src_a | src_b);
                `ALU_ADD: check("RAND ADD", src_a + src_b);
                `ALU_XOR: check("RAND XOR", src_a ^ src_b);
                `ALU_SUB: check("RAND SUB", src_a - src_b);
                `ALU_SLT: check("RAND SLT", ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0);
                `ALU_SLTU: check("RAND SLTU", (src_a < src_b) ? 32'd1 : 32'd0);
                `ALU_SLL: check("RAND SLL", src_a << src_b[4:0]);
                `ALU_SRL: check("RAND SRL", src_a >> src_b[4:0]);
                `ALU_SRA: check("RAND SRA", $signed(src_a) >>> src_b[4:0]);
                default: ;
            endcase
        end

        $display("\nALU TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "ALU tests failed");
        $finish;
    end

endmodule
