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