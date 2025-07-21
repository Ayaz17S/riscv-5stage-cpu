`timescale 1ns / 1ps

module id_ex_reg_tb;

  reg clk, reset;

  // Inputs
  reg [31:0] pc_in;
  reg [31:0] rs1_data_in;
  reg [31:0] rs2_data_in;
  reg [31:0] imm_in;
  reg [4:0] rs1_in, rs2_in, rd_in;
  reg [2:0] funct3_in;
  reg [6:0] funct7_in;
  reg reg_write_in, alu_src_in;
  reg [1:0] alu_op_in;
  reg mem_read_in, mem_write_in, mem_to_reg_in, branch_in;

  // Outputs
  wire [31:0] pc_out;
  wire [31:0] rs1_data_out;
  wire [31:0] rs2_data_out;
  wire [31:0] imm_out;
  wire [4:0] rs1_out, rs2_out, rd_out;
  wire [2:0] funct3_out;
  wire [6:0] funct7_out;
  wire reg_write_out, alu_src_out;
  wire [1:0] alu_op_out;
  wire mem_read_out, mem_write_out, mem_to_reg_out, branch_out;

  // Instantiate DUT
  id_ex_reg dut (
    .clk(clk), .reset(reset),
    .pc_in(pc_in), .rs1_data_in(rs1_data_in), .rs2_data_in(rs2_data_in), .imm_in(imm_in),
    .rs1_in(rs1_in), .rs2_in(rs2_in), .rd_in(rd_in),
    .funct3_in(funct3_in), .funct7_in(funct7_in),
    .reg_write_in(reg_write_in), .alu_src_in(alu_src_in), .alu_op_in(alu_op_in),
    .mem_read_in(mem_read_in), .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in), .branch_in(branch_in),
    .pc_out(pc_out), .rs1_data_out(rs1_data_out), .rs2_data_out(rs2_data_out), .imm_out(imm_out),
    .rs1_out(rs1_out), .rs2_out(rs2_out), .rd_out(rd_out),
    .funct3_out(funct3_out), .funct7_out(funct7_out),
    .reg_write_out(reg_write_out), .alu_src_out(alu_src_out), .alu_op_out(alu_op_out),
    .mem_read_out(mem_read_out), .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out), .branch_out(branch_out)
  );

  // Clock
  always #5 clk = ~clk;

  initial begin
    $dumpfile("id_ex_reg.vcd");
    $dumpvars(0, id_ex_reg_tb);

    // Init
    clk = 0;
    reset = 1;

    pc_in = 32'h00000010;
    rs1_data_in = 32'h000000AA;
    rs2_data_in = 32'h000000BB;
    imm_in = 32'h00000FFF;
    rs1_in = 5'd1; rs2_in = 5'd2; rd_in = 5'd3;
    funct3_in = 3'b000;
    funct7_in = 7'b0000000;
    reg_write_in = 1;
    alu_src_in = 1;
    alu_op_in = 2'b10;
    mem_read_in = 0;
    mem_write_in = 1;
    mem_to_reg_in = 0;
    branch_in = 0;

    #10 reset = 0;

    // Change inputs to see if outputs latch old values
    #10 pc_in = 32'hDEADBEEF;
         rs1_data_in = 32'h12345678;
         rs2_data_in = 32'h87654321;

    #20 $finish;
  end
endmodule
