//Program Counter
module Program_Counter(clk, rst, PC_in, PC_out);
input clk, rst;
input [31:0] PC_in;
output reg [31:0] PC_out;
always @(posedge clk or posedge rst) begin
  if(rst)
    PC_out<=32'b00;
  else
    PC_out<=PC_in;
end
endmodule

//PC+4
module PC_increment(fromPC, NextoPC);
input [31:0]fromPC;
output [31:0]NextoPC;
assign NextoPC = fromPC + 4;
endmodule

//Instruction Memory (ROM)
module Instruction_Mem(rst, read_addr, inst_out);
input rst;
input [31:0] read_addr;
output [31:0] inst_out;

reg [31:0] I_Mem[63:0];
integer k;

initial begin
  for (k = 0; k < 64; k = k + 1) begin
      I_Mem[k] = 32'b0;
  end

  I_Mem[0]  = 32'b00000000000000000000000000000000;      // NOP
  I_Mem[1]  = 32'b0000000_11001_10000_000_01101_0110011; // add x13, x16, x25
  I_Mem[2]  = 32'b0100000_00011_01000_000_00101_0110011; // sub x5, x8, x3
  I_Mem[3]  = 32'b0000000_00011_00010_111_00001_0110011; // and x1, x2, x3
  I_Mem[4]  = 32'b0000000_00101_00011_110_00100_0110011; // or x4, x3, x5
  I_Mem[5]  = 32'b000000000011_10101_000_10110_0010011;  // addi x22, x21, 3
  I_Mem[6]  = 32'b000000000001_01000_110_01001_0010011;  // ori x9, x8, 1
  I_Mem[7]  = 32'b000000001111_00101_010_01000_0000011;  // lw x8, 15(x5)
  I_Mem[8]  = 32'b000000000011_00011_010_01001_0000011;  // lw x9, 3(x3)
  I_Mem[9]  = 32'b0000000_01111_00101_010_01100_0100011; // sw x15, 12(x5)
  I_Mem[10] = 32'b0000000_01110_00110_010_01010_0100011; // sw x14, 10(x6)
  I_Mem[11] = 32'h00948663;                              // beq x9, x9, 12
end

assign inst_out = I_Mem[read_addr[31:2]];
endmodule

//IF/ID Pipeline Register
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

//Register
module Reg_File(clk, rst, RegWrite, Rs1, Rs2, Rd, Write_data, read_data1, read_data2);
input clk, rst, RegWrite;
input [4:0] Rs1, Rs2, Rd;
input [31:0] Write_data;
output [31:0] read_data1, read_data2;
reg[31:0] Registers[31:0];
integer k;
initial begin
  Registers[0] = 0; Registers[1] = 4; Registers[2] = 2; Registers[3] = 24;
  Registers[4] = 4; Registers[5] = 1; Registers[6] = 44; Registers[7] = 4;
  Registers[8] = 2; Registers[9] = 1; Registers[10] = 23; Registers[11] = 4;
  Registers[12] = 90; Registers[13] = 10; Registers[14] = 20; Registers[15] = 30;
  Registers[16] = 40; Registers[17] = 50; Registers[18] = 60; Registers[19] = 70;
  Registers[20] = 80; Registers[21] = 80; Registers[22] = 90; Registers[23] = 70;
  Registers[24] = 60; Registers[25] = 65; Registers[26] = 4; Registers[27] = 32;
  Registers[28] = 12; Registers[29] = 34; Registers[30] = 5; Registers[31] = 10;
end
always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(k=0; k<32; k=k+1)begin
      Registers[k]=32'b00;
    end
  end
  else if (RegWrite)begin
    if(Rd != 5'd0)
      Registers[Rd]<=Write_data;
  end
end
assign read_data1 = Registers[Rs1];
assign read_data2 = Registers[Rs2];
endmodule

//Immediate Generator
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

//Control Unit
module control_unit(instruction, branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
input [6:0]instruction;
output reg branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
output reg [1:0]ALUOp;
always@(*) begin
  case (instruction)
  7'b0110011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b001000_10; // R-type
  7'b0010011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b101000_10;
  7'b0000011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b111100_00; // Load
  7'b0100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b100010_00; // Store
  7'b1100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b000001_01; // Branch
  default: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} = 8'b000000_00;
  endcase
end
endmodule

//ID/EX Pipeline Register
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

//EX/MEM Pipeline Register
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

//MEM/WB Pipeline Register
module MEMWB_Reg(clk, rst, RegWrite_in, MemtoReg_in, Rd_in, ALU_Result_in, MemData_in, RegWrite_out, MemtoReg_out, Rd_out, ALU_Result_out, MemData_out);
input clk, rst;
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
  else begin
    RegWrite_out<=RegWrite_in; MemtoReg_out<=MemtoReg_in;
    Rd_out<=Rd_in;
    ALU_Result_out<=ALU_Result_in; MemData_out<=MemData_in;
  end
end
endmodule

//Forwarding Unit
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

//Hazard Detection Unit
// HIPNU FIX: Changed branch_ID to branch_EX to prevent premature pipeline flushing!
module Hazard_Unit(Rs1_ID, Rs2_ID, Rd_EX, MemRead_EX, branch_EX, zero_EX, stall, flush);
input [4:0] Rs1_ID, Rs2_ID, Rd_EX;
input MemRead_EX, branch_EX, zero_EX;
output reg stall, flush;
always @(*) begin
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

//ALU
module ALU_unit(A, B, Control_in, ALU_Result, zero);
input [31:0] A, B;
input [3:0] Control_in;
output reg zero;
output reg [31:0] ALU_Result;
always @(Control_in or A or B) begin
  case(Control_in)
  4'b0000: ALU_Result = A & B;
  4'b0001: ALU_Result = A | B;
  4'b0010: ALU_Result = A + B;
  4'b0110: ALU_Result = A - B;
  default: ALU_Result = 32'b0;
  endcase

  if(ALU_Result == 32'b0) zero = 1'b1;
  else zero = 1'b0;
end
endmodule

//ALU Control
module ALU_Control(ALUOp, bit30, func3, Control_out);
input bit30;
input [2:0] func3;
input [1:0] ALUOp;
output reg [3:0] Control_out;
always @(*) begin
  casez({ALUOp, bit30, func3})
  6'b00_0_000: Control_out = 4'b0010;
  6'b01_0_000: Control_out = 4'b0110;
  6'b10_0_000: Control_out = 4'b0010;
  6'b10_1_000: Control_out = 4'b0110;
  6'b10_0_111: Control_out = 4'b0000;
  6'b10_0_110: Control_out = 4'b0001;
  default: Control_out = 4'b0000;
  endcase
end
endmodule

//Data Memory
module Data_Memory(clk, rst, MemWrite, MemRead, address, Write_data, MemData_out);
input clk, rst, MemWrite, MemRead;
input [31:0] address, Write_data;
output [31:0] MemData_out;
integer k;
reg [31:0] D_Memory[63:0];
always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(k=0; k<64; k=k+1) begin
      D_Memory[k] = 32'b0;
    end
  end
  else if(MemWrite) begin
    D_Memory[address[31:2]] <= Write_data;
  end
end
assign MemData_out = (MemRead) ? D_Memory[address[31:2]] : 32'b00;
endmodule

//Multiplexers
module Mux(sel, A, B, Mux_out);
input sel;
input [31:0] A, B;
output [31:0] Mux_out;
assign Mux_out = (sel==1'b0)? A: B;
endmodule

//3-to-1 Mux for forwarding
module Mux3(sel, A, B, C, Mux_out);
input [1:0] sel;
input [31:0] A, B, C;
output reg [31:0] Mux_out;
always @(*) begin
  case(sel)
  2'b00: Mux_out = A;
  2'b01: Mux_out = B;
  2'b10: Mux_out = C;
  default: Mux_out = A;
  endcase
end
endmodule

//AND Logic
module AND_logic(branch, zero, and_out);
input branch, zero;
output and_out;
assign and_out = branch & zero;
endmodule

//Adder logic
module adder_logic(in1, in2, sum_out);
input [31:0]in1, in2;
output [31:0]sum_out;
assign sum_out = in1+in2;
endmodule

//All modules instantiate here
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

// HIPNU FIX: Connected branch_EX here to match the timing fix in the Hazard_Unit
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
  .RegWrite_out(RegWrite_MEM), .MemtoReg_MEM(MemtoReg_MEM), .branch_out(branch_MEM), .MemRead_out(MemRead_MEM), .MemWrite_out(MemWrite_MEM), .zero_out(zero_MEM), .Rd_out(Rd_MEM), .Sum_out(Sum_MEM), .ALU_Result_out(ALU_Result_MEM), .Rd2_out(Rd2_MEM)
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

// testbench
module tb_top;
reg clk, rst;
top uut(.clk(clk), .rst(rst));

initial begin
    clk = 0;
    rst = 1;
    #12;
    rst = 0;
    #400;
    $stop;
end

always begin
    #5 clk = ~clk;
end
endmodule