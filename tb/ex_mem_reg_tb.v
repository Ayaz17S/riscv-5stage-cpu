`timescale 1ns/1ps

module ex_mem_reg_tb;

  reg clk, reset;

  // Inputs
  reg mem_read_in;
  reg mem_write_in;
  reg mem_to_reg_in;
  reg reg_write_in;
  reg [31:0] alu_result_in;
  reg [31:0] rs2_data_in;
  reg [4:0] rd_in;
  reg zero_in;

  // Outputs
  wire mem_read_out;
  wire mem_write_out;
  wire mem_to_reg_out;
  wire reg_write_out;
  wire [31:0] alu_result_out;
  wire [31:0] rs2_data_out;
  wire [4:0] rd_out;
  wire zero_out;

  // Instantiate the module
  ex_mem_reg dut (
    .clk(clk),
    .reset(reset),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .reg_write_in(reg_write_in),
    .alu_result_in(alu_result_in),
    .rs2_data_in(rs2_data_in),
    .rd_in(rd_in),
    .zero_in(zero_in),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .reg_write_out(reg_write_out),
    .alu_result_out(alu_result_out),
    .rs2_data_out(rs2_data_out),
    .rd_out(rd_out),
    .zero_out(zero_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("ex_mem_reg_tb.vcd");
    $dumpvars(0, ex_mem_reg_tb);

    // Initialize
    clk = 0;
    reset = 1;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_to_reg_in = 0;
    reg_write_in = 0;
    alu_result_in = 0;
    rs2_data_in = 0;
    rd_in = 0;
    zero_in = 0;

    // Apply reset
    #10;
    reset = 0;

    // First test input
    mem_read_in = 1;
    mem_write_in = 0;
    mem_to_reg_in = 1;
    reg_write_in = 1;
    alu_result_in = 32'hABCD1234;
    rs2_data_in = 32'h11112222;
    rd_in = 5'd10;
    zero_in = 0;

    #10;

    // Change input again
    mem_read_in = 0;
    mem_write_in = 1;
    mem_to_reg_in = 0;
    reg_write_in = 0;
    alu_result_in = 32'h5555AAAA;
    rs2_data_in = 32'h22223333;
    rd_in = 5'd5;
    zero_in = 1;

    #10;

    $finish;
  end
endmodule
