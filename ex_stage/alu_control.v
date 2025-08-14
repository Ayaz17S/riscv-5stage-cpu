// Enhanced ALU Control Unit with support for all RISC-V operations
module alu_control (
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_ctrl
);

always @(*) begin
    case (alu_op)
        // Load/Store operations - always ADD
        2'b00: alu_ctrl = 4'b0000; // ADD
        
        // Branch operations - always SUB for comparison
        2'b01: alu_ctrl = 4'b0001; // SUB
        
        // R-type and I-type operations - decode using funct3 and funct7
        2'b10: begin
            case (funct3)
                3'b000: begin // ADD/SUB/ADDI
                    if (funct7[5] == 1'b1 && alu_op == 2'b10) // SUB (only for R-type)
                        alu_ctrl = 4'b0001; // SUB
                    else
                        alu_ctrl = 4'b0000; // ADD/ADDI
                end
                3'b001: alu_ctrl = 4'b0101; // SLL/SLLI
                3'b010: alu_ctrl = 4'b1000; // SLT/SLTI
                3'b011: alu_ctrl = 4'b1001; // SLTU/SLTIU
                3'b100: alu_ctrl = 4'b0100; // XOR/XORI
                3'b101: begin // SRL/SRLI/SRA/SRAI
                    if (funct7[5] == 1'b1)
                        alu_ctrl = 4'b0111; // SRA/SRAI
                    else
                        alu_ctrl = 4'b0110; // SRL/SRLI
                end
                3'b110: alu_ctrl = 4'b0011; // OR/ORI
                3'b111: alu_ctrl = 4'b0010; // AND/ANDI
                default: alu_ctrl = 4'b0000; // Default to ADD
            endcase
        end
        
        // Special operations (LUI, etc.)
        2'b11: alu_ctrl = 4'b1010; // Pass through B input (for LUI)
        
        default: alu_ctrl = 4'b0000; // Default to ADD
    endcase
end
    
endmodule