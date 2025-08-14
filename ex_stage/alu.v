// Enhanced ALU with support for all RISC-V operations
module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_control,
    output reg [31:0] result,
    output zero
);

always @(*) begin
    case (alu_control)
        4'b0000: result = a + b;                              // ADD
        4'b0001: result = a - b;                              // SUB
        4'b0010: result = a & b;                              // AND
        4'b0011: result = a | b;                              // OR
        4'b0100: result = a ^ b;                              // XOR
        4'b0101: result = a << b[4:0];                        // SLL (shift left logical)
        4'b0110: result = a >> b[4:0];                        // SRL (shift right logical)
        4'b0111: result = $signed(a) >>> b[4:0];              // SRA (shift right arithmetic)
        4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;  // SLT (set less than)
        4'b1001: result = (a < b) ? 32'b1 : 32'b0;            // SLTU (set less than unsigned)
        4'b1010: result = b;                                  // Pass through B (for LUI)
        4'b1011: result = ~(a | b);                           // NOR (not implemented in RISC-V but useful)
        default: result = 32'b0;                              // Default case
    endcase
end

// Zero flag - set when result is zero (used for branch decisions)
assign zero = (result == 32'b0);

endmodule