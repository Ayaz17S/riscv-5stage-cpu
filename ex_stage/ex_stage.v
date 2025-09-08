// Enhanced EX Stage with proper forwarding and store data path
module ex_stage (
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] imm,
    input alu_src,
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    input [1:0] forwardA,
    input [1:0] forwardB,
    input [31:0] ex_mem_alu_result,
    input [31:0] write_data,
    output [31:0] alu_result,
    output [31:0] store_data, // ✅ NEW: Output for store data
    output zero
);

    wire [3:0] alu_ctrl;

    // Forwarding MUX for ALU input A (rs1_data)
    wire [31:0] alu_in1;
    assign alu_in1 = (forwardA == 2'b10) ? ex_mem_alu_result :  // EX/MEM forwarding
                     (forwardA == 2'b01) ? write_data :        // MEM/WB forwarding
                     rs1_data;                                // No forwarding

    // Forwarding MUX for ALU input B and for store data
    wire [31:0] rs2_forwarded;
    assign rs2_forwarded = (forwardB == 2'b10) ? ex_mem_alu_result :  // EX/MEM forwarding
                           (forwardB == 2'b01) ? write_data :        // MEM/WB forwarding
                           rs2_data;                                // No forwarding
    
    // ✅ NEW: Assign the forwarded value to the new output
    assign store_data = rs2_forwarded;

    // ALU source MUX (register vs immediate)
    wire [31:0] alu_in2;
    assign alu_in2 = alu_src ? imm : rs2_forwarded;

    // ALU Control Unit
    alu_control AC (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl)
    );

    // ALU
    alu ALU (
        .a(alu_in1),
        .b(alu_in2),
        .alu_control(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

endmodule
