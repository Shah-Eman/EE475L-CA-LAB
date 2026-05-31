`timescale 1ns/1ns

`include "opcode.vh"
`include "mem_path.vh"

// Lab 6 testbench — R-type and I-type instructions only (Part 1)

module cpu_tb();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;

    reg [ 31:0] cycle;
    reg         done;
    reg [ 31:0] current_test_id = 0;
    reg [255:0] current_test_type;
    reg [ 31:0] current_output;
    reg [ 31:0] current_result;
    reg         all_tests_passed = 0;

    reg [  4:0] RS1, RS2;
    reg [ 31:0] RD1, RD2;
    reg [  4:0] SHAMT;
    reg [ 31:0] IMM, IMM0;
    reg [ 14:0] INST_ADDR;
    reg [ 14:0] DATA_ADDR;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

    cpu cpu ( .clk (clk), .rst (rst) );

    wire [31:0] timeout_cycle = 10;

    task reset;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1)
                `REGFILE_PATH.Registers[i] = 0;
            for (i = 0; i < 512; i = i + 1)
                `DMEM_PATH.memory[i] = 0;
            for (i = 0; i < 16; i = i + 1)
                `IMEM_PATH.memory[i] = 0;
        end
    endtask

    task reset_cpu;
        @(posedge clk);
        rst = 1;
        #30;
        rst = 0;
    endtask

    initial begin
        while (all_tests_passed === 0) begin
            @(posedge clk);
            if (cycle === timeout_cycle) begin
                $display("[Failed] Timeout at [%d] test %s, expected_result = %h, got = %h",
                         current_test_id, current_test_type, current_result, current_output);
                $finish();
            end
        end
    end

    always @(posedge clk) begin
        if (done === 0)
            cycle <= cycle + 1;
        else
            cycle <= 0;
    end

    task check_result_rf;
        input [31:0]  rf_wa;
        input [31:0]  result;
        input [255:0] test_type;
        begin
            done = 0;
            current_test_id   = current_test_id + 1;
            current_test_type = test_type;
            current_result    = result;
            while (`REGFILE_PATH.Registers[rf_wa] !== result) begin
                current_output = `REGFILE_PATH.Registers[rf_wa];
                @(negedge clk);
            end
            cycle = 0;
            done = 1;
            $display("[%d] Test %s passed!", current_test_id, test_type);
        end
    endtask

    initial begin
        rst = 0;
        rst = 1;
        repeat (1) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // R-Type: ADD, SUB, SLL, XOR, OR, AND, SRL, SLLI, SRLI
        RS1 = 1; RD1 = -100; RS2 = 2; RD2 = 200;
        `REGFILE_PATH.Registers[RS1] = RD1;
        `REGFILE_PATH.Registers[RS2] = RD2;
        SHAMT     = 5'd20;
        INST_ADDR = 14'h0000;

        `IMEM_PATH.memory[INST_ADDR + 0] = {`FNC7_0, RS2,   RS1, `FNC_ADD_SUB, 5'd3,  `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 1] = {`FNC7_1, RS2,   RS1, `FNC_ADD_SUB, 5'd4,  `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 2] = {`FNC7_0, RS2,   RS1, `FNC_SLL,     5'd5,  `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 3] = {`FNC7_0, RS2,   RS1, `FNC_XOR,     5'd8,  `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 4] = {`FNC7_0, RS2,   RS1, `FNC_OR,      5'd9,  `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 5] = {`FNC7_0, RS2,   RS1, `FNC_AND,     5'd10, `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 6] = {`FNC7_0, RS2,   RS1, `FNC_SRL_SRA, 5'd11, `OPC_ARI_RTYPE};
        `IMEM_PATH.memory[INST_ADDR + 7] = {`FNC7_0, SHAMT, RS1, `FNC_SLL,     5'd13, `OPC_ARI_ITYPE};
        `IMEM_PATH.memory[INST_ADDR + 8] = {`FNC7_0, SHAMT, RS1, `FNC_SRL_SRA, 5'd14, `OPC_ARI_ITYPE};

        reset_cpu();
        check_result_rf(5'd3,  32'h00000064, "R-Type ADD");
        check_result_rf(5'd4,  32'hfffffed4, "R-Type SUB");
        check_result_rf(5'd5,  32'hffff9c00, "R-Type SLL");
        check_result_rf(5'd8,  32'hffffff54, "R-Type XOR");
        check_result_rf(5'd9,  32'hffffffdc, "R-Type OR");
        check_result_rf(5'd10, 32'h00000088, "R-Type AND");
        check_result_rf(5'd11, 32'h00ffffff, "R-Type SRL");
        check_result_rf(5'd13, 32'hf9c00000, "R-Type SLLI");
        check_result_rf(5'd14, 32'h00000fff, "R-Type SRLI");

        // I-Type arithmetic: ADDI, XORI, ORI, ANDI
        reset();
        RS1 = 1; RD1 = -100;
        `REGFILE_PATH.Registers[RS1] = RD1;
        IMM       = -200;
        INST_ADDR = 14'h0000;

        `IMEM_PATH.memory[INST_ADDR + 0] = {IMM[11:0], RS1, `FNC_ADD_SUB, 5'd3, `OPC_ARI_ITYPE};
        `IMEM_PATH.memory[INST_ADDR + 3] = {IMM[11:0], RS1, `FNC_XOR,     5'd6, `OPC_ARI_ITYPE};
        `IMEM_PATH.memory[INST_ADDR + 4] = {IMM[11:0], RS1, `FNC_OR,      5'd7, `OPC_ARI_ITYPE};
        `IMEM_PATH.memory[INST_ADDR + 5] = {IMM[11:0], RS1, `FNC_AND,     5'd8, `OPC_ARI_ITYPE};

        reset_cpu();
        check_result_rf(5'd3, 32'hfffffed4, "I-Type ADD");
        check_result_rf(5'd6, 32'h000000a4, "I-Type XOR");
        check_result_rf(5'd7, 32'hffffffbc, "I-Type OR");
        check_result_rf(5'd8, 32'hffffff18, "I-Type AND");

        // I-Type load: LW
        reset();
        `REGFILE_PATH.Registers[1] = 32'h0000_0100;
        IMM0      = 32'h0000_0000;
        INST_ADDR = 14'h0000;
        DATA_ADDR = (`REGFILE_PATH.Registers[1] + IMM0[11:0]);
        `DMEM_PATH.memory[DATA_ADDR] = 32'hdeadbeef;
        `IMEM_PATH.memory[INST_ADDR + 0] = {IMM0[11:0], 5'd1, `FNC_LW, 5'd2, `OPC_LOAD};

        reset_cpu();
        check_result_rf(5'd2, 32'hdeadbeef, "I-Type LW");

        all_tests_passed = 1'b1;
        repeat (100) @(posedge clk);
        $display("All Lab 6 tests passed!");
        $finish();
    end

endmodule
