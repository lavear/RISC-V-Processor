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