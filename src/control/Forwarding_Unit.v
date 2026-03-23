module Forwarding_Unit(Rs1_EX, Rs2_EX, Rd_MEM, Rd_WB, RegWrite_MEM, RegWrite_WB, ForwardA, ForwardB);
input [4:0] Rs1_EX, Rs2_EX, Rd_MEM, Rd_WB;
input RegWrite_MEM, RegWrite_WB;
output reg [1:0] ForwardA, ForwardB;
always @(*) begin
  // ForwardA
  if(RegWrite_MEM && (Rd_MEM != 5'b0) && (Rd_MEM == Rs1_EX))
    ForwardA = 2'b10;
  else if(RegWrite_WB && (Rd_WB != 5'b0) && (Rd_WB == Rs1_EX))
    ForwardA = 2'b01;
  else
    ForwardA = 2'b00;
  // ForwardB
  if(RegWrite_MEM && (Rd_MEM != 5'b0) && (Rd_MEM == Rs2_EX))
    ForwardB = 2'b10;
  else if(RegWrite_WB && (Rd_WB != 5'b0) && (Rd_WB == Rs2_EX))
    ForwardB = 2'b01;
  else
    ForwardB = 2'b00;
end
endmodule