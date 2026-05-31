module pc #(
    parameter W = 32,
    parameter RESET_VAL = 32'h1000_0000
)(
    input  logic         clk,
    input  logic         rst,
    input  logic [W-1:0] next_pc,
    output logic [W-1:0] curr_pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            curr_pc <= RESET_VAL;
        else
            curr_pc <= next_pc;
    end

endmodule
