// Ripple clock divider for the seven-segment display multiplexer.
//
// This is the same 26-stage toggle-flip-flop chain that was provided with
// the lab; it has only been parameterised so the divide ratio (which tap
// of the chain feeds clk_out) can be lowered during simulation. On the
// FPGA the default TAP = 17 reproduces the original `assign clk_out = q17`
// (clk / 2^18, giving a comfortable multiplexing rate from a ~100 MHz
// board clock).
module clk_delay_display #(
    parameter TAP = 17
)(
    input  logic clk,
    input  logic reset,
    output logic clk_out
);

    logic [25:0] q;

    t_ff ff0 (
        .reset   (reset),
        .clk     (clk),
        .clk_out (q[0])
    );

    genvar i;
    generate
        for (i = 1; i < 26; i++) begin : chain
            t_ff ff (
                .reset   (reset),
                .clk     (q[i-1]),
                .clk_out (q[i])
            );
        end
    endgenerate

    assign clk_out = q[TAP];

endmodule
