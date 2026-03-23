module control_unit(instruction, branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
input [6:0]instruction;
output reg branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
output reg [1:0]ALUOp;
always@(*) begin
  case (instruction)
  7'b0110011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b001000_10; 
  7'b0010011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b101000_10;
  7'b0000011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b111100_00; 
  7'b0100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b100010_00; 
  7'b1100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b000001_01; 
  default: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b000000_00;
  endcase
end
endmodule