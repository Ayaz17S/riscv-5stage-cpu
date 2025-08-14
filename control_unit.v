// Enhanced Control Unit with comprehensive instruction support
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
    // Default values - prevents latches
    {reg_write, alu_src, alu_op, mem_read, mem_write, mem_to_reg, branch} = 7'b0;

    case (opcode)
        // R-Type Instructions (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
        7'b0110011: begin
            reg_write = 1;
            alu_src = 0;      // Use rs2 (register)
            alu_op = 2'b10;   // R-type ALU operation
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write ALU result to register
            branch = 0;
        end
        
        // I-Type Instructions (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU)
        7'b0010011: begin
            reg_write = 1;
            alu_src = 1;      // Use immediate
            alu_op = 2'b10;   // I-type ALU operation (same as R-type)
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write ALU result to register
            branch = 0;
        end
        
        // Load Instructions (LW, LH, LB, LHU, LBU)
        7'b0000011: begin
            reg_write = 1;
            alu_src = 1;      // Use immediate for address calculation
            alu_op = 2'b00;   // ADD for address calculation
            mem_read = 1;
            mem_write = 0;
            mem_to_reg = 1;   // Write memory data to register
            branch = 0;
        end
        
        // Store Instructions (SW, SH, SB)
        7'b0100011: begin
            reg_write = 0;
            alu_src = 1;      // Use immediate for address calculation
            alu_op = 2'b00;   // ADD for address calculation
            mem_read = 0;
            mem_write = 1;
            mem_to_reg = 0;   // Don't care
            branch = 0;
        end
        
        // Branch Instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
        7'b1100011: begin
            reg_write = 0;
            alu_src = 0;      // Use rs2 for comparison
            alu_op = 2'b01;   // Branch ALU operation (subtraction for comparison)
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Don't care
            branch = 1;
        end
        
        // Jump and Link (JAL)
        7'b1101111: begin
            reg_write = 1;
            alu_src = 0;      // Don't care
            alu_op = 2'b00;   // Don't care for jump
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write PC+4 to register (need to implement PC+4 path)
            branch = 1;       // Take jump
        end
        
        // Jump and Link Register (JALR)
        7'b1100111: begin
            reg_write = 1;
            alu_src = 1;      // Use immediate for target calculation
            alu_op = 2'b00;   // ADD for target calculation
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write PC+4 to register
            branch = 1;       // Take jump
        end
        
        // Load Upper Immediate (LUI)
        7'b0110111: begin
            reg_write = 1;
            alu_src = 1;      // Use immediate
            alu_op = 2'b11;   // Special operation for LUI
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write ALU result to register
            branch = 0;
        end
        
        // Add Upper Immediate to PC (AUIPC)
        7'b0010111: begin
            reg_write = 1;
            alu_src = 1;      // Use immediate
            alu_op = 2'b00;   // ADD (PC + immediate)
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;   // Write ALU result to register
            branch = 0;
        end
        
        // Default case for undefined opcodes
        default: begin
            reg_write = 0;
            alu_src = 0;
            alu_op = 2'b00;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;
            branch = 0;
        end
    endcase
end
    
endmodule