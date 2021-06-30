`timescale 1ns / 1ps

module CosLookUp(clk, reset,aci,cos_out);

input reset;
input [2:0] aci; // 
output reg signed [16:0] cos_out;
input clk;

always@(posedge clk) begin

    if (reset)cos_out<= 17'd0;
    else begin
    case(aci)
        3'b000 : cos_out  <= 17'b0000001_0000000000; //0 *
        
      //3'b001 : cos_out  <= 17'b1111111_0011110110; //15
        3'b001 : cos_out  <= 17'b0000000_1111011101; //15 **
        
      //3'b010 : cos_out  <= 17'b0000000_0010011101; //30
        3'b010 : cos_out  <= 17'b0000000_1101110110; //30 **
                                      
        3'b011 : cos_out  <= 17'b0000000_1011100000; //45 **
        
      //3'b100 : cos_out  <= 17'b1111111_0000110000; //60
        3'b100 : cos_out  <= 17'b0000000_1000000000; //60 **
        
      //3'b101 : cos_out  <= 17'b0000000_1010101111; //75
        3'b101 : cos_out  <= 17'b0000000_0100001001; //75 **
        
      //3'b110 : cos_out  <= 17'b1111111_1000110101; //90
        3'b110 : cos_out  <= 17'b0000000_0000000000; //90 **
     endcase
     end    
end
endmodule
