module forwarding_unit(
    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,
    input ex_mem_reg_write,
    input mem_wb_reg_write,
    input [4:0] id_ex_rs1,
    input [4:0] id_ex_rs2,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

always @(*) begin
    // Defaults
    forwardA = 2'b00;
    forwardB = 2'b00;
    
    // EX hazard (EX/MEM -> EX)
    if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1)
        forwardA = 2'b10;
    if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2)
        forwardB = 2'b10;
    
    // MEM hazard (MEM/WB -> EX)
    if (mem_wb_reg_write && mem_wb_rd != 0 && 
        !(ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) &&
        mem_wb_rd == id_ex_rs1)
        forwardA = 2'b01;
    
    if (mem_wb_reg_write && mem_wb_rd != 0 && 
        !(ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) &&
        mem_wb_rd == id_ex_rs2)
        forwardB = 2'b01;
end
endmodule