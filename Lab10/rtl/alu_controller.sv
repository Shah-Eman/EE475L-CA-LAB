`include "opcode.vh"

module alu_controller (
    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_ctrl
);

    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLT  = 4'b0111;
    localparam ALU_SLTU = 4'b1000;
    localparam ALU_SLL  = 4'b1001;
    localparam ALU_SRL  = 4'b1010;
    localparam ALU_SRA  = 4'b1011;

    always_comb begin
        case (alu_op)
            2'b00: alu_ctrl = ALU_ADD;

            2'b01: begin
                case (funct3)
                    `FNC_BLT, `FNC_BGE:  alu_ctrl = ALU_SLT;
                    `FNC_BLTU, `FNC_BGEU: alu_ctrl = ALU_SLTU;
                    default:              alu_ctrl = ALU_SUB;
                endcase
            end

            2'b10, 2'b11: begin
                case (funct3)
                    `FNC_ADD_SUB: begin
                        if ((alu_op == 2'b10) && (funct7 == `FNC7_1))
                            alu_ctrl = ALU_SUB;
                        else
                            alu_ctrl = ALU_ADD;
                    end
                    `FNC_SLL:     alu_ctrl = ALU_SLL;
                    `FNC_SLT:     alu_ctrl = ALU_SLT;
                    `FNC_SLTU:    alu_ctrl = ALU_SLTU;
                    `FNC_XOR:     alu_ctrl = ALU_XOR;
                    `FNC_SRL_SRA: alu_ctrl = (funct7 == `FNC7_1) ? ALU_SRA : ALU_SRL;
                    `FNC_OR:      alu_ctrl = ALU_OR;
                    `FNC_AND:     alu_ctrl = ALU_AND;
                    default:      alu_ctrl = ALU_AND;
                endcase
            end

            default: alu_ctrl = ALU_AND;
        endcase
    end

endmodule
