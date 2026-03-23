module Mux(sel, A, B, Mux_out);
input sel;
input [31:0] A, B;
output [31:0] Mux_out;
assign Mux_out = (sel==1'b0)? A: B;
endmodule