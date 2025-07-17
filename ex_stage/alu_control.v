module alu_control (
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_ctrl
);
always @(*) begin
    case (alu_op)
        2'b00:alu_ctrl =4'b0000;
        2'b01:alu_ctrl=4'b0001;
        2'b10:begin
            case ({funct7[5],funct3})
                4'b0000: alu_ctrl = 4'b0000; // ADD
                4'b1000: alu_ctrl = 4'b0001; // SUB
                4'b0111: alu_ctrl = 4'b0010; // AND
                4'b0110: alu_ctrl = 4'b0011; // OR
                4'b0100: alu_ctrl = 4'b0100; // XOR
                4'b0001: alu_ctrl = 4'b0101; // SLL
                4'b0101: alu_ctrl = 4'b0110; // SRL
                4'b1101: alu_ctrl = 4'b0111; // SRA
                4'b0010: alu_ctrl = 4'b1000; // SLT
                4'b0011: alu_ctrl = 4'b1001; // SLTU
                default: alu_ctrl = 4'b0000; 
                 
            endcase
        end
        default: alu_ctrl = 4'b0000;
    endcase
end
    
endmodule