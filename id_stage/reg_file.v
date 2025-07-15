module reg_file (
    input clk,
    input reset,
    input reg_write,
    input [4:0] rs1,rs2,rd,
    input[31:0] write_data,
    output [31:0] rs1_data,rs2_data
);

reg [31:0] registers [0:31];

integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i =0 ;i<32 ;i=i+1 ) begin
            registers[i]<=32'b0;
        end
    end else if (reg_write && rd!=0) begin
        registers[rd]<= write_data;
    end
end

assign rs1_data = (rs1==0)?32'b0 : registers[rs1];
assign rs2_data = (rs2==0)?32'b0 : registers[rs2];
    
endmodule