`timescale 1ns / 1ps

module mem_stage_tb;

    // Testbench signals
    reg clk;
    reg mem_read;
    reg mem_write;
    reg [31:0] addr;
    reg [31:0] write_data;
    wire [31:0] read_data;

    // Instantiate the mem_stage module
    mem_stage uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
    $dumpfile("mem_stage.vcd");
    $dumpvars(0, mem_stage_tb); 
        // Initial values
        clk = 0;
        mem_read = 0;
        mem_write = 0;
        addr = 0;
        write_data = 0;

        $display("Starting MEM Stage Test");
        $monitor("Time: %0t | Write=%b | Read=%b | Addr=%h | WData=%d | RData=%d", $time, mem_write, mem_read, addr, write_data, read_data);

        // Write 100 to memory address 8
        #10;
        addr = 32'd8;
        write_data = 32'd100;
        mem_write = 1;
        #10;
        mem_write = 0;

        // Read from address 8
        #10;
        mem_read = 1;
        #10;
        mem_read = 0;

        // Write 55 to address 16
        #10;
        addr = 32'd16;
        write_data = 32'd55;
        mem_write = 1;
        #10;
        mem_write = 0;

        // Read from address 16
        #10;
        mem_read = 1;
        #10;
        mem_read = 0;

        $display("MEM Stage Test Finished.");
        $stop;
    end

endmodule
