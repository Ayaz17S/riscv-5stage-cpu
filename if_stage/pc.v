module pc(
    input clk,
    input reset,
    input pc_write,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);

always @(posedge clk or  posedge reset) begin
    if (reset) begin
        pc_out<=32'b0;
    end else if (pc_write) begin
        pc_out<=pc_in;
    end
end
endmodule