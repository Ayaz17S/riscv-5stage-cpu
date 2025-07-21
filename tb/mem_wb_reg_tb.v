`timescale 1ns/1ps

module mem_wb_reg_tb;

  // Inputs
  reg clk, reset;
  reg [31:0] mem_data_in, alu_result_in;
  reg [4:0] rd_in;
  reg reg_write_in, mem_to_reg_in;

  // Outputs
  wire [31:0] mem_data_out, alu_result_out;
  wire [4:0] rd_out;
  wire reg_write_out, mem_to_reg_out;

  // Instantiate the module
  mem_wb_reg uut (
    .clk(clk),
    .reset(reset),
    .mem_data_in(mem_data_in),
    .alu_result_in(alu_result_in),
    .rd_in(rd_in),
    .reg_write_in(reg_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .mem_data_out(mem_data_out),
    .alu_result_out(alu_result_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("mem_wb_reg_tb.vcd");
    $dumpvars(0, mem_wb_reg_tb);

    // Initialize
    clk = 0;
    reset = 1;
    mem_data_in = 32'h0;
    alu_result_in = 32'h0;
    rd_in = 5'b0;
    reg_write_in = 0;
    mem_to_reg_in = 0;

    #10 reset = 0;

    // Apply values at next clock cycle
    #10;
    mem_data_in = 32'hABCD1234;
    alu_result_in = 32'hDEADBEEF;
    rd_in = 5'd10;
    reg_write_in = 1;
    mem_to_reg_in = 1;

    // Wait for a few clock cycles
    #20;

    // Change values again
    mem_data_in = 32'hCAFEBABE;
    alu_result_in = 32'h12345678;
    rd_in = 5'd5;
    reg_write_in = 1;
    mem_to_reg_in = 0;

    #20;

    $finish;
  end

endmodule
