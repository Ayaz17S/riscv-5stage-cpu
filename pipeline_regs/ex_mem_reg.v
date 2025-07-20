module ex_mem_reg (
    input clk,
    input reset,

    // Control signals
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input reg_write_in,

    // Data signals
    input [31:0] alu_result_in,
    input [31:0] rs2_data_in,  // Needed for sw
    input [4:0] rd_in,
    input zero_in,

    // Outputs
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg reg_write_out,

    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0] rd_out,
    output reg zero_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        mem_read_out    <= 0;
        mem_write_out   <= 0;
        mem_to_reg_out  <= 0;
        reg_write_out   <= 0;

        alu_result_out  <= 0;
        rs2_data_out    <= 0;
        rd_out          <= 0;
        zero_out        <= 0;
    end else begin
        mem_read_out    <= mem_read_in;
        mem_write_out   <= mem_write_in;
        mem_to_reg_out  <= mem_to_reg_in;
        reg_write_out   <= reg_write_in;

        alu_result_out  <= alu_result_in;
        rs2_data_out    <= rs2_data_in;
        rd_out          <= rd_in;
        zero_out        <= zero_in;
    end
end

endmodule
