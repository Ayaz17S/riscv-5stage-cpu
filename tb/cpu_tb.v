`timescale 1ns / 1ps
module cpu_tb;
    reg clk, reset;

    cpu dut (
        .clk(clk),
        .reset(reset)
    );


    // Clock generation
    always #5 clk = ~clk;

    initial begin
     initial begin
    $dumpfile("cpu_tb.vcd");

    // Dump CPU testbench and submodules
    $dumpvars(0, cpu_tb);        // Dump top-level tb
    $dumpvars(1, cpu_tb.dut);    // Dump CPU instance
    $dumpvars(1, cpu_tb.dut.if_u);
    $dumpvars(1, cpu_tb.dut.id_u);
    $dumpvars(1, cpu_tb.dut.if_u.PC);
    $dumpvars(1, cpu_tb.dut.if_u.IMEM);
    $dumpvars(1, cpu_tb.dut.id_u.REGFILE);
    $dumpvars(1, cpu_tb.dut.id_u.IMMGEN);
end
 

        // Release reset after some time
        #10 reset = 0;

        // Let it run for a while
        #100 $finish;
    end

endmodule
