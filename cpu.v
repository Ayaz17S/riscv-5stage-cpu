// Top-Level CPU Module with all pipeline stages connected

module cpu(
    input clk,
    input reset
);

    // IF Stage
    wire [31:0] pc_if, instr_if;
    wire if_pc_write;

    // IF/ID
    wire [31:0] pc_id, instr_id;
    wire if_id_write;

    // ID Stage
    wire [31:0] rs1_data, rs2_data, imm;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire id_reg_write, id_alu_src, id_mem_read, id_mem_write, id_mem_to_reg, id_branch;
    wire [1:0] id_alu_op;

    // ID/EX
    wire [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    wire [2:0] id_ex_funct3;
    wire [6:0] id_ex_funct7;
    wire id_ex_reg_write, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_branch;
    wire [1:0] id_ex_alu_op;

    // EX Stage
    wire [31:0] alu_result;
    wire zero;

    // EX/MEM
    wire [31:0] ex_mem_alu_result, ex_mem_rs2_data;
    wire [4:0] ex_mem_rd;
    wire ex_mem_zero, ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;

    // MEM Stage
    wire [31:0] mem_read_data;

    // MEM/WB
    wire [31:0] mem_wb_alu_result, mem_wb_mem_data;
    wire [4:0] mem_wb_rd;
    wire mem_wb_reg_write, mem_wb_mem_to_reg;

    // WB Stage
    wire [31:0] write_data;

    // Branching
    wire branch_taken = id_ex_branch && zero;
    wire [31:0] branch_target = id_ex_pc + id_ex_imm;

    // Control Unit
    control_unit cu(
        .opcode(instr_id[6:0]),
        .reg_write(id_reg_write),
        .alu_src(id_alu_src),
        .alu_op(id_alu_op),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .branch(id_branch)
    );

    // Hazard Detection
    hazard_unit hu(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(instr_id[19:15]),
        .if_id_rs2(instr_id[24:20]),
        .pc_write(if_pc_write),
        .if_id_write(if_id_write),
        .stall()
    );

    // Forwarding Unit
    forwarding_unit fu(
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .forwardA(),
        .forwardB()
    );

    // Pipeline Stages
    if_stage if_stage(
        .clk(clk),
        .reset(reset),
        .pc_write(if_pc_write),
        .branch_taken(branch_taken),
        .branch_addr(branch_target),
        .instr(instr_if),
        .pc_out(pc_if)
    );

    if_id_reg if_id_reg(
        .clk(clk),
        .reset(reset),
        .flush(branch_taken),
        .if_id_write(if_id_write),
        .pc_in(pc_if),
        .instr_in(instr_if),
        .pc_out(pc_id),
        .instr_out(instr_id)
    );

    id_stage id_stage(
        .clk(clk),
        .reset(reset),
        .instr(instr_id),
        .reg_write(mem_wb_reg_write),
        .rd(mem_wb_rd),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm)
    );

    id_ex_reg id_ex_reg(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_id),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),
        .imm_in(imm),
        .rs1_in(instr_id[19:15]),
        .rs2_in(instr_id[24:20]),
        .rd_in(instr_id[11:7]),
        .funct3_in(instr_id[14:12]),
        .funct7_in(instr_id[31:25]),
        .reg_write_in(id_reg_write),
        .alu_src_in(id_alu_src),
        .alu_op_in(id_alu_op),
        .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write),
        .mem_to_reg_in(id_mem_to_reg),
        .branch_in(id_branch),
        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7),
        .reg_write_out(id_ex_reg_write),
        .alu_src_out(id_ex_alu_src),
        .alu_op_out(id_ex_alu_op),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .branch_out(id_ex_branch)
    );

    ex_stage ex_stage(
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .imm(id_ex_imm),
        .alu_src(id_ex_alu_src),
        .alu_op(id_ex_alu_op),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .alu_result(alu_result),
        .zero(zero)
    );

    ex_mem_reg ex_mem_reg(
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result),
        .rs2_data_in(id_ex_rs2_data),
        .rd_in(id_ex_rd),
        .zero_in(zero),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .rd_out(ex_mem_rd),
        .zero_out(ex_mem_zero),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    mem_stage mem_stage(
        .clk(clk),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .read_data(mem_read_data)
    );

    mem_wb_reg mem_wb_reg(
        .clk(clk),
        .reset(reset),
        .alu_result_in(ex_mem_alu_result),
        .mem_data_in(mem_read_data),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .alu_result_out(mem_wb_alu_result),
        .mem_data_out(mem_wb_mem_data),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    wb_stage wb_stage(
        .alu_result(mem_wb_alu_result),
        .mem_data(mem_wb_mem_data),
        .mem_to_reg(mem_wb_mem_to_reg),
        .write_back_data(write_data)
    );

endmodule
