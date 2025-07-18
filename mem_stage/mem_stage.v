module mem_stage (
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] data_mem[0:255] ;
always @(posedge clk) begin
    if (mem_write) begin
        data_mem[addr[9:2]]<=write_data;
    end
end
assign read_data = mem_read?data_mem[addr[9:2]]:32'b0;
    
endmodule