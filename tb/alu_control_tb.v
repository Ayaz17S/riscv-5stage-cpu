`timescale 1ns/1ps

module alu_control_tb;

  reg [1:0] alu_op;
  reg [2:0] funct3;
  reg [6:0] funct7;
  wire [3:0] alu_ctrl;

  alu_control uut (
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_ctrl(alu_ctrl)
  );

  initial begin
    $dumpfile("alu_control_waveform.vcd");
    $dumpvars(0, alu_control_tb);
    $display("Time\talu_op funct7 funct3 | alu_ctrl");
    $monitor("%g\t%b   %b    %b   | %b", $time, alu_op, funct7[5], funct3, alu_ctrl);

    // Load/Store → ADD
    alu_op = 2'b00; funct3 = 3'b000; funct7 = 7'b0000000; #10;

    // Branch → SUB
    alu_op = 2'b01; funct3 = 3'b000; funct7 = 7'b0000000; #10;

    // ADD
    alu_op = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000; #10;

    // SUB
    alu_op = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000; #10;

    // AND
    alu_op = 2'b10; funct3 = 3'b111; funct7 = 7'b0000000; #10;

    // OR
    alu_op = 2'b10; funct3 = 3'b110; funct7 = 7'b0000000; #10;

    // XOR
    alu_op = 2'b10; funct3 = 3'b100; funct7 = 7'b0000000; #10;

    // SLL
    alu_op = 2'b10; funct3 = 3'b001; funct7 = 7'b0000000; #10;

    // SRL
    alu_op = 2'b10; funct3 = 3'b101; funct7 = 7'b0000000; #10;

    // SRA
    alu_op = 2'b10; funct3 = 3'b101; funct7 = 7'b0100000; #10;

    // SLT
    alu_op = 2'b10; funct3 = 3'b010; funct7 = 7'b0000000; #10;

    // SLTU
    alu_op = 2'b10; funct3 = 3'b011; funct7 = 7'b0000000; #10;

    $finish;
  end

endmodule
