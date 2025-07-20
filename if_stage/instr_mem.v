module instr_mem(
    input [31:0] addr,
    output [31:0] instr
);

reg [31:0] mem [0:255];  

initial begin
    $readmemh("if_stage/instr_mem.hex", mem);  // Adjust path if needed
end

assign instr = mem[addr[9:2]];  // Assuming word-aligned instructions

endmodule
