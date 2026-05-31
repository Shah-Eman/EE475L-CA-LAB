// Lab 4 — Arithmetic Logic Unit (Table 1.1 encoding)
module alu (
    input  logic [31:0] src_a,
    input  logic [31:0] src_b,
    input  logic [3:0]  op_sel,
    output logic [31:0] out,
    output logic        zero_flag
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
        case (op_sel)
            ALU_AND:  out = src_a & src_b;
            ALU_OR:   out = src_a | src_b;
            ALU_ADD:  out = src_a + src_b;
            ALU_XOR:  out = src_a ^ src_b;
            ALU_SUB:  out = src_a - src_b;
            ALU_SLT:  out = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;
            ALU_SLTU: out = (src_a < src_b) ? 32'd1 : 32'd0;
            ALU_SLL:  out = src_a << src_b[4:0];
            ALU_SRL:  out = src_a >> src_b[4:0];
            ALU_SRA:  out = $signed(src_a) >>> src_b[4:0];
            default:  out = 32'd0;
        endcase
    end

    assign zero_flag = (out == 32'd0);

endmodule
