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
    $dumpvars(0, cpu_tb);

    clk = 0;
    reset = 1;

    // Wait a bit then release reset
    #10 reset = 0;

    // Run for a certain number of cycles
    #500 $finish;
  end

endmodule
