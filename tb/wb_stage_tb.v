`timescale 1ns / 1ps

module wb_stage_tb;

  reg [31:0] alu_result;
  reg [31:0] mem_data;
  reg mem_to_reg;
  wire [31:0] write_back_data;

  wb_stage uut (
    .alu_result(alu_result),
    .mem_data(mem_data),
    .mem_to_reg(mem_to_reg),
    .write_back_data(write_back_data)
  );

  initial begin
    $display("Starting WB stage test...");
    
    // Case 1: mem_to_reg = 0 => alu_result selected
    alu_result = 32'hAAAA_BBBB;
    mem_data = 32'hDEAD_BEEF;
    mem_to_reg = 0;
    #10;
    $display("WB result (ALU): %h", write_back_data);

    // Case 2: mem_to_reg = 1 => mem_data selected
    mem_to_reg = 1;
    #10;
    $display("WB result (MEM): %h", write_back_data);

    $finish;
  end

endmodule
