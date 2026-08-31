module Program_Counter(clk, rst, stall_all, PC_in, PC_out);
input clk, rst, stall_all;
input [31:0] PC_in;
output reg [31:0] PC_out;
always @(posedge clk or posedge rst) begin
  if(rst)
    PC_out<=32'b00;
  else if (!stall_all)
    PC_out<=PC_in;
end
endmodule
