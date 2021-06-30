`timescale 1ns / 1ps

module SinLookUp(clk,reset,eksi,aci,sin_normal_out,sin_minus_out,sin_out);
input [2:0]aci; //  7 ADET ACI BULUNMAKTADIR
input eksi;
input clk,reset;

output reg signed [16:0]sin_normal_out;  // FORMAT Q7.10
output reg signed [16:0]sin_minus_out;   // FORMAT Q7.10
output signed [16:0] sin_out; // FORMAT Q7.10


always@(posedge clk) begin

      if (reset) begin      
         sin_normal_out <= 17'd0;
         sin_minus_out  <= 17'd0;
      end
      else begin 
            if (eksi==0) begin
                case(aci)
                3'b000 : sin_normal_out  <= 17'b0000000_0000000000; //0
                3'b001 : sin_normal_out  <= 17'b0000000_0100001001; //15 ** radian value
              //3'b010 : sin_normal_out  <= 17'b1111111_0000001100; //30
                3'b010 : sin_normal_out  <= 17'b0000000_1000000000; //30 **
                3'b011 : sin_normal_out  <= 17'b0000000_1011100000; //45 **
              //3'b100 : sin_normal_out  <= 17'b1111111_1011000101; //60
                3'b100 : sin_normal_out  <= 17'b0000000_1101110110; //60 **
              //3'd101 : sin_normal_out  <= 17'b1111111_1001110010; //75
                3'b101 : sin_normal_out  <= 17'b0000000_1111011101; //75 **
              //3'd110 : sin_normal_out  <= 17'b0000000_1110010011; //90
                3'b110 : sin_normal_out  <= 17'b0000001_0000000000; //90 **
                endcase
             end
           
            else if (eksi==1) begin //sin_eksi_aci
                case(aci) 
                3'b000 : sin_minus_out  <= 17'b0000000_0000000000; //0
                //3'b001 : sin_minus_out  <= 17'b1111111_0101100110; //-15
                3'b001 : sin_minus_out  <= 17'b1111111_1011110110; //-15 **
                //3'b010 : sin_minus_out  <= 17'b0000000_1111110011; //-30
                3'b010 : sin_minus_out  <= 17'b1111111_1000000000; //-30 
                3'b011 : sin_minus_out  <= 17'b1111111_0100100001; //-45 **
              //3'b100 : sin_minus_out  <= 17'b0000000_0100111000; //-60
                3'b100 : sin_minus_out  <= 17'b1111111_0010001001; //-60 **
              //3'b101 : sin_minus_out  <= 17'b0000000_0110001101; //-75
                3'b101 : sin_minus_out  <= 17'b1111111_0000100010; //-75 **
                //3'b110 : sin_minus_out  <= 17'b1111111_0001101100; //-90
                3'b110 : sin_minus_out  <= 17'b1111111_0000000000; //-90 **
                endcase
           end
     end 
end
    
assign sin_out = (eksi) ? sin_minus_out : sin_normal_out ; 

endmodule