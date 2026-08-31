module Hazard_Unit(Rs1_ID, Rs2_ID, Rd_EX, MemRead_EX, branch_EX, zero_EX, AXI_STALL, stall, flush, stall_all);
input [4:0] Rs1_ID, Rs2_ID, Rd_EX;
input MemRead_EX, branch_EX, zero_EX, AXI_STALL;
output reg stall, flush, stall_all;
always @(*) begin
  // stall_all for memory bus
  stall_all = AXI_STALL;

  // load-use stall
  if(MemRead_EX && ((Rd_EX == Rs1_ID) || (Rd_EX == Rs2_ID)))
    stall = 1'b1;
  else
    stall = 1'b0;
  // branch flush
  if(branch_EX && zero_EX)
    flush = 1'b1;
  else
    flush = 1'b0;
end
endmodule
