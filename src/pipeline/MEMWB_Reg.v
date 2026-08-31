module MEMWB_Reg(clk, rst, stall_all, RegWrite_in, MemtoReg_in, Rd_in, ALU_Result_in, MemData_in, RegWrite_out, MemtoReg_out, Rd_out, ALU_Result_out, MemData_out);
input clk, rst, stall_all;
input RegWrite_in, MemtoReg_in;
input [4:0] Rd_in;
input [31:0] ALU_Result_in, MemData_in;
output reg RegWrite_out, MemtoReg_out;
output reg [4:0] Rd_out;
output reg [31:0] ALU_Result_out, MemData_out;
always @(posedge clk or posedge rst) begin
  if(rst) begin
    RegWrite_out<=1'b0; MemtoReg_out<=1'b0;
    Rd_out<=5'b0;
    ALU_Result_out<=32'b0; MemData_out<=32'b0;
  end
  else if (!stall_all) begin
    RegWrite_out<=RegWrite_in; MemtoReg_out<=MemtoReg_in;
    Rd_out<=Rd_in;
    ALU_Result_out<=ALU_Result_in; MemData_out<=MemData_in;
  end
end
endmodule
