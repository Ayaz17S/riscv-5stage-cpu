`timescale 1ns/1ps
module if_stage_tb;

  reg clk, reset, pc_write, branch_taken;
  reg [31:0] branch_addr;
  wire [31:0] instr, pc_out;

  if_stage dut (
    .clk(clk),
    .reset(reset),
    .pc_write(pc_write),
    .branch_taken(branch_taken),
    .branch_addr(branch_addr),
    .instr(instr),
    .pc_out(pc_out)
  );

  // Clock generator
  always #5 clk = ~clk;

  initial begin
    $dumpfile("if_stage_tb.vcd");
    $dumpvars(0, if_stage_tb);

    // Init
    clk = 0;
    reset = 1;
    pc_write = 0;
    branch_taken = 0;
    branch_addr = 0;

    // Hold reset
    #10 reset = 0;

    // First cycle: write PC
    #5 pc_write = 1;
    
    // Let 5 instructions go through
    repeat (5) begin
      #10;
    end

    // Branch test: simulate jump to address 0x00000010 (4th instruction)
    #5 branch_taken = 1;
       branch_addr = 32'h00000010;

    #10 branch_taken = 0;

    // Continue normal execution
    repeat (3) begin
      #10;
    end

    $finish;
  end
endmodule
