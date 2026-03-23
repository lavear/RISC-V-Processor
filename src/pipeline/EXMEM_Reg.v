module EXMEM_Reg(clk, rst, RegWrite_in, MemtoReg_in, branch_in, MemRead_in, MemWrite_in, zero_in, Rd_in, Sum_in, ALU_Result_in, Rd2_in, RegWrite_out, MemtoReg_out, branch_out, MemRead_out, MemWrite_out, zero_out, Rd_out, Sum_out, ALU_Result_out, Rd2_out);
input clk, rst;
input RegWrite_in, MemtoReg_in, branch_in, MemRead_in, MemWrite_in, zero_in;
input [4:0] Rd_in;
input [31:0] Sum_in, ALU_Result_in, Rd2_in;
output reg RegWrite_out, MemtoReg_out, branch_out, MemRead_out, MemWrite_out, zero_out;
output reg [4:0] Rd_out;
output reg [31:0] Sum_out, ALU_Result_out, Rd2_out;
always @(posedge clk or posedge rst) begin
  if(rst) begin
    RegWrite_out<=1'b0; MemtoReg_out<=1'b0; branch_out<=1'b0; MemRead_out<=1'b0; MemWrite_out<=1'b0; zero_out<=1'b0;
    Rd_out<=5'b0;
    Sum_out<=32'b0; ALU_Result_out<=32'b0; Rd2_out<=32'b0;
  end
  else begin
    RegWrite_out<=RegWrite_in; MemtoReg_out<=MemtoReg_in; branch_out<=branch_in;
    MemRead_out<=MemRead_in; MemWrite_out<=MemWrite_in; zero_out<=zero_in;
    Rd_out<=Rd_in;
    Sum_out<=Sum_in; ALU_Result_out<=ALU_Result_in; Rd2_out<=Rd2_in;
  end
end
endmodule