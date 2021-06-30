`timescale 1ns / 1ps

module testbench_for_cosinus();

reg clk;
reg reset;
reg [2:0] aci; // 
wire [17:0]cos_out;

integer i;

CosLookUp uut(clk,reset,aci,cos_out);

always #5 clk=~clk;

initial begin

clk=1;
reset=1;
#50;
reset=0;

for (i=0;i<=7;i=i+1) begin
    aci=i;
    #10;
end

end

endmodule
