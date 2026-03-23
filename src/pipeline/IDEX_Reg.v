module IDEX_Reg(clk, rst, flush, RegWrite_in, MemtoReg_in, branch_in, MemRead_in, MemWrite_in, ALUSrc_in, func7b_in, ALUOp_in, func3_in, Rs1_in, Rs2_in, Rd_in, PC_in, Rd1_in, Rd2_in, immext_in, RegWrite_out, MemtoReg_out, branch_out, MemRead_out, MemWrite_out, ALUSrc_out, func7b_out, ALUOp_out, func3_out, Rs1_out, Rs2_out, Rd_out, PC_out, Rd1_out, Rd2_out, immext_out);
input clk, rst, flush;
input RegWrite_in, MemtoReg_in, branch_in, MemRead_in, MemWrite_in, ALUSrc_in, func7b_in;
input [1:0] ALUOp_in;
input [2:0] func3_in;
input [4:0] Rs1_in, Rs2_in, Rd_in;
input [31:0] PC_in, Rd1_in, Rd2_in, immext_in;
output reg RegWrite_out, MemtoReg_out, branch_out, MemRead_out, MemWrite_out, ALUSrc_out, func7b_out;
output reg [1:0] ALUOp_out;
output reg [2:0] func3_out;
output reg [4:0] Rs1_out, Rs2_out, Rd_out;
output reg [31:0] PC_out, Rd1_out, Rd2_out, immext_out;
always@(posedge clk or posedge rst) begin
  if(rst || flush) begin
    RegWrite_out<=1'b0; MemtoReg_out<=1'b0; branch_out<=1'b0; MemRead_out<=1'b0;
    MemWrite_out<=1'b0; ALUSrc_out<=1'b0; func7b_out<=1'b0; ALUOp_out<=2'b0;
    func3_out<=3'b0; Rs1_out<=5'b0; Rs2_out<=5'b0; Rd_out<=5'b0;
    PC_out<=32'b0; Rd1_out<=32'b0; Rd2_out<=32'b0; immext_out<=32'b0;
  end
  else begin
    RegWrite_out<=RegWrite_in; MemtoReg_out<=MemtoReg_in; branch_out<=branch_in;
    MemRead_out<=MemRead_in; MemWrite_out<=MemWrite_in; ALUSrc_out<=ALUSrc_in;
    func7b_out<=func7b_in; ALUOp_out<=ALUOp_in; func3_out<=func3_in;
    Rs1_out<=Rs1_in; Rs2_out<=Rs2_in; Rd_out<=Rd_in;
    PC_out<=PC_in; Rd1_out<=Rd1_in; Rd2_out<=Rd2_in; immext_out<=immext_in;
  end
end
endmodule