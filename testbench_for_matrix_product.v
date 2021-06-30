`timescale 1ns / 1ps

module testbench_for_matrix_product();

reg clk,reset;
reg [2:0] aci,selection; //0=0 , 1=15, 2=30 ...
    
//matrix output locations 31 bits , FORMAT : Q_13_20
wire [32:0] selected_value;

matrix_product uut(.clk(clk),.reset(reset),.aci(aci),.selection(selection),.selected_value(selected_value));

always #5 clk=~clk;

initial begin
    #50;
    clk=1;
    reset=0;
    
    #10 aci=3'b000;
    #100 ;
    #10 selection=3'b000;
    #10 selection=3'b001;
    #10 selection=3'b010;
    #10 selection=3'b011;
    #10 selection=3'b100;
    #10 selection=3'b101;
    #10 selection=3'b110;
    #10 selection=3'b111;
    
      
end

endmodule
