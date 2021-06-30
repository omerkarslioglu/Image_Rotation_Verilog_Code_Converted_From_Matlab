`timescale 1ns / 1ps

`define imageSize 64*64*3

module tb();
 reg [3:0] aci;
 reg clk;
 reg reset;
 reg [23:0] imgData;
 integer file,file1,i;
 
 reg imgDataValid;
 integer sentSize;
 wire [23:0] o_rgb_data;
 wire rgbOutDataValid;
 integer receivedData=0;
 wire line_flag;
 wire [5:0] a;
 wire [5:0] b;
 initial
 begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
 end

 initial
 begin
    reset = 1;
    sentSize = 0;
    imgDataValid = 0;
    aci = 4'b0111;
    #100;
    reset = 0;
    #100;
    file = $fopen("kaplum_color.bin","rb");
    file1 = $fopen("kaplumGrey.bin","wb");

    for(i=0;i<64*64;i=i+1)
    begin
        @(posedge clk);       
        $fscanf(file,"%c%c%c",imgData[7:0],imgData[15:8],imgData[23:16]);
        imgDataValid <= 1'b1; // 0 sa iþlem biter
    end
    
    @(posedge clk);
    imgDataValid <= 1'b0;
    $fclose(file);
 end

 always @(posedge clk)
 begin
     if(rgbOutDataValid && line_flag || (receivedData < 4096 && line_flag))
     begin
         $fwrite(file1,"%c%c%c",o_rgb_data[7:0],o_rgb_data[15:8],o_rgb_data[23:16]);
         receivedData = receivedData+1;
     end 
     //if(receivedData == `imageSize/3 || (a==6'd63 && b==6'd63))
     if(receivedData == `imageSize/3 )
     begin
        $fclose(file1);
        $stop;
     end
 end

resim_okuma dut(
    .axi_clk(clk),
    .reset(reset),
    //slave interface giris
    .i_rgb_data_valid(imgDataValid),
    .i_rgb_data(imgData),
    //master interface cikis
    .o_greyScale_data_valid(rgbOutDataValid),
    .o_rgb_data(o_rgb_data),
    .aci(aci),
    .line_flag(line_flag),
    .a(a),.b(b)
);  

endmodule