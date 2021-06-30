`timescale 1ns / 1ps

module testbench_rotated_grid();

reg clk,reset;
reg [2:0] aci; 

rotated_grid uut(.clk(clk),.reset(reset),.aci(aci));


initial begin 
clk=1;

#50;
reset=0;

#50 aci=3'b010;
#200;

end

always #5 clk=~clk;

endmodule
