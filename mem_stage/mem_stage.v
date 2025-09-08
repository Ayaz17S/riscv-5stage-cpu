module mem_stage (
    input clk,
    input mem_read, // mem_read is no longer used for read logic, but kept for consistency
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

    // 256 x 32-bit memory = 1KB
    reg [31:0] data_mem [0:255];
    integer i; // ✅ MOVED declaration to module scope

    // Initialize memory to a known state to prevent X's at the start
    initial begin
        for (i = 0; i < 256; i = i + 1)
            data_mem[i] = 32'b0;
    end

    // WRITE LOGIC - Synchronous (occurs on clock edge)
    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[addr[9:2]] <= write_data;
        end
    end

    // ✅ CORRECTED READ LOGIC - Purely Combinational
    // The output `read_data` always reflects the memory content at `addr`.
    // The control logic in the WB stage will decide if this data is used.
    assign read_data = data_mem[addr[9:2]];

endmodule

