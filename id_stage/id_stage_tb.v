`timescale 1ns/1ps

module id_stage_tb;

reg clk, reset;
reg [31:0] instr;
reg reg_write;
reg [4:0] rd;
reg [31:0] write_data;

wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] imm;

id_stage dut (
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

always #5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, id_stage_tb);

    clk = 0;
    reset = 1;
    instr = 0;
    reg_write = 0;
    rd = 0;
    write_data = 0;

    #10 reset = 0;

    // Write 42 to x1
    reg_write = 1;
    rd = 5'd1;
    write_data = 32'd42;

    #10 reg_write = 0;

    // Provide instruction: add x3, x1, x2
    instr = 32'b0000000_00010_00001_000_00011_0110011;

    #10;

    $display("rs1_data = %d, rs2_data = %d, imm = %d", rs1_data, rs2_data, imm);
    $stop;
end

endmodule
