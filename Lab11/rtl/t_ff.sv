// Toggle flip-flop used to build the ripple clock divider in
// clk_delay_display. Each stage divides its input clock by two.
module t_ff (
    input  logic clk,
    input  logic reset,
    output logic clk_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            clk_out <= 1'b0;
        else
            clk_out <= ~clk_out;
    end

endmodule
