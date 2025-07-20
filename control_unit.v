module control_unit (
    input[6:0] opcode,
    output reg reg_write,
    output reg alu_src,
    output reg [1:0] alu_op,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch
);

always @(*) begin
    {reg_write, alu_src, alu_op, mem_read, mem_write, mem_to_reg, branch} = 0;

    case (opcode)
       7'b0110011 :begin
        reg_write =1;
        alu_op=2'b10;
       end 
        7'b0010011: begin
            reg_write = 1;
            alu_src = 1;
            alu_op = 2'b10;
        end
        7'b0000011: begin
            reg_write = 1;
            alu_src = 1;
            mem_read = 1;
            mem_to_reg = 1;
            alu_op = 2'b00;
        end
        7'b0100011: begin
            alu_src = 1;
            mem_write = 1;
            alu_op = 2'b00;
        end
        // Branch
        7'b1100011: begin
            branch = 1;
            alu_op = 2'b01;
        end
        default: ;
    endcase
end
    
endmodule