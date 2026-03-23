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