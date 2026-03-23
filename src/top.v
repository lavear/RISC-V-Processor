module top(clk, rst);
input clk, rst;

wire [31:0] PCin_top;
wire stall_top, flush_top;

wire [31:0] PC_IF, inst_IF, NextoPC_IF;

wire [31:0] PC_ID, inst_ID;
wire [31:0] Rd1_ID, Rd2_ID, immext_ID;
wire RegWrite_ID, ALUSrc_ID, branch_ID, MemtoReg_ID, MemWrite_ID, MemRead_ID;
wire [1:0] ALUOp_ID;

wire [31:0] PC_EX, Rd1_EX, Rd2_EX, immext_EX;
wire [4:0] Rs1_EX, Rs2_EX, Rd_EX;
wire RegWrite_EX, ALUSrc_EX, branch_EX, MemtoReg_EX, MemWrite_EX, MemRead_EX, func7b_EX;
wire [1:0] ALUOp_EX;
wire [2:0] func3_EX;
wire [3:0] control_EX;
wire [31:0] fwdA_EX, fwdB_EX, muxB_EX, ALU_Result_EX, Sum_EX;
wire [1:0] ForwardA_EX, ForwardB_EX;
wire zero_EX;

wire RegWrite_MEM, MemtoReg_MEM, branch_MEM, MemRead_MEM, MemWrite_MEM, zero_MEM;
wire [4:0] Rd_MEM;
wire [31:0] Sum_MEM, ALU_Result_MEM, Rd2_MEM, MemData_MEM;
wire sel2_MEM;

wire RegWrite_WB, MemtoReg_WB;
wire [4:0] Rd_WB;
wire [31:0] ALU_Result_WB, MemData_WB, WriteBack_WB;

Program_Counter PC(.clk(clk), .rst(rst), .PC_in(PCin_top), .PC_out(PC_IF));
PC_increment PCA(.fromPC(PC_IF), .NextoPC(NextoPC_IF));
Instruction_Mem IM(.rst(rst), .read_addr(PC_IF), .inst_out(inst_IF));

IFID_Reg IFID1(
  .clk(clk), .rst(rst), .flush(flush_top), .stall(stall_top),
  .PC_in(PC_IF), .inst_in(inst_IF),
  .PC_out(PC_ID), .inst_out(inst_ID)
);

Reg_File RF(.clk(clk), .rst(rst), .RegWrite(RegWrite_WB), .Rs1(inst_ID[19:15]), .Rs2(inst_ID[24:20]), .Rd(Rd_WB), .Write_data(WriteBack_WB), .read_data1(Rd1_ID), .read_data2(Rd2_ID));
ImmGen IG(.opcode(inst_ID[6:0]), .inst(inst_ID), .imm_ext(immext_ID));
control_unit CU(.instruction(inst_ID[6:0]), .branch(branch_ID), .MemRead(MemRead_ID), .MemtoReg(MemtoReg_ID), .ALUOp(ALUOp_ID), .MemWrite(MemWrite_ID), .ALUSrc(ALUSrc_ID), .RegWrite(RegWrite_ID));

Hazard_Unit HU(
  .Rs1_ID(inst_ID[19:15]), .Rs2_ID(inst_ID[24:20]), .Rd_EX(Rd_EX),
  .MemRead_EX(MemRead_EX), .branch_EX(branch_EX), .zero_EX(zero_EX),
  .stall(stall_top), .flush(flush_top)
);

IDEX_Reg IDEX1(
  .clk(clk), .rst(rst), .flush(flush_top),
  .RegWrite_in(RegWrite_ID), .MemtoReg_in(MemtoReg_ID), .branch_in(branch_ID), .MemRead_in(MemRead_ID), .MemWrite_in(MemWrite_ID), .ALUSrc_in(ALUSrc_ID), .func7b_in(inst_ID[30]), .ALUOp_in(ALUOp_ID), .func3_in(inst_ID[14:12]), .Rs1_in(inst_ID[19:15]), .Rs2_in(inst_ID[24:20]), .Rd_in(inst_ID[11:7]), .PC_in(PC_ID), .Rd1_in(Rd1_ID), .Rd2_in(Rd2_ID), .immext_in(immext_ID),
  .RegWrite_out(RegWrite_EX), .MemtoReg_out(MemtoReg_EX), .branch_out(branch_EX), .MemRead_out(MemRead_EX), .MemWrite_out(MemWrite_EX), .ALUSrc_out(ALUSrc_EX), .func7b_out(func7b_EX), .ALUOp_out(ALUOp_EX), .func3_out(func3_EX), .Rs1_out(Rs1_EX), .Rs2_out(Rs2_EX), .Rd_out(Rd_EX), .PC_out(PC_EX), .Rd1_out(Rd1_EX), .Rd2_out(Rd2_EX), .immext_out(immext_EX)
);

Forwarding_Unit FU(
  .Rs1_EX(Rs1_EX), .Rs2_EX(Rs2_EX), .Rd_MEM(Rd_MEM), .Rd_WB(Rd_WB),
  .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB),
  .ForwardA(ForwardA_EX), .ForwardB(ForwardB_EX)
);

ALU_Control ALC(.ALUOp(ALUOp_EX), .bit30(func7b_EX), .func3(func3_EX), .Control_out(control_EX));
Mux3 FwdMuxA(.sel(ForwardA_EX), .A(Rd1_EX), .B(WriteBack_WB), .C(ALU_Result_MEM), .Mux_out(fwdA_EX));
Mux3 FwdMuxB(.sel(ForwardB_EX), .A(Rd2_EX), .B(WriteBack_WB), .C(ALU_Result_MEM), .Mux_out(fwdB_EX));
Mux Mux1(.sel(ALUSrc_EX), .A(fwdB_EX), .B(immext_EX), .Mux_out(muxB_EX));
ALU_unit ALUU(.A(fwdA_EX), .B(muxB_EX), .Control_in(control_EX), .ALU_Result(ALU_Result_EX), .zero(zero_EX));
adder_logic AD1(.in1(PC_EX), .in2(immext_EX), .sum_out(Sum_EX));

EXMEM_Reg EXMEM1(
  .clk(clk), .rst(rst),
  .RegWrite_in(RegWrite_EX), .MemtoReg_in(MemtoReg_EX), .branch_in(branch_EX), .MemRead_in(MemRead_EX), .MemWrite_in(MemWrite_EX), .zero_in(zero_EX), .Rd_in(Rd_EX), .Sum_in(Sum_EX), .ALU_Result_in(ALU_Result_EX), .Rd2_in(fwdB_EX),
  .RegWrite_out(RegWrite_MEM), .MemtoReg_out(MemtoReg_MEM), .branch_out(branch_MEM), .MemRead_out(MemRead_MEM), .MemWrite_out(MemWrite_MEM), .zero_out(zero_MEM), .Rd_out(Rd_MEM), .Sum_out(Sum_MEM), .ALU_Result_out(ALU_Result_MEM), .Rd2_out(Rd2_MEM)
);

AND_logic AND1(.branch(branch_MEM), .zero(zero_MEM), .and_out(sel2_MEM));
Mux Mux2(.sel(sel2_MEM), .A(NextoPC_IF), .B(Sum_MEM), .Mux_out(PCin_top));
Data_Memory DM(.clk(clk), .rst(rst), .MemWrite(MemWrite_MEM), .MemRead(MemRead_MEM), .address(ALU_Result_MEM), .Write_data(Rd2_MEM), .MemData_out(MemData_MEM));

MEMWB_Reg MEMWB1(
  .clk(clk), .rst(rst),
  .RegWrite_in(RegWrite_MEM), .MemtoReg_in(MemtoReg_MEM), .Rd_in(Rd_MEM), .ALU_Result_in(ALU_Result_MEM), .MemData_in(MemData_MEM),
  .RegWrite_out(RegWrite_WB), .MemtoReg_out(MemtoReg_WB), .Rd_out(Rd_WB), .ALU_Result_out(ALU_Result_WB), .MemData_out(MemData_WB)
);

Mux Mux3(.sel(MemtoReg_WB), .A(ALU_Result_WB), .B(MemData_WB), .Mux_out(WriteBack_WB));
endmodule