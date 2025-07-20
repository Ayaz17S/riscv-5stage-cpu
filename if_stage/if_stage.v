module if_stage(
    input clk,
    input reset,
    input pc_write,
    input branch_taken,              // <-- NEW
    input [31:0] branch_addr,        // <-- NEW
    output [31:0] instr,
    output [31:0] pc_out
);

    wire [31:0] pc_next;
    wire [31:0] pc_curr;

    // Choose next PC: branch target or sequential
    assign pc_next = branch_taken ? branch_addr : (pc_curr + 4);

    pc PC (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_in(pc_next),
        .pc_out(pc_curr)
    );

    instr_mem IMEM (
        .addr(pc_curr),
        .instr(instr)
    );

    assign pc_out = pc_curr;
endmodule
