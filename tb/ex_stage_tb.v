`timescale 1ns/1ps

module ex_stage_tb;

  reg [31:0] rs1_data, rs2_data, imm;
  reg alu_src;
  reg [1:0] alu_op;
  reg [2:0] funct3;
  reg [6:0] funct7;
  wire [31:0] alu_result;
  wire zero;

  ex_stage dut (
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

    // ADD (funct7=0, funct3=000), alu_op=10
    rs1_data = 32'd10;
    rs2_data = 32'd20;
    imm = 32'd5;
    alu_src = 0;
    alu_op = 2'b10;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    // SUB (funct7=1, funct3=000), alu_op=10
    funct7 = 7'b0100000;
    #10;

    // OR (funct7=0, funct3=110)
    funct7 = 7'b0000000;
    funct3 = 3'b110;
    #10;

    // XOR with imm, alu_src = 1
    alu_src = 1;
    funct3 = 3'b100;
    imm = 32'h0F0F0F0F;
    #10;

    // SLT
    alu_src = 0;
    rs1_data = -5;
    rs2_data = 10;
    funct3 = 3'b010;
    #10;

    // SLTU: rs1_data < rs2_data unsigned?
    rs1_data = 32'hFFFFFFFF; // Large unsigned
    rs2_data = 32'd1;
    funct3 = 3'b011;
    #10;

    // SLL
    rs1_data = 32'h00000001;
    rs2_data = 32'd4;
    funct3 = 3'b001;
    #10;

    // SRA
    rs1_data = -32'd8;
    rs2_data = 32'd1;
    funct3 = 3'b101;
    funct7 = 7'b0100000; // SRA
    #10;

    $finish;
  end

endmodule
