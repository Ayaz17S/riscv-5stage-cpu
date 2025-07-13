module if_stage(
    input clk,
    input reset,
    input pc_write,
    output [31:0] instr,
    output [31:0] pc_out
);

wire [31:0] pc_next;
wire [31:0] pc_curr;

assign pc_next =pc_curr+4;

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