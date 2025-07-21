`timescale 1ns/1ps
module id_stage_tb;

  reg clk;
  reg reset;
  reg reg_write;
  reg [31:0] instr;
  reg [4:0] rd;
  reg [31:0] write_data;
  wire [31:0] rs1_data, rs2_data, imm;

  // Instantiate DUT
  id_stage DUT (
    .clk(clk),
    .reset(reset),
    .instr(instr),
    .reg_write(reg_write),
    .rd(rd),
    .write_data(write_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .imm(imm)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("id_stage.vcd");
    $dumpvars(0, id_stage_tb);

    clk = 0;
    reset = 1;
    reg_write = 0;
    instr = 32'b0;
    rd = 5'd0;
    write_data = 32'b0;

    #10 reset = 0;

    // Write to register x1 = 10
    reg_write = 1;
    rd = 5'd1;
    write_data = 32'd10;
    instr = 32'h00000013;  // NOP (x0 = x0 + 0), not really used here
    #10;

    // Now try an actual ADDI: addi x2, x1, 5
    reg_write = 0;
    instr = 32'b000000000101_00001_000_00010_0010011;  // addi x2, x1, 5
    #10;

    // Another example: sw x2, 4(x1)
    instr = 32'b0000000_00010_00001_010_00100_0100011;  // sw x2, 4(x1)
    #10;

    $finish;
  end
endmodule
