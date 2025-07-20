module id_ex_reg (
    input clk,
    input reset,
    input [31:0] pc_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] imm_in,
    input [4:0] rd_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input [6:0] opcode_in,

    // Control signals
    input reg_write_in,
    input alu_src_in,
    input [1:0] alu_op_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input branch_in,

    // Outputs to EX stage
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [6:0] opcode_out,

    // Control signals to EX
    output reg reg_write_out,
    output reg alu_src_out,
    output reg [1:0] alu_op_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out          <= 32'b0;
        rs1_data_out    <= 32'b0;
        rs2_data_out    <= 32'b0;
        imm_out         <= 32'b0;
        rd_out          <= 5'b0;
        funct3_out      <= 3'b0;
        funct7_out      <= 7'b0;
        opcode_out      <= 7'b0;

        reg_write_out   <= 0;
        alu_src_out     <= 0;
        alu_op_out      <= 2'b0;
        mem_read_out    <= 0;
        mem_write_out   <= 0;
        mem_to_reg_out  <= 0;
        branch_out      <= 0;
    end else begin
        pc_out          <= pc_in;
        rs1_data_out    <= rs1_data_in;
        rs2_data_out    <= rs2_data_in;
        imm_out         <= imm_in;
        rd_out          <= rd_in;
        funct3_out      <= funct3_in;
        funct7_out      <= funct7_in;
        opcode_out      <= opcode_in;

        reg_write_out   <= reg_write_in;
        alu_src_out     <= alu_src_in;
        alu_op_out      <= alu_op_in;
        mem_read_out    <= mem_read_in;
        mem_write_out   <= mem_write_in;
        mem_to_reg_out  <= mem_to_reg_in;
        branch_out      <= branch_in;
    end
end

endmodule
