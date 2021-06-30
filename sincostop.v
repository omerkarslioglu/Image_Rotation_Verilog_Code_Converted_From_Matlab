`timescale 1ns / 1ps

module sincostop(clk,reset,eksi,aci,mode_switch,out);
    
    input clk,reset;
    input[2:0] aci;
    input eksi;
    input mode_switch;
   
    output signed [16:0] out; // FORMAT : Q7.10
    
    wire signed [16:0] SinOut;
    wire signed [16:0] CosOut;
    wire signed [16:0] sin_min;
 
    reg [2:0] count=3'd0;

    assign out = (mode_switch) ? SinOut : CosOut;
    
    SinLookUp SinusLookUp(.clk(clk),.reset(reset),.eksi(eksi),.aci(aci),.sin_out(SinOut));
    CosLookUp CosinusLookUp (.clk(clk),.reset(reset),.aci(aci), .cos_out(CosOut));

endmodule