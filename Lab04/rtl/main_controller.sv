// Lab 4 — First-level controller: opcode -> ALUOp (Table 1.2)
`include "opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    output logic [1:0] alu_op
);

    always_comb begin
        case (opcode)
            `OPC_ARI_RTYPE: alu_op = 2'b10;
            `OPC_ARI_ITYPE,
            `OPC_JALR:      alu_op = 2'b11;
            `OPC_LOAD,
            `OPC_STORE:     alu_op = 2'b00;
            `OPC_BRANCH:     alu_op = 2'b01;
            default:        alu_op = 2'b00;
        endcase
    end

endmodule
