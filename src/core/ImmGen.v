module ImmGen(opcode, inst, imm_ext);
input [6:0]opcode;
input [31:0]inst;
output reg [31:0]imm_ext;
always @(*) begin
  imm_ext = 32'b0;
  case(opcode)
  7'b0000011, 7'b0010011 : imm_ext = {{20{inst[31]}}, inst[31:20]};
  7'b0100011 : imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  7'b1100011 : imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  default: imm_ext = 32'b0;
  endcase
end
endmodule