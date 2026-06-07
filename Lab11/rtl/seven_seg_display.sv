// Seven-segment display driver (from the provided simultaneous_display.sv,
// module renamed to match the file name and given a TAP parameter so the
// refresh divider can run fast in simulation).
//
// It time-multiplexes eight common-anode seven-segment displays: a 3-bit
// counter (clocked by the divided clock) walks through the eight digits,
// selecting one anode and the matching 4-bit value from num[] each step.
// Persistence of vision makes all eight digits appear lit simultaneously.
module seven_seg_display #(
    parameter TAP = 17
)(
    input  logic [3:0] num [7:0],
    input  logic       reset,
    input  logic       clk,
    output logic       an0, an1, an2, an3, an4, an5, an6, an7,
    output logic       segA, segB, segC, segD, segE, segF, segG
);

    logic       count_en, clk1;
    logic [2:0] count_d, count_q;

    clk_delay_display #(.TAP(TAP)) CLK_DELAY_DISP (
        .clk     (clk),
        .reset   (reset),
        .clk_out (clk1)
    );

    assign count_en = 1'b1;

    // Digit-select counter
    always_comb count_d = count_q + 1'b1;
    always_ff @(posedge clk1 or posedge reset) begin
        if (reset)
            count_q <= #1 3'b000;
        else if (count_en)
            count_q <= #1 count_d;
    end

    // Active digit value
    logic [3:0] y;
    always_comb begin
        case (count_q)
            3'b000: y = num[0];
            3'b001: y = num[1];
            3'b010: y = num[2];
            3'b011: y = num[3];
            3'b100: y = num[4];
            3'b101: y = num[5];
            3'b110: y = num[6];
            3'b111: y = num[7];
        endcase
    end

    // Cathode (segment) decoder
    logic [6:0] s;
    always_comb begin
        segA = s[6];
        segB = s[5];
        segC = s[4];
        segD = s[3];
        segE = s[2];
        segF = s[1];
        segG = s[0];
    end

    always_comb begin
        case (y)
            4'b0000: s = 7'b000_0001;
            4'b0001: s = 7'b100_1111;
            4'b0010: s = 7'b001_0010;
            4'b0011: s = 7'b000_0110;
            4'b0100: s = 7'b100_1100;
            4'b0101: s = 7'b010_0100;
            4'b0110: s = 7'b010_0000;
            4'b0111: s = 7'b000_1111;
            4'b1000: s = 7'b000_0000;
            4'b1001: s = 7'b000_0100;
            4'b1010: s = 7'b000_1000;
            4'b1011: s = 7'b110_0000;
            4'b1100: s = 7'b011_0001;
            4'b1101: s = 7'b100_0010;
            4'b1110: s = 7'b011_0000;
            4'b1111: s = 7'b011_1000;
        endcase
    end

    // Anode (digit-enable) decoder
    logic [7:0] z;
    always_comb begin
        an0 = z[7];
        an1 = z[6];
        an2 = z[5];
        an3 = z[4];
        an4 = z[3];
        an5 = z[2];
        an6 = z[1];
        an7 = z[0];
    end

    always_comb begin
        case (count_q)
            3'b000: z = 8'b0111_1111;
            3'b001: z = 8'b1011_1111;
            3'b010: z = 8'b1101_1111;
            3'b011: z = 8'b1110_1111;
            3'b100: z = 8'b1111_0111;
            3'b101: z = 8'b1111_1011;
            3'b110: z = 8'b1111_1101;
            3'b111: z = 8'b1111_1110;
        endcase
    end

endmodule
