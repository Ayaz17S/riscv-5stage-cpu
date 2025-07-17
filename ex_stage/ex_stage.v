module ex_stage (
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] imm,
    input alu_src,                     // selects b: rs2_data or imm
    input [1:0] alu_op,                // from control unit
    input [2:0] funct3,                // from instruction
    input [6:0] funct7,                // from instruction
    output [31:0] alu_result,
    output zero
);

wire [31:0] b;
assign b = alu_src ? imm : rs2_data;

wire [3:0] alu_ctrl;

alu_control AC (
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_ctrl(alu_ctrl)
);

alu ALU (
    .a(rs1_data),
    .b(b),
    .alu_control(alu_ctrl),
    .result(alu_result),
    .zero(zero)
);

endmodule
