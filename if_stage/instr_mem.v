module instr_mem(
    input [31:0] addr,
    output [31:0] instr
);

 reg [31:0] memory [0:255];

 initial begin
    $readmemh("instr_mem.hex", memory);
 end
 assign instr = memory[addr[9:2]];
 endmodule