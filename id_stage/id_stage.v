module id_stage (
    input clk,
    input reset,
    input [31:0] instr,

    // Inputs from WB stage
    input reg_write_wb,
    input [4:0] rd_wb,
    input [31:0] write_data_wb,

    // Outputs to EX stage
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] imm,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [2:0] funct3,
    output [6:0] funct7,
    output [6:0] opcode,

    // Control signals
    output reg_write,
    output alu_src,
    output [1:0] alu_op,
    output mem_read,
    output mem_write,
    output mem_to_reg,
    output branch
);

assign opcode = instr[6:0];
assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];

// Instantiate control unit
control_unit CU (
    .opcode(opcode),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_op(alu_op),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch)
);

// Instantiate register file
reg_file RF (
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write_wb),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd_wb),
    .write_data(write_data_wb),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

// Instantiate immediate generator
imm_gen IMM (
    .instr(instr),
    .imm(imm)
);

endmodule
