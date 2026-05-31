`timescale 1ns/1ps
`include "opcode.vh"

module imm_gen_tb;

    logic [31:0] instr_word;
    logic [31:0] imm_out;

    imm_gen dut (.instr_word(instr_word), .imm_out(imm_out));

    int pass_count = 0;
    int fail_count = 0;

    task check(input string name, input logic [31:0] expected);
        if (imm_out !== expected) begin
            $display("[FAIL] %s: expected %h, got %h (instr=%h)", name, expected, imm_out, instr_word);
            fail_count++;
        end else begin
            $display("[PASS] %s -> %h", name, imm_out);
            pass_count++;
        end
    endtask

    initial begin
        logic [11:0] imm12;
        logic [31:0] b_off, j_off, u_val;

        // I-type ADDI (negative immediate)
        imm12 = 12'hFF8;
        instr_word = {imm12, 5'd1, `FNC_ADD_SUB, 5'd2, `OPC_ARI_ITYPE};
        #1; check("I-type ADDI", {{20{imm12[11]}}, imm12});

        // I-type LW
        imm12 = 12'h004;
        instr_word = {imm12, 5'd3, `FNC_LW, 5'd4, `OPC_LOAD};
        #1; check("I-type LW", {{20{imm12[11]}}, imm12});

        // S-type SW
        imm12 = 12'h1AC;
        instr_word = {imm12[11:5], 5'd1, 5'd2, `FNC_SW, imm12[4:0], `OPC_STORE};
        #1; check("S-type SW", {{20{imm12[11]}}, imm12[11:5], imm12[4:0]});

        // B-type BEQ — encode from 32-bit byte offset (must be even)
        b_off = 32'h0000_0020;
        instr_word = {b_off[12], b_off[10:5], 5'd2, 5'd1, `FNC_BEQ, b_off[4:1], b_off[11], `OPC_BRANCH};
        #1; check("B-type BEQ", b_off);

        // U-type LUI
        u_val = 32'h7ABCD000;
        instr_word = {u_val[31:12], 5'd5, `OPC_LUI};
        #1; check("U-type LUI", u_val);

        // U-type AUIPC
        u_val = 32'h12345000;
        instr_word = {u_val[31:12], 5'd6, `OPC_AUIPC};
        #1; check("U-type AUIPC", u_val);

        // J-type JAL
        j_off = 32'h0000_0FF0;
        instr_word = {j_off[20], j_off[10:1], j_off[11], j_off[19:12], 5'd7, `OPC_JAL};
        #1; check("J-type JAL", j_off);

        // JALR (I-type immediate)
        imm12 = 12'h008;
        instr_word = {imm12, 5'd1, 3'b000, 5'd8, `OPC_JALR};
        #1; check("JALR", {{20{imm12[11]}}, imm12});

        // Randomized tests — build instruction from known expected immediate
        repeat (40) begin
            logic [31:0] exp;
            int fmt = $urandom_range(0, 4);
            case (fmt)
                0: begin
                    imm12 = $urandom();
                    exp = {{20{imm12[11]}}, imm12};
                    instr_word = {imm12, 5'd0, `FNC_ADD_SUB, 5'd0, `OPC_ARI_ITYPE};
                end
                1: begin
                    imm12 = $urandom();
                    exp = {{20{imm12[11]}}, imm12[11:5], imm12[4:0]};
                    instr_word = {imm12[11:5], 5'd0, 5'd0, `FNC_SW, imm12[4:0], `OPC_STORE};
                end
                2: begin
                    b_off = {$urandom(), 1'b0};
                    exp = {{19{b_off[12]}}, b_off[12], b_off[11], b_off[10:5], b_off[4:1], 1'b0};
                    instr_word = {b_off[12], b_off[10:5], 5'd0, 5'd0, `FNC_BEQ, b_off[4:1], b_off[11], `OPC_BRANCH};
                end
                3: begin
                    u_val = {$urandom(), 12'b0};
                    exp = u_val;
                    instr_word = {u_val[31:12], 5'd0, `OPC_LUI};
                end
                default: begin
                    j_off = {$urandom(), 1'b0};
                    exp = {{11{j_off[20]}}, j_off[20], j_off[19:12], j_off[11], j_off[10:1], 1'b0};
                    instr_word = {j_off[20], j_off[10:1], j_off[11], j_off[19:12], 5'd0, `OPC_JAL};
                end
            endcase
            #1;
            if (imm_out !== exp) fail_count++; else pass_count++;
        end

        $display("\nImmGen TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "Immediate generator tests failed");
        $finish;
    end

endmodule
