module reg_file (
    input clk,
    input reset,
    input reg_write,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);

reg [31:0] regs [0:31];

assign rs1_data = (rs1 != 0) ? regs[rs1] : 32'b0;
assign rs2_data = (rs2 != 0) ? regs[rs2] : 32'b0;

always @(posedge clk or posedge reset) begin
    if (reset) begin : reset_block
        integer i;
        for (i = 0; i < 32; i = i + 1)
            regs[i] <= 32'b0;
    end else if (reg_write && rd != 0) begin
        regs[rd] <= write_data;
    end
end


endmodule
