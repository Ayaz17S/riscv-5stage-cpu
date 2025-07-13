`timescale 1ns/1ps

module if_stage_tb;

    reg clk, reset, pc_write;
    wire [31:0] instr;
    wire [31:0] pc_out;

 if_stage uut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .instr(instr),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("if_stage.vcd");
        $dumpvars(0, if_stage_tb);

        clk = 0;
        reset = 1;
        pc_write = 0;

        #10;
        reset =0;
        pc_write=1;
        repeat (5) @(posedge clk);

        $finish;
    end

endmodule