// Lab 10 — hazard detection: forwarding + load-use stall
module hazard_unit (
    input  logic        if_id_valid,
    input  logic [4:0]  if_id_rs1,
    input  logic [4:0]  if_id_rs2,
    input  logic        id_mem_valid,
    input  logic        id_mem_reg_wr,
    input  logic        id_mem_is_load,
    input  logic [4:0]  id_mem_rd,
    input  logic        wb_reg_wr,
    input  logic [4:0]  wb_rd,
    output logic        stall,
    output logic [1:0]  forward_a_sel,
    output logic [1:0]  forward_b_sel
);

    logic fwd_a_from_mem, fwd_a_from_wb;
    logic fwd_b_from_mem, fwd_b_from_wb; 

    assign stall = id_mem_valid && id_mem_reg_wr && id_mem_is_load && (id_mem_rd != 5'd0) &&
                   if_id_valid &&
                   ((if_id_rs1 == id_mem_rd && if_id_rs1 != 5'd0) ||
                    (if_id_rs2 == id_mem_rd && if_id_rs2 != 5'd0));

    assign fwd_a_from_mem = if_id_valid && id_mem_valid && id_mem_reg_wr && !id_mem_is_load &&
                            (id_mem_rd != 5'd0) && (id_mem_rd == if_id_rs1);
    assign fwd_a_from_wb  = if_id_valid && wb_reg_wr &&
                            (wb_rd != 5'd0) && (wb_rd == if_id_rs1);

    assign fwd_b_from_mem = if_id_valid && id_mem_valid && id_mem_reg_wr && !id_mem_is_load &&
                            (id_mem_rd != 5'd0) && (id_mem_rd == if_id_rs2);
    assign fwd_b_from_wb  = if_id_valid && wb_reg_wr &&
                            (wb_rd != 5'd0) && (wb_rd == if_id_rs2);

    always_comb begin
        forward_a_sel = 2'b00;
        forward_b_sel = 2'b00;

        if (fwd_a_from_wb)
            forward_a_sel = 2'b10;
        else if (fwd_a_from_mem)
            forward_a_sel = 2'b01;

        if (fwd_b_from_wb)
            forward_b_sel = 2'b10;
        else if (fwd_b_from_mem)
            forward_b_sel = 2'b01;
    end

endmodule
