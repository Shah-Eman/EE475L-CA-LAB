// Lab 5 — Immediate Generator (all RV32I immediate formats)
`include "opcode.vh"

module imm_gen (
    input  logic [31:0] instr_word,
    output logic [31:0] imm_out
);

    logic [6:0] opc;
    assign opc = instr_word[6:0];

    always_comb begin
        case (opc)
            `OPC_ARI_ITYPE,
            `OPC_LOAD,
            `OPC_JALR:
                imm_out = {{20{instr_word[31]}}, instr_word[31:20]};

            `OPC_STORE:
                imm_out = {{20{instr_word[31]}}, instr_word[31:25], instr_word[11:7]};

            `OPC_BRANCH:
                imm_out = {{19{instr_word[31]}}, instr_word[31], instr_word[7],
                            instr_word[30:25], instr_word[11:8], 1'b0};

            `OPC_LUI,
            `OPC_AUIPC:
                imm_out = {instr_word[31:12], 12'b0};

            `OPC_JAL:
                imm_out = {{11{instr_word[31]}}, instr_word[31], instr_word[19:12],
                            instr_word[20], instr_word[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule
