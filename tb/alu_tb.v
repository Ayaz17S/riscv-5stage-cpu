`timescale 1ns/1ps

module alu_tb;

  reg [31:0] a, b;
  reg [3:0] alu_control;
  wire [31:0] result;
  wire zero;

  // Instantiate the ALU
  alu uut (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
  );

  initial begin
    $dumpfile("alu_waveform.vcd");
    $dumpvars(0, alu_tb);
    $display("Starting ALU Test...");

    // Test ADD
    a = 32'd10; b = 32'd5; alu_control = 4'b0000; #10;
    $display("ADD: result=%d, zero=%b", result, zero);

    // Test SUB
    a = 32'd10; b = 32'd10; alu_control = 4'b0001; #10;
    $display("SUB (should be 0): result=%d, zero=%b", result, zero);

    // Test AND
    a = 32'b1010; b = 32'b1100; alu_control = 4'b0010; #10;
    $display("AND: result=%b", result);

    // Test OR
    a = 32'b1010; b = 32'b1100; alu_control = 4'b0011; #10;
    $display("OR: result=%b", result);

    // Test XOR
    a = 32'b1010; b = 32'b1100; alu_control = 4'b0100; #10;
    $display("XOR: result=%b", result);

    // Test SLL
    a = 32'b1; b = 32'd2; alu_control = 4'b0101; #10;
    $display("SLL: result=%b", result);

    // Test SRL
    a = 32'b1000; b = 32'd2; alu_control = 4'b0110; #10;
    $display("SRL: result=%b", result);

    // Test SRA
    a = -32'd8; b = 32'd2; alu_control = 4'b0111; #10;
    $display("SRA: result=%d", result);

    // Test SLT (signed)
    a = -32'd1; b = 32'd2; alu_control = 4'b1000; #10;
    $display("SLT: result=%d", result);

    // Test SLTU (unsigned)
    a = 32'hFFFFFFFF; b = 32'd0; alu_control = 4'b1001; #10;
    $display("SLTU: result=%d", result);

    $display("ALU Test Completed.");
    $stop;
  end

endmodule
