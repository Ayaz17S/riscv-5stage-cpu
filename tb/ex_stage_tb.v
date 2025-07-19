`timescale 1ns/1ps

module ex_stage_tb;

  reg [31:0] rs1_data;
  reg [31:0] rs2_data;
  reg [31:0] imm;
  reg alu_src;
  reg [1:0] alu_op;
  reg [2:0] funct3;
  reg [6:0] funct7;

  wire [31:0] alu_result;
  wire zero;

  // DUT
  ex_stage uut (
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .imm(imm),
    .alu_src(alu_src),
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_result(alu_result),
    .zero(zero)
  );

  initial begin
    $dumpfile("ex_stage.vcd");
    $dumpvars(0, ex_stage_tb);

    // --- ADD (rs1 + rs2)
    rs1_data = 32'd10;
    rs2_data = 32'd5;
    imm = 32'd0;
    alu_src = 0;
    alu_op = 2'b10;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    // --- SUB
    rs1_data = 32'd20;
    rs2_data = 32'd10;
    alu_src = 0;
    alu_op = 2'b10;
    funct3 = 3'b000;
    funct7 = 7'b0100000;
    #10;

    // --- ADDI
    rs1_data = 32'd15;
    imm = 32'd25;
    alu_src = 1;
    alu_op = 2'b00;
    #10;

    $finish;
  end

endmodule
