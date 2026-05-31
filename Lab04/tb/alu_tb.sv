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

    function automatic logic [31:0] golden(input logic [3:0] op, input logic [31:0] a, input logic [31:0] b);
        case (op)
            `ALU_AND:  return a & b;
            `ALU_OR:   return a | b;
            `ALU_ADD:  return a + b;
            `ALU_XOR:  return a ^ b;
            `ALU_SUB:  return a - b;
            `ALU_SLT:  return ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: return (a < b) ? 32'd1 : 32'd0;
            `ALU_SLL:  return a << b[4:0];
            `ALU_SRL:  return a >> b[4:0];
            `ALU_SRA:  return $signed(a) >>> b[4:0];
            default:   return 32'd0;
        endcase
    endfunction

    initial begin
        repeat (100) begin
            src_a  = $urandom();
            src_b  = $urandom();
            op_sel = 4'($urandom_range(0, 10));
            #1;
            if (out !== golden(op_sel, src_a, src_b)) begin
                $display("[FAIL] op=%b a=%h b=%h exp=%h got=%h", op_sel, src_a, src_b,
                         golden(op_sel, src_a, src_b), out);
                fail_count++;
            end else
                pass_count++;
        end

        src_a = 32'd42; src_b = 32'd42; op_sel = `ALU_SUB; #1;
        if (zero_flag !== 1'b1) fail_count++; else pass_count++;

        $display("\nLab4 ALU TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "ALU tests failed");
        $finish;
    end

endmodule
