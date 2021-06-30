`timescale 1ns / 1ps

module resim_okuma(
input    axi_clk,
input    reset,
input    i_rgb_data_valid,
input [23:0] i_rgb_data,
input [3:0] aci,
output reg  o_greyScale_data_valid,
output reg [23:0] o_rgb_data,
output reg line_flag,
output reg [5:0] a=0 ,
output reg [5:0] b=0 
);

//wire [7:0] w_red;
//wire [7:0] w_green;
//wire [7:0] w_blue;

reg [23:0]picture[0:63][0:63]; // 24 bits and 1023 locations
reg [23:0]picture_buffer[0:63][0:63];

reg [6:0]i=0;
reg [5:0]j=0;

reg [5:0] k=6'b111111;
reg [5:0] w=6'b111111;

reg [5:0] buff_sayac_i=5'd0;
reg [5:0] buff_sayac_j=5'd0;

reg [13:0] m ;
reg signed [33:0]x_span_left[0:4300]; //	Q14_20
reg signed [19:0]y_span_down[0:4300]; //   Q10_10

reg signed [16:0]x_r[0:4300];
reg signed [16:0]y_r[0:4300];

reg [19:0]point_span[0:4300] ; // Q10_10
reg [16:0]out_points_span[0:4300] ; // q7.10

reg [2:0] others_state=3'b000;
reg [1:0] in_cords_state=2'b00;

reg signed [32:0] ic1,ic2,ic3,ic4,x_span_left_buff,y_span_down_buff;

wire signed [16:0] x_r_one , y_r_one;

reg process_completed_flag=0;
wire rg_completed_flag ;

reg signed [16:0] y_r_max_value,y_r_min_value,x_r_max_value,x_r_min_value ,out_size_x,out_size_y;

reg [32:0] ops_buff ;

wire [2:0] aci_three_bits;
reg signed [16:0] ir00,ir01,ir10,ir11;
wire signed [16:0] irout;

reg [1:0] selection_ir=2'b00;
reg [2:0]selection_ir_say=3'b000;

reg [1:0] selmaxmin=2'b00;
reg [2:0] selmaxmin_say=3'b000;
wire signed [16:0] outmaxmin;
assign aci_three_bits=aci[2:0];

inverse_r ir(.clk(axi_clk),.aci(aci_three_bits), .selection_ir(selection_ir), .irout(irout));
rotated_grid r_g(.clk(axi_clk) ,.reset(reset),.aci(aci_three_bits) , .selmaxmin(selmaxmin) ,.outmaxmin(outmaxmin),
			 .rg_completed_flag(rg_completed_flag) , .x_r_one(x_r_one) , .y_r_one(y_r_one));

//assign w_red = i_rgb_data[7:0];
//assign w_green = i_rgb_data[15:8];
//assign w_blue = i_rgb_data[23:16];

always @(posedge axi_clk)begin
    if(reset) line_flag<=0;
    else begin
    case(aci) 
        4'b0000 : begin // aci 0'sa veya 360'sa eðer o
            if(i_rgb_data_valid) begin
                if(i<7'd64) begin // resmi memorye bit bit at
                    picture[j][i]=i_rgb_data; // columns rows
                    j<=j+1;
                    if(j>6'd62) begin
                        i<=i+1;
                        j<=0;
                    end
                end  
            end
            if(a<64 && i>=7'd63) begin
                    line_flag<=1 ; // out olarak atama yapmaya baþla
                    b<=b+1; 
                    if(b>6'd62) begin
                        a<=a+1;
                        b<=0;
                    end
                end
                o_rgb_data=picture[b][a]; // output
            
        end
        4'b0001 , 4'b0010 , 4'b0011 , 4'b0100 , 4'b0101 : begin //    15,30,45,60,75 
        //others
        if(rg_completed_flag) begin
                case(selection_ir_say) 
                    3'b000 : begin
                        ir11<=irout;
                        selection_ir<=2'b00;
                        selection_ir_say<=3'b001;
                    end
                    3'b001 : begin
                        ir00<=irout;
                        selection_ir<=2'b01;
                        selection_ir_say<=3'b010;
                    end
                    3'b010 : begin
                        ir01<=irout;
                        selection_ir<=2'b10;
                        selection_ir_say<=3'b011;
                    end
                    3'b011 : begin
                        ir10<=irout;
                        selection_ir<=2'b11;
                        selection_ir_say<=3'b000;
                    end
                endcase
                case(selmaxmin_say) //******************************************************************************
                    3'b000 : begin
                        x_r_min_value<=outmaxmin;
                        selmaxmin<=2'b00;
                        selmaxmin_say<=3'b001;
                    end
                    3'b001 : begin
                        y_r_max_value<=outmaxmin;
                        selmaxmin<=2'b01;
                        selmaxmin_say<=3'b010;
                    end
                    3'b010 : begin
                        y_r_min_value<=outmaxmin;
                        selmaxmin<=2'b10;
                        selmaxmin_say<=3'b011;
                    end
                    3'b011 : begin
                        x_r_max_value<=outmaxmin;
                        selmaxmin<=2'b11;
                        selmaxmin_say<=3'b000;
                    end
                endcase
                case(others_state) 
	               3'b000 : begin
		              if(m<13'd4300) begin
			             x_r[m]<=x_r_one;
			             y_r[m]<=y_r_one;
			             m<=m+1;
			             if(k>=13'd4300) begin
				            k<=0;
				            others_state <=3'b001;
			             end
		              end
	               end
	               3'b001 : begin
		              case (in_cords_state)
			             2'b00 : begin
                            ic1<=ir00*x_r[m];
                            ic2<=ir01*y_r[m];
                            ic3<=ir10*x_r[m];
                            ic4<=ir11*y_r[m];
				
                            out_size_x<=x_r_max_value-x_r_min_value ;
                            out_size_y<=y_r_max_value-y_r_min_value ;
				
                            in_cords_state<=2'b01;
			            end
                        2'b01 : begin
                            x_span_left_buff  <=ic1+ic2;
                            y_span_down_buff <=ic3+ic4;
                            
                            ops_buff<=x_r[m]*out_size_y ;
                            
                            in_cords_state<=2'b10;
                         end
                        2'b10 : begin
                            x_span_left[m]  <=(x_span_left_buff[26:10] + 17'b0011111_1000000000)*18'b01000000_0000000000;
                            y_span_down[m]  <= y_span_down_buff[29:10] + 20'b0000011111_1000000000;
                            
                            out_points_span[m]<=ops_buff[26:10] + y_r[m] - y_r_min_value + 1 ; 
                            
                            in_cords_state<=2'b11;
                        end
                        2'b11 : begin
                            point_span[m]<= x_span_left[m] + y_span_down[m] + 1;
                            m<=m+1;
                            in_cords_state<=2'b00;
                            if(m>=4300) process_completed_flag<=1;
                        end
                      // x_r ve y_r degerleri düzgün gelmediginden out verilmedi
		              endcase
		            end
		      endcase
            end
        end
        4'b0110 : begin // aci 90'se
            if(i_rgb_data_valid) begin
                if(i<7'd64) begin // resmi memorye bit bit at
                    picture[j][i]=i_rgb_data; // columns rows
                    j<=j+1; //sutun
                    if(j>6'd62) begin
                        i<=i+1;
                        j<=0;
                    end
                end  
            end
//            
              if(k>0 && i>=7'd63) begin
                    line_flag<=1 ; // out olarak atama yapmaya baþla
                    b<=b+1;
                    if(b>6'd62) begin
                        k<=k-1;
                        b<=0;
                    end
                end
                o_rgb_data=picture[k][b]; // output
           
           
//            if(buff_sayac_i<7'd64) begin // simetri kaydetme
//                    picture_buffer[buff_sayac_j][buff_sayac_i]=picture[k][a]; // columns rows
//                    buff_sayac_j<=buff_sayac_j+1;
//                    if(j>6'd62) begin
//                        buff_sayac_i<=buff_sayac_i+1;
//                        buff_sayac_j<=0;
//                    end
//              end  
            
            
        end 
        4'b0111 : begin // aci 180'se
            if(i_rgb_data_valid) begin
                if(i<7'd64) begin // resmi memorye bit bit at
                    picture[j][i]=i_rgb_data; // columns rows
                    j<=j+1;
                    if(j>6'd62) begin
                        i<=i+1;
                        j<=0;
                    end
                end  
            end
            if(k>0 && i>=7'd63) begin
                    line_flag<=1 ; // out olarak atama yapmaya baþla
                    b<=b+1;
                    if(b>6'd62) begin
                        k<=k-1;
                        b<=0;
                    end
                end
                o_rgb_data=picture[b][k]; // output
                         
        end
        4'b1000 : begin // aci 270'sa
            if(i_rgb_data_valid) begin
                if(i<7'd64) begin // resmi memorye bit bit at
                    picture[j][i]=i_rgb_data; // columns rows
                    j<=j+1;
                    if(j>6'd62) begin
                        i<=i+1;
                        j<=0;
                    end
                end  
            end
            if(a<64 && i>=7'd63) begin //simetri alma
                    line_flag<=1 ; 
                    k<=k-1;
                    if(k<=0) begin
                        a<=a+1;
                        k<=6'd63;
                    end
            end
           
            o_rgb_data=picture[a][k];    
        end
       
        default begin
        line_flag<=1 ; // out olarak atama yapmaya baþla
            if(i_rgb_data_valid) begin
                if(i<7'd64) begin // resmi memorye bit bit at
                    picture[j][i]=i_rgb_data; // columns rows
                    j<=j+1;
                    if(j>6'd62) begin
                        i<=i+1;
                    end
                end
                o_rgb_data<=picture[i][j];
            end
        end   
    endcase
    end
end

always @(posedge axi_clk)
begin
    o_greyScale_data_valid <= i_rgb_data_valid; //iþlemin bitip bitmediði (okumanýn bitip bitmediði)
end

endmodule


