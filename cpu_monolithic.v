// =====================================================================
// == Monolithic CPU Design File (Corrected)
// == Contains all required modules for the RISC-V 5-Stage CPU
// =====================================================================

// ==========================================================
// == PC (Program Counter)
// ==========================================================
module pc(
    input clk,
    input reset,
    input pc_write,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 32'b0;
    end else if (pc_write) begin
        pc_out <= pc_in;
    end
end
endmodule

// ==========================================================
// == Instruction Memory
// ==========================================================
module instr_mem(
    input [31:0] addr,
    output [31:0] instr
);
reg [31:0] mem [0:255];
initial begin
    // IMPORTANT: This path must be correct relative to where you run vvp
    $readmemh("if_stage/instr_mem.hex", mem);
end
assign instr = mem[addr[9:2]];
endmodule

// ==========================================================
// == Immediate Generator
// ==========================================================
module imm_gen (
    input [31:0] instr,
    output reg [31:0] imm
);
wire [6:0] opcode = instr[6:0];
always @(*) begin
    case (opcode)
        7'b0000011, 7'b0010011, 7'b1100111: imm = {{20{instr[31]}}, instr[31:20]}; // I-Type
        7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-Type
        7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-Type
        7'b0110111, 7'b0010111: imm = {instr[31:12], 12'b0}; // U-Type
        7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-Type
        default: imm = 32'b0;
    endcase
end
endmodule

// ==========================================================
// == Register File
// ==========================================================
module reg_file (
    input clk,
    input reset,
    input reg_write,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
reg [31:0] regs [0:31];
assign rs1_data = (rs1 != 0) ? regs[rs1] : 32'b0;
assign rs2_data = (rs2 != 0) ? regs[rs2] : 32'b0;
always @(posedge clk or posedge reset) begin
    if (reset) begin : reset_block
        integer i;
        for (i = 0; i < 32; i = i + 1)
            regs[i] <= 32'b0;
    end else if (reg_write && rd != 0) begin
        regs[rd] <= write_data;
    end
end
endmodule

// ==========================================================
// == ALU
// ==========================================================
module alu (
    input [31:0] a, b,
    input [3:0] alu_control,
    output reg [31:0] result,
    output zero
);
always @(*) begin
    case (alu_control)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = a & b;
        4'b0011: result = a | b;
        4'b0100: result = a ^ b;
        4'b0101: result = a << b[4:0];
        4'b0110: result = a >> b[4:0];
        4'b0111: result = $signed(a) >>> b[4:0];
        4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
        4'b1001: result = (a < b) ? 32'b1 : 32'b0;
        4'b1010: result = b;
        4'b1011: result = ~(a | b);
        default: result = 32'b0;
    endcase
end
assign zero = (result == 32'b0);
endmodule

// ==========================================================
// == ALU Control Unit
// ==========================================================
module alu_control (
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_ctrl
);
always @(*) begin
    case (alu_op)
        2'b00: alu_ctrl = 4'b0000; // ADD (for Load/Store)
        2'b01: alu_ctrl = 4'b0001; // SUB (for Branch)
        2'b10: begin // R-type and I-type
            case (funct3)
                3'b000: if (funct7[5] == 1'b1 && alu_op == 2'b10) alu_ctrl = 4'b0001; else alu_ctrl = 4'b0000; // SUB/ADD
                3'b001: alu_ctrl = 4'b0101; // SLL
                3'b010: alu_ctrl = 4'b1000; // SLT
                3'b011: alu_ctrl = 4'b1001; // SLTU
                3'b100: alu_ctrl = 4'b0100; // XOR
                3'b101: if (funct7[5] == 1'b1) alu_ctrl = 4'b0111; else alu_ctrl = 4'b0110; // SRA/SRL
                3'b110: alu_ctrl = 4'b0011; // OR
                3'b111: alu_ctrl = 4'b0010; // AND
                default: alu_ctrl = 4'b0000;
            endcase
        end
        2'b11: alu_ctrl = 4'b1010; // Pass B (for LUI)
        default: alu_ctrl = 4'b0000;
    endcase
end
endmodule

// ==========================================================
// == Pipeline Registers
// ==========================================================

module if_id_reg(
    input clk, reset, flush, if_id_write,
    input [31:0] pc_in, instr_in,
    output reg [31:0] pc_out, instr_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_out <= 0;
            instr_out <= 0;
        end else if (if_id_write) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule

module id_ex_reg(
    input clk, reset, stall,
    input [31:0] pc_in, rs1_data_in, rs2_data_in, imm_in,
    input [4:0] rs1_in, rs2_in, rd_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input reg_write_in, alu_src_in, mem_read_in, mem_write_in, mem_to_reg_in, branch_in,
    input [1:0] alu_op_in,
    output reg [31:0] pc_out, rs1_data_out, rs2_data_out, imm_out,
    output reg [4:0] rs1_out, rs2_out, rd_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg reg_write_out, alu_src_out, mem_read_out, mem_write_out, mem_to_reg_out, branch_out,
    output reg [1:0] alu_op_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || stall) begin
            {pc_out, rs1_data_out, rs2_data_out, imm_out, rs1_out, rs2_out, rd_out, funct3_out, funct7_out, reg_write_out, alu_src_out, alu_op_out, mem_read_out, mem_write_out, mem_to_reg_out, branch_out} <= 0;
        end else begin
            {pc_out, rs1_data_out, rs2_data_out, imm_out, rs1_out, rs2_out, rd_out, funct3_out, funct7_out, reg_write_out, alu_src_out, alu_op_out, mem_read_out, mem_write_out, mem_to_reg_out, branch_out} <=
            {pc_in, rs1_data_in, rs2_data_in, imm_in, rs1_in, rs2_in, rd_in, funct3_in, funct7_in, reg_write_in, alu_src_in, alu_op_in, mem_read_in, mem_write_in, mem_to_reg_in, branch_in};
        end
    end
endmodule

module ex_mem_reg(
    input clk, reset,
    input mem_read_in, mem_write_in, mem_to_reg_in, reg_write_in,
    input [31:0] alu_result_in, rs2_data_in,
    input [4:0] rd_in,
    input zero_in,
    output reg mem_read_out, mem_write_out, mem_to_reg_out, reg_write_out,
    output reg [31:0] alu_result_out, rs2_data_out,
    output reg [4:0] rd_out,
    output reg zero_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {mem_read_out, mem_write_out, mem_to_reg_out, reg_write_out, alu_result_out, rs2_data_out, rd_out, zero_out} <= 0;
        end else begin
            {mem_read_out, mem_write_out, mem_to_reg_out, reg_write_out, alu_result_out, rs2_data_out, rd_out, zero_out} <=
            {mem_read_in, mem_write_in, mem_to_reg_in, reg_write_in, alu_result_in, rs2_data_in, rd_in, zero_in};
        end
    end
endmodule

module mem_wb_reg(
    input clk, reset,
    input [31:0] mem_data_in, alu_result_in,
    input [4:0] rd_in,
    input reg_write_in, mem_to_reg_in,
    output reg [31:0] mem_data_out, alu_result_out,
    output reg [4:0] rd_out,
    output reg reg_write_out, mem_to_reg_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {mem_data_out, alu_result_out, rd_out, reg_write_out, mem_to_reg_out} <= 0;
        end else begin
            {mem_data_out, alu_result_out, rd_out, reg_write_out, mem_to_reg_out} <=
            {mem_data_in, alu_result_in, rd_in, reg_write_in, mem_to_reg_in};
        end
    end
endmodule

// ==========================================================
// == Stage Modules (IF, ID, EX, MEM, WB)
// ==========================================================
module if_stage( input clk, reset, pc_write, branch_taken, input [31:0] branch_addr, output [31:0] instr, pc_out);
    wire [31:0] pc_next, pc_curr;
    assign pc_next = branch_taken ? branch_addr : (pc_curr + 4);
    pc PC(.clk(clk), .reset(reset), .pc_write(pc_write), .pc_in(pc_next), .pc_out(pc_curr));
    instr_mem IMEM(.addr(pc_curr), .instr(instr));
    assign pc_out = pc_curr;
endmodule

module id_stage( input clk, reset, reg_write, input [31:0] instr, write_data, input [4:0] rd, output [31:0] rs1_data, rs2_data, imm);
    reg_file RF(.clk(clk), .reset(reset), .rs1(instr[19:15]), .rs2(instr[24:20]), .rd(rd), .write_data(write_data), .reg_write(reg_write), .rs1_data(rs1_data), .rs2_data(rs2_data));
    imm_gen IMM(.instr(instr), .imm(imm));
endmodule

module ex_stage( input [31:0] rs1_data, rs2_data, imm, ex_mem_alu_result, write_data, input alu_src, input [1:0] alu_op, forwardA, forwardB, input [2:0] funct3, input [6:0] funct7, output [31:0] alu_result, store_data, output zero);
    wire [3:0] alu_ctrl;
    wire [31:0] alu_in1 = (forwardA == 2'b10) ? ex_mem_alu_result : (forwardA == 2'b01) ? write_data : rs1_data;
    wire [31:0] rs2_forwarded = (forwardB == 2'b10) ? ex_mem_alu_result : (forwardB == 2'b01) ? write_data : rs2_data;
    assign store_data = rs2_forwarded;
    wire [31:0] alu_in2 = alu_src ? imm : rs2_forwarded;
    alu_control AC(.alu_op(alu_op), .funct3(funct3), .funct7(funct7), .alu_ctrl(alu_ctrl));
    alu ALU(.a(alu_in1), .b(alu_in2), .alu_control(alu_ctrl), .result(alu_result), .zero(zero));
endmodule

module mem_stage( input clk, mem_read, mem_write, input [31:0] addr, write_data, output [31:0] read_data);
    reg [31:0] data_mem [0:255]; integer i;
    initial for (i = 0; i < 256; i = i + 1) data_mem[i] = 32'b0;
    always @(posedge clk) if (mem_write) data_mem[addr[9:2]] <= write_data;
    assign read_data = data_mem[addr[9:2]];
endmodule

module wb_stage( input [31:0] alu_result, mem_data, input mem_to_reg, output [31:0] write_back_data);
    assign write_back_data = mem_to_reg ? mem_data : alu_result;
endmodule

// ==========================================================
// == Top-Level Control and Hazard Units
// ==========================================================
module control_unit ( input[6:0] opcode, output reg reg_write, output reg alu_src, output reg [1:0] alu_op, output reg mem_read, output reg mem_write, output reg mem_to_reg, output reg branch );
always @(*) begin
    {reg_write, alu_src, alu_op, mem_read, mem_write, mem_to_reg, branch} = 0;
    case (opcode)
        7'b0110011: {reg_write, alu_src, alu_op, mem_to_reg} = {1'b1, 1'b0, 2'b10, 1'b0}; // R-Type
        7'b0010011: {reg_write, alu_src, alu_op, mem_to_reg} = {1'b1, 1'b1, 2'b10, 1'b0}; // I-Type
        7'b0000011: {reg_write, alu_src, alu_op, mem_read, mem_to_reg} = {1'b1, 1'b1, 2'b00, 1'b1, 1'b1}; // Load
        7'b0100011: {alu_src, alu_op, mem_write} = {1'b1, 2'b00, 1'b1}; // Store
        7'b1100011: {alu_op, branch} = {2'b01, 1'b1}; // Branch
        7'b1101111: {reg_write, branch} = {1'b1, 1'b1}; // JAL
        7'b1100111: {reg_write, alu_src, alu_op, branch} = {1'b1, 1'b1, 2'b00, 1'b1}; // JALR
        7'b0110111: {reg_write, alu_src, alu_op} = {1'b1, 1'b1, 2'b11}; // LUI
        7'b0010111: {reg_write, alu_src, alu_op} = {1'b1, 1'b1, 2'b00}; // AUIPC
    endcase
end
endmodule

module hazard_unit( input id_ex_mem_read, input [4:0] id_ex_rd, if_id_rs1, if_id_rs2, output reg pc_write, if_id_write, stall );
always @(*) begin
    {pc_write, if_id_write, stall} = {1'b1, 1'b1, 1'b0};
    if (id_ex_mem_read && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2))
        {pc_write, if_id_write, stall} = {1'b0, 1'b0, 1'b1};
end
endmodule

module forwarding_unit( input [4:0] ex_mem_rd, mem_wb_rd, id_ex_rs1, id_ex_rs2, input ex_mem_reg_write, mem_wb_reg_write, output reg [1:0] forwardA, forwardB );
always @(*) begin
    forwardA = 2'b00;
    forwardB = 2'b00;
    if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) forwardA = 2'b10;
    if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) forwardB = 2'b10;
    if (mem_wb_reg_write && mem_wb_rd != 0 && !(ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) && mem_wb_rd == id_ex_rs1) forwardA = 2'b01;
    if (mem_wb_reg_write && mem_wb_rd != 0 && !(ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) && mem_wb_rd == id_ex_rs2) forwardB = 2'b01;
end
endmodule

// ==========================================================
// == CPU Top-Level Module
// ==========================================================
module cpu(input clk, reset);
    wire [31:0] pc_if, instr_if, pc_id, instr_id, rs1_data, rs2_data, imm, id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm, alu_result, store_data_ex, ex_mem_alu_result, ex_mem_rs2_data, mem_read_data, mem_wb_alu_result, mem_wb_mem_data, write_data, branch_target;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd, ex_mem_rd, mem_wb_rd;
    wire if_pc_write, if_id_write, id_reg_write, id_alu_src, id_mem_read, id_mem_write, id_mem_to_reg, id_branch, id_ex_reg_write, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_branch, zero, ex_mem_zero, ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, mem_wb_reg_write, mem_wb_mem_to_reg, branch_taken, stall;
    wire [1:0] id_alu_op, id_ex_alu_op, forwardA, forwardB;
    wire [2:0] id_ex_funct3;
    wire [6:0] id_ex_funct7;

    control_unit cu(.opcode(instr_id[6:0]), .reg_write(id_reg_write), .alu_src(id_alu_src), .alu_op(id_alu_op), .mem_read(id_mem_read), .mem_write(id_mem_write), .mem_to_reg(id_mem_to_reg), .branch(id_branch));
    hazard_unit hu(.id_ex_mem_read(id_ex_mem_read), .id_ex_rd(id_ex_rd), .if_id_rs1(instr_id[19:15]), .if_id_rs2(instr_id[24:20]), .pc_write(if_pc_write), .if_id_write(if_id_write), .stall(stall));
    forwarding_unit fu(.ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd), .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write), .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2), .forwardA(forwardA), .forwardB(forwardB));
    
    wire branch_condition_met = (id_ex_funct3 == 3'b000 && zero) || // BEQ
                                  (id_ex_funct3 == 3'b001 && !zero);  // BNE
                                  
    wire is_conditional_branch = id_ex_branch && (id_ex_alu_op == 2'b01);
    wire is_unconditional_jump = id_ex_branch && (id_ex_alu_op != 2'b01);

    assign branch_taken = (is_conditional_branch && branch_condition_met) || is_unconditional_jump;
    assign branch_target = id_ex_pc + id_ex_imm;

    if_stage if_s(.clk(clk), .reset(reset), .pc_write(if_pc_write), .branch_taken(branch_taken), .branch_addr(branch_target), .instr(instr_if), .pc_out(pc_if));
    if_id_reg if_id_r(.clk(clk), .reset(reset), .flush(branch_taken), .if_id_write(if_id_write), .pc_in(pc_if), .instr_in(instr_if), .pc_out(pc_id), .instr_out(instr_id));
    id_stage id_s(.clk(clk), .reset(reset), .instr(instr_id), .reg_write(mem_wb_reg_write), .rd(mem_wb_rd), .write_data(write_data), .rs1_data(rs1_data), .rs2_data(rs2_data), .imm(imm));
    
    // ✅ FINAL FIX: When a branch is taken, we must flush the instruction that has already entered the ID->EX pipeline.
    // We combine the 'stall' signal (for data hazards) with the 'branch_taken' signal (for control hazards).
    wire id_ex_stall_or_flush = stall || branch_taken;
    
    id_ex_reg id_ex_r(.clk(clk), .reset(reset), .stall(id_ex_stall_or_flush), .pc_in(pc_id), .rs1_data_in(rs1_data), .rs2_data_in(rs2_data), .imm_in(imm), .rs1_in(instr_id[19:15]), .rs2_in(instr_id[24:20]), .rd_in(instr_id[11:7]), .funct3_in(instr_id[14:12]), .funct7_in(instr_id[31:25]), .reg_write_in(id_reg_write), .alu_src_in(id_alu_src), .alu_op_in(id_alu_op), .mem_read_in(id_mem_read), .mem_write_in(id_mem_write), .mem_to_reg_in(id_mem_to_reg), .branch_in(id_branch), .pc_out(id_ex_pc), .rs1_data_out(id_ex_rs1_data), .rs2_data_out(id_ex_rs2_data), .imm_out(id_ex_imm), .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2), .rd_out(id_ex_rd), .funct3_out(id_ex_funct3), .funct7_out(id_ex_funct7), .reg_write_out(id_ex_reg_write), .alu_src_out(id_ex_alu_src), .alu_op_out(id_ex_alu_op), .mem_read_out(id_ex_mem_read), .mem_write_out(id_ex_mem_write), .mem_to_reg_out(id_ex_mem_to_reg), .branch_out(id_ex_branch));
    
    ex_stage ex_s(.rs1_data(id_ex_rs1_data), .rs2_data(id_ex_rs2_data), .imm(id_ex_imm), .alu_src(id_ex_alu_src), .alu_op(id_ex_alu_op), .funct3(id_ex_funct3), .funct7(id_ex_funct7), .forwardA(forwardA), .forwardB(forwardB), .ex_mem_alu_result(ex_mem_alu_result), .write_data(write_data), .alu_result(alu_result), .store_data(store_data_ex), .zero(zero));
    ex_mem_reg ex_mem_r(.clk(clk), .reset(reset), .alu_result_in(alu_result), .rs2_data_in(store_data_ex), .rd_in(id_ex_rd), .zero_in(zero), .reg_write_in(id_ex_reg_write), .mem_read_in(id_ex_mem_read), .mem_write_in(id_ex_mem_write), .mem_to_reg_in(id_ex_mem_to_reg), .alu_result_out(ex_mem_alu_result), .rs2_data_out(ex_mem_rs2_data), .rd_out(ex_mem_rd), .zero_out(ex_mem_zero), .reg_write_out(ex_mem_reg_write), .mem_read_out(ex_mem_mem_read), .mem_write_out(ex_mem_mem_write), .mem_to_reg_out(ex_mem_mem_to_reg));
    mem_stage mem_s(.clk(clk), .mem_read(ex_mem_mem_read), .mem_write(ex_mem_mem_write), .addr(ex_mem_alu_result), .write_data(ex_mem_rs2_data), .read_data(mem_read_data));
    mem_wb_reg mem_wb_r(.clk(clk), .reset(reset), .alu_result_in(ex_mem_alu_result), .mem_data_in(mem_read_data), .rd_in(ex_mem_rd), .reg_write_in(ex_mem_reg_write), .mem_to_reg_in(ex_mem_mem_to_reg), .alu_result_out(mem_wb_alu_result), .mem_data_out(mem_wb_mem_data), .rd_out(mem_wb_rd), .reg_write_out(mem_wb_reg_write), .mem_to_reg_out(mem_wb_mem_to_reg));
    wb_stage wb_s(.alu_result(mem_wb_alu_result), .mem_data(mem_wb_mem_data), .mem_to_reg(mem_wb_mem_to_reg), .write_back_data(write_data));
endmodule

