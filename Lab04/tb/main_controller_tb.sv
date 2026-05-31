`timescale 1ns/1ps
`include "opcode.vh"

module main_controller_tb;

    logic [6:0] opcode;
    logic [1:0] alu_op;

    main_controller dut (.opcode(opcode), .alu_op(alu_op));

    int pass_count = 0;
    int fail_count = 0;

    function automatic logic [1:0] expected_aluop(input logic [6:0] opc);
        case (opc)
            `OPC_ARI_RTYPE: return 2'b10;
            `OPC_ARI_ITYPE,
            `OPC_JALR:      return 2'b11;
            `OPC_LOAD,
            `OPC_STORE:     return 2'b00;
            `OPC_BRANCH:     return 2'b01;
            default:        return 2'b00;
        endcase
    endfunction

    initial begin
        logic [6:0] opcodes[$] = {
            `OPC_ARI_RTYPE, `OPC_ARI_ITYPE, `OPC_LOAD, `OPC_STORE,
            `OPC_BRANCH, `OPC_JALR, `OPC_LUI, `OPC_JAL, `OPC_AUIPC
        };

        foreach (opcodes[i]) begin
            opcode = opcodes[i];
            #1;
            if (alu_op !== expected_aluop(opcodes[i])) begin
                $display("[FAIL] opcode %b -> got %b exp %b", opcodes[i], alu_op, expected_aluop(opcodes[i]));
                fail_count++;
            end else begin
                $display("[PASS] opcode %b", opcodes[i]);
                pass_count++;
            end
        end

        repeat (32) begin
            opcode = $urandom();
            #1;
            if (alu_op !== expected_aluop(opcode)) fail_count++; else pass_count++;
        end

        $display("\nLab4 Main Controller TB: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count != 0) $fatal(1, "Main controller tests failed");
        $finish;
    end

endmodule
