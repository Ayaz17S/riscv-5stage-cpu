`timescale 1ns/1ps
module cpu_tb;

  reg clk;
  reg reset;

  // Instantiate the CPU
  cpu uut (
    .clk(clk),
    .reset(reset)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("cpu_tb.vcd");
    $dumpvars(0, uut);  // Dump ALL signals
    
    $display("Starting simulation...");
    
    clk = 0;
    reset = 1;
    #20 reset = 0;  // Longer reset period
    
    // Monitor key signals
    $monitor("Time=%0t: PC=%h Instr=%h", 
             $time, uut.pc_if, uut.instr_if);
    
    #500;  // Run for 500ns
    $display("Simulation finished");
    $finish;
  end
endmodule