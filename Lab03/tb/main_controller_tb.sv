`timescale 1ns/1ps
`include "opcode.vh"

module main_controller_tb;

    logic [6:0] opcode;
    logic [1:0] alu_op;

    main_controller dut (.opcode(opcode), .alu_op(alu_op));

    int pass_count = 0;
    int fail_count = 0;

    task check_expect(input string name, input logic [1:0] exp);
        if (alu_op !== exp) begin
            $display("[FAIL] %s: expected %b, got %b", name, exp, alu_op);
            fail_count++;
        end else begin
            $display("[PASS] %s", name);
            pass_count++;
        end
    endtask

    initial begin
        opcode = `OPC_ARI_RTYPE; #1; check_expect("R-type", 2'b10);
        opcode = `OPC_ARI_ITYPE; #1; check_expect("I-type arith", 2'b11);
        opcode = `OPC_JALR;      #1; check_expect("JALR", 2'b11);
        opcode = `OPC_LOAD;      #1; check_expect("LOAD", 2'b00);
        opcode = `OPC_STORE;     #1; check_expect("STORE", 2'b00);
        opcode = `OPC_BRANCH;    #1; check_expect("BRANCH", 2'b01);
        opcode = `OPC_LUI;       #1; check_expect("LUI default", 2'b00);
        opcode = `OPC_JAL;       #1; check_expect("JAL default", 2'b00);

        repeat (20) begin
            opcode = $urandom();
            #1;
            if (^alu_op === 1'bx) begin
                $display("[FAIL] X on alu_op for opcode=%b", opcode);
                fail_count++;
            end else
                pass_count++;
        end

        $display("\nMain Controller TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "Main controller tests failed");
        $finish;
    end

endmodule
