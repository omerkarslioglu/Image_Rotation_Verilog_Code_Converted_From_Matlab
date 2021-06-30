`timescale 1ns / 1ps

module testbench_for_sin();

reg clk,reset;
reg[2:0] aci;
reg eksi;
reg mode_switch;
wire signed [16:0] out; // FORMAT : Q7.10

integer i;

sincostop uut(.clk(clk),.reset(reset),.eksi(eksi),.aci(aci),.out(out),.mode_switch(mode_switch));

always #5 clk=~clk;

initial begin

clk=1;
reset=1;
#50;
reset=0;
eksi=0;
#50;

mode_switch=1;

for (i=0;i<=6;i=i+1) begin
    aci=i;
    #10;
end

mode_switch=0;

for (i=0;i<=6;i=i+1) begin
    aci=i;
    #10;
end

#50
eksi=1;

for (i=0;i<=6;i=i+1) begin
    aci=i;
    #10;
end

end


endmodule
