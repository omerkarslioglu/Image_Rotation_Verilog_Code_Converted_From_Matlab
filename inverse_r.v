
`timescale 1ns / 1ps

module inverse_r(clk, aci,selection_ir,irout);

input clk;
input [2:0] aci = 3'b000;
input [1:0] selection_ir ;
output signed [16:0] irout; 

reg signed [16:0] ir;
reg signed [16:0] ib00,ib01,ib10,ib11;

always@(posedge clk) begin

case (aci)

 3'b000 : begin
        ib00 <= 17'b0000001_0000000000; //Q7.10
        ib01 <= 17'b0000000_0000000000;
        ib10 <=  17'b0000000_0000000000;
        ib11 <=  17'b0000001_0000000000;
 end
 3'b001 : begin 
        ib00 <= 17'b0000000_1111011100;
        ib01 <= 17'b1111111_1011110110;
        ib10 <=  17'b0000000_0100001001;
        ib11 <=  17'b0000000_1111011100;
  end
  3'b010 : begin 
        ib00 <= 17'b0000000_1101110110;
        ib01 <= 17'b1111111_1000000000;
        ib10 <=  17'b0000000_1000000000;
        ib11 <=  17'b0000000_1101110110;
  end  
  3'b011 : begin 
        ib00 <= 17'b0000000_1011010011;
        ib01 <= 17'b1111111_0100101100;
        ib10 <=  17'b0000000_1011010011;
        ib11 <=  17'b0000000_1011010011;
  end 
  3'b100 : begin 
        ib00 <= 17'b0000000_1000000000;
        ib01 <= 17'b1111111_0010001001;
        ib10 <=  17'b0000000_1101110110;
        ib11 <=  17'b0000000_1000000000;
  end   
  3'b101 : begin 

        ib00 <= 17'b0000000_0100001001;
        ib01 <= 17'b1111111_0000100011;
        ib10 <=  17'b0000000_1111011100;
        ib11 <=  17'b0000000_0100001001;
  end  
  3'b110 : begin 
        ib00 <= 17'b0000000_0000000000;
        ib01 <= 17'b1111111_0000000000;
        ib10 <=  17'b0000001_0000000000;
        ib11 <=  17'b0000000_0000000000;         
  end
endcase
    
    case (selection_ir)
        2'b00 : ir<=ib00;
        2'b01 : ir<=ib00;
        2'b10 : ir<=ib00;
        2'b11 : ir<=ib00;
    endcase
end

assign irout=ir;


endmodule