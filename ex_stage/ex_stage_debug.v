// ==========================================================
// === DEBUG VERSION of EX Stage - FORWARDING IS DISABLED ===
// ==========================================================
module ex_stage (
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] imm,
    input alu_src,
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    // These forwarding inputs are now unused, but kept for port matching
    input [1:0] forwardA,
    input [1:0] forwardB,
    input [31:0] ex_mem_alu_result,
    input [31:0] write_data,
    output [31:0] alu_result,
    output zero
);

    wire [3:0] alu_ctrl;

    // --- FORWARDING LOGIC REMOVED FOR DEBUGGING ---
    // ALU inputs are now taken directly from the ID/EX register data.
    wire [31:0] alu_in1 = rs1_data;

    // ALU source MUX (register vs immediate)
    wire [31:0] alu_in2;
    assign alu_in2 = alu_src ? imm : rs2_data; // NOTE: rs2_forwarded is now just rs2_data

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
