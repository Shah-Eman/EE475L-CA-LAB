// Lab 6 — Main controller (R-type and I-type only)
`include "opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    output logic [1:0] alu_op,
    output logic       reg_wr,
    output logic       imm_sel,
    output logic [1:0] result_mux,
    output logic       mem_wr,
    output logic       is_branch,
    output logic       is_jump
);

    always_comb begin
        reg_wr     = 1'b0;
        imm_sel    = 1'b0;
        alu_op     = 2'b00;
        result_mux = 2'b00;
        mem_wr     = 1'b0;
        is_branch  = 1'b0;
        is_jump    = 1'b0;

        case (opcode)
            `OPC_ARI_RTYPE: begin
                reg_wr = 1'b1;
                alu_op = 2'b10;
            end

            `OPC_ARI_ITYPE: begin
                reg_wr  = 1'b1;
                imm_sel = 1'b1;
                alu_op  = 2'b11;
            end

            `OPC_LOAD: begin
                reg_wr     = 1'b1;
                imm_sel    = 1'b1;
                alu_op     = 2'b00;
                result_mux = 2'b01;
            end

            default: ;
        endcase
    end

endmodule
