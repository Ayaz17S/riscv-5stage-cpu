`timescale 1ns / 1ps

module wb_stage_tb;

    // Inputs
    reg [31:0] alu_result;
    reg [31:0] mem_data;
    reg mem_to_reg;

    // Output
    wire [31:0] write_back_data;

    // Instantiate the Unit Under Test (UUT)
    wb_stage uut (
        .alu_result(alu_result),
        .mem_data(mem_data),
        .mem_to_reg(mem_to_reg),
        .write_back_data(write_back_data)
    );

    initial begin
        // Optional: VCD for waveform
        $dumpfile("wb_stage.vcd");
        $dumpvars(0, wb_stage_tb);

        // Test Case 1: mem_to_reg = 0 → ALU result should be written back
        alu_result = 32'hAAAA_AAAA;
        mem_data = 32'h5555_5555;
        mem_to_reg = 0;
        #10;
        $display("mem_to_reg = %b, write_back_data = %h", mem_to_reg, write_back_data);

        // Test Case 2: mem_to_reg = 1 → Memory data should be written back
        alu_result = 32'h1234_5678;
        mem_data = 32'hDEAD_BEEF;
        mem_to_reg = 1;
        #10;
        $display("mem_to_reg = %b, write_back_data = %h", mem_to_reg, write_back_data);

        $finish;
    end

endmodule
