// mem_stage_tb.v
`timescale 1ns/1ps
module mem_stage_tb;

reg clk, mem_read, mem_write;
reg [31:0] addr, write_data;
wire [31:0] read_data;

mem_stage dut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);

initial begin
    $dumpfile("mem_stage.vcd");
    $dumpvars(0, mem_stage_tb);

    clk = 0;
    mem_read = 0;
    mem_write = 0;
    addr = 0;
    write_data = 0;

    // Write to address 0x08
    #5 addr = 32'h08;
       write_data = 32'hDEADBEEF;
       mem_write = 1;

    #5 clk = 1;  // Rising edge: write happens
    #5 clk = 0;
       mem_write = 0;

    // Read from address 0x08
    #5 mem_read = 1;

    #5 $display("Read Data: %h", read_data); // Expect DEADBEEF
    #5 mem_read = 0;

    // Read from uninitialized address
    #5 addr = 32'h0C;
       mem_read = 1;
    #5 $display("Read Data (uninitialized): %h", read_data); // Expect 0

    #10 $finish;
end

endmodule
