module IFID_Reg(clk, rst, flush, stall, PC_in, inst_in, PC_out, inst_out);
input clk, rst, flush, stall;
input [31:0] PC_in;
input [31:0] inst_in;
output reg [31:0] PC_out;
output reg [31:0] inst_out;
always @(posedge clk or posedge rst) begin
  if(rst || flush) begin
    PC_out<=32'b0;
    inst_out<=32'b0;
  end
  else if(!stall) begin
    PC_out<=PC_in;
    inst_out<=inst_in;
  end
end
endmodule