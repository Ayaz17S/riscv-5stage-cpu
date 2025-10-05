// ==========================================================
// == Monolithic CPU Testbench (Corrected Paths)
// ==========================================================
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
    always #50 clk = ~clk;

    initial begin
        $dumpfile("cpu_final_waveform.vcd");
        $dumpvars(0, uut);
        
        $display("=== Final RISC-V CPU Test ===");
        
        // Initialize
        clk = 0;
        reset = 1;
        
        // Hold reset for a few cycles
        repeat(5) @(posedge clk);
        reset = 0;
        
        $display("Reset released at time %0t", $time);
        
        // Run for enough cycles to complete the program
        repeat(30) @(posedge clk);
        
        $display("\n=== Test Results Analysis ===");
        $display("Register File Contents:");
        // ✅ CORRECTED HIERARCHICAL PATHS (uut.id_s.RF.regs)
        $display("x1 (Expected: 1) = %h", uut.id_s.RF.regs[1]);
        $display("x2 (Expected: 2) = %h", uut.id_s.RF.regs[2]);
        $display("x3 (Expected: 3) = %h", uut.id_s.RF.regs[3]);
        $display("x4 (Expected: ffffffff) = %h", uut.id_s.RF.regs[4]);
        $display("x5 (Expected: 0) = %h", uut.id_s.RF.regs[5]);
        $display("x6 (Expected: 3) = %h", uut.id_s.RF.regs[6]);
        $display("x7 (Expected: 3) = %h", uut.id_s.RF.regs[7]);
        $display("x8 (Expected: 4) = %h", uut.id_s.RF.regs[8]);
        $display("x12 (Expected: 2) = %h", uut.id_s.RF.regs[12]);
        $display("x14 (Expected: 1) = %h", uut.id_s.RF.regs[14]);
        $display("x15 (Expected: 3) = %h", uut.id_s.RF.regs[15]);
        
        $display("\nCPU Test Completed at time %0t", $time);
        $finish;
    end
endmodule

