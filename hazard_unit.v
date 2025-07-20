module hazard_unit(
    input id_ex_mem_read,
    input [4:0] id_ex_rd,
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    output reg pc_write,
    output reg if_id_write,
    output reg stall
);

always @(*) begin
    stall = 0;
    pc_write = 1;
    if_id_write = 1;
    
    // Load-use hazard detection
    if (id_ex_mem_read && 
        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
        stall = 1;
        pc_write = 0;
        if_id_write = 0;
    end
end
endmodule