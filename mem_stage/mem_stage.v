module mem_stage (
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    // 256 x 32-bit memory = 1KB
    reg [31:0] data_mem [0:255];

    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[addr[9:2]] <= write_data;
        end
    end

    always @(*) begin
        if (mem_read)
            read_data = data_mem[addr[9:2]];
        else
            read_data = 32'b0;
    end

endmodule
