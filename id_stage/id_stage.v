module id_stage (
    input clk,
    input reset,
    input [31:0] instr,
    input reg_write,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] imm
);

wire [4:0] rs1 = instr[19:15];
wire [4:0] rs2 = instr[24:20];

// Instantiate reg_file
reg_file RF (
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

// Instantiate imm_gen
imm_gen IMM (
    .instr(instr),
    .imm(imm)
);

endmodule
