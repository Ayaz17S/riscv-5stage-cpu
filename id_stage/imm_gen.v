module imm_gen (
    input [31:0] instr,
    output reg [31:0] imm
);

// Extract the opcode (bits [6:0]) to determine instruction format
wire [6:0] opcode;
assign opcode = instr[6:0];

always @(*) begin
    case (opcode)
        // I-Type: addi, lw, jalr
        7'b0000011,   // lw
        7'b0010011,   // addi
        7'b1100111:   // jalr
        begin
            imm = {{20{instr[31]}}, instr[31:20]};  // Sign-extend 12-bit immediate
        end

        // S-Type: sw
        7'b0100011: begin
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // imm[11:5] + imm[4:0]
        end

        // B-Type: beq, bne
        7'b1100011: begin
            imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  // sign-extend + shift-left-1
        end

        // U-Type: lui, auipc
        7'b0110111,   // lui
        7'b0010111:   // auipc
        begin
            imm = {instr[31:12], 12'b0};  // upper 20 bits, lower 12 = 0
        end

        // J-Type: jal
        7'b1101111: begin
            imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};  // sign-extend + shift-left-1
        end

        // Default case (undefined)
        default: begin
            imm = 32'b0;
        end
    endcase
end

endmodule
