`timescale 1ns / 1ps

//% Input:    rect_points_m   -   a set of (x;y) points which define a rectangle ordered clock-wise
//%                               ( format: [x1,x2,x3,x4;y1,y2,y3,y4] )
//%
//% Output:   x_r,y_r         -   2 row vectors which hold the x and y positions of 
//%                               the output grid

module rotated_grid(clk,reset,aci,selmaxmin,rg_completed_flag,x_r_one,y_r_one,outmaxmin);

input clk,reset;
input [2:0] aci;
input [1:0] selmaxmin;
output signed [16:0] outmaxmin;
//output [16:0] y_r_max_value;
//output [16:0] y_r_min_value;
//output [16:0] x_r_max_value;
//output [16:0] x_r_min_value;

output [16:0]  x_r_one ;
output [16:0] y_r_one ;

output reg rg_completed_flag=0;

reg [2:0] selection ; 
reg [3:0] sel_atama =4'b0000 ;

wire signed [32:0] matrix_selected_value; // output from  matrix_product

reg reset_matrix_product;
reg signed [32:0] cx1,cx2,cx3,cx4,cy1,cy2,cy3,cy4;//Q13_20
reg signed [16:0] x1,x2,x3,x4,y1,y2,y3,y4;//Q7_10
reg atama_completed_flag=0;

matrix_product mp(.clk(clk),.reset(reset_matrix_product),.aci(aci),.selection(selection),.selected_value(matrix_selected_value));


reg [6:0] clipped_top;
reg [6:0] clipped_bottom;
reg [6:0] rows;

reg signed [16:0] left_crossover;
reg signed [16:0] right_crossover;

reg [10:0] fraction_bottom;
reg signed [16:0] new_fraction_bottom;

reg signed [16:0] new_y4;//Q7.10 --> 17

reg [11:0] i=0;
reg [11:0] n=0; //** en son for krali sayac
reg [11:0] a=0; // x_r ve x_y sayaci
reg [11:0] z=0; // To_x_right_From_x_left sayaci
reg [11:0] t=0; // span sayaci
reg [5:0] bos_sayac = 6'd0 ;
reg [13:0] inxryr_sayac = 0 ;
reg [13:0] span_initial_sayac = 0 ;

reg [16:0] new_i;
reg signed [16:0]m[127:0]; //128 locations q7.10


/*initial begin
    reset_matrix_product=0;
    for( i=0; i<rows ; i=i+1 ) begin // ram initialization
        new_fraction_bottom={8'b00000000,fraction_bottom}; // Q7.10
        new_i={i,10'b0};
        m[i]= new_i-new_fraction_bottom;           
    end
end */

reg signed [32:0] x_left_nf;
reg signed [32:0] x_right_nf;
reg signed [32:0] x_left_nf_new ;

reg signed [32:0] x1x2_div_y1y2_reg;
reg signed [32:0] x1x4_div_y1y4_reg;
reg signed [32:0] x3x2_div_y3y2_reg;
reg signed [32:0] x3x4_div_y3y4_reg;

reg signed [16:0] x1x2_div_y1y2;
reg signed [16:0] x1x4_div_y1y4;

reg signed [16:0] x3x2_div_y3y2;
reg signed [16:0] x3x4_div_y3y4;

reg signed [6:0] x_right [0:127];
reg signed [6:0] x_left [0:127];

reg [11:0] vec_length = 0 ;

reg signed [6:0]x_r[0:4300];
reg signed [16:0]y_r[0:4300];



reg [13:0]span[0:4095]; // decimal
reg [13:0] k=0;   // x_r'nin þahsiyetine ait // initialý 0 olarak belirledim // span deðerini atýyor
reg signed [6:0]To_x_right_From_x_left[0:127];

reg [11:0] spanin_boyutu; //unsigned sadece boyut
reg [11:0] To_x_right_From_x_left_boyutu;

reg [13:0] cursor = 1;  

reg memory_initial_flag=0;
reg second_initial_flag;

reg x_right_and_x_left_completed=0;
reg To_x_right_From_x_left_flag=0;
reg span_flag=0;

//for max and min values
reg [13:0] counter = 0 ;	
reg [1:0] max_x_r_state;
reg [6:0] took_buff_x_r;  //q7.0
reg [16:0] took_buff_y_r; //q7.10
reg [6:0] xmaxbuff;
reg [6:0] xminbuff;
reg [16:0] ymaxbuff;
reg [16:0] yminbuff;

initial begin // initial values of memories
    for (inxryr_sayac=0;inxryr_sayac<=4300;inxryr_sayac=inxryr_sayac+1) begin    
        x_r[inxryr_sayac]<=0;
        y_r[inxryr_sayac]<=0;   
    end   
end

initial begin // initial values of memories
    for (span_initial_sayac=0;span_initial_sayac<=4300;span_initial_sayac=span_initial_sayac+1) begin    
        span[span_initial_sayac] <= 0; 
    end   
end

//reg [2:0] present_second_initial_flag_state = 3'b000; 
localparam [2:0] zero=3'b000, one=3'b001,two=3'b010,three=3'b011,four=3'b100,five=3'b101;
reg [2:0] next_second_initial_flag_state = 3'b000 ;

always@(posedge clk) begin //for truncate operation
    if(!reset) begin
        if(bos_sayac<6'd21) bos_sayac<=bos_sayac+1; // delay
        if(bos_sayac>=6'd20) begin
            case(sel_atama)
                4'b0000 : begin
                    selection<=3'b000; 
                    sel_atama<=4'b0001;
                end
                4'b0001 : begin
                    selection<=3'b001;
                    //cx1<=matrix_selected_value;
                    sel_atama<=4'b0010;
                end
                4'b0010 : begin
                    selection<=3'b010;
                    cx1<=matrix_selected_value;
                    sel_atama<=4'b0011;
                end
                4'b0011 : begin
                    selection<=3'b011;
                    cx2<=matrix_selected_value;
                    sel_atama<=4'b0100;
                end
                4'b0100 : begin
                    selection<=3'b100;
                    cx3<=matrix_selected_value;
                    sel_atama<=4'b0101;
                end
                4'b0101 : begin
                    selection<=3'b101;
                    cx4<=matrix_selected_value;
                    sel_atama<=4'b0110;
                end
                4'b0110 : begin
                    selection<=3'b110;
                    cy1<=matrix_selected_value;
                    sel_atama<=4'b0111;
                end
                4'b0111 : begin
                    selection<=3'b111;
                    cy2<=matrix_selected_value;
                    sel_atama<=4'b1000;
                end
                4'b1000 : begin
                    cy3<=matrix_selected_value;
                    sel_atama<=4'b1001;
                end
                4'b1001 : begin
                    cy4<=matrix_selected_value;
                    atama_completed_flag<=1;
                    sel_atama<=4'b0000;
                end
            endcase
        end             
    end // atama_completed_flag>0 RESETÝ EKLENECEK
end

always@(posedge clk) begin //for truncate operation
   if(!reset) begin
        x1<=cx1[26:10];// Q7.10  
        x2<=cx2[26:10];
        x3<=cx3[26:10];
        x4<=cx4[26:10];
    
        y1<=cy1[26:10];
        y2<=cy2[26:10];
        y3<=cy3[26:10];
        y4<=cy4[26:10];
    end
end

always @(posedge clk) begin
//always @(posedge clk or reset) begin
	if(reset) begin
		reset_matrix_product<= 1 ;
		memory_initial_flag<=0;
	end
	else begin //main block 
		reset_matrix_product<=0; //matrix product is active
		
		if(atama_completed_flag>0) begin // as an initial and sub_main
			
			clipped_top<=y2[16:10];// floor (truncate)
        
			new_y4<=y4+17'b0000000_1000000000;// rounding (ceil)
			fraction_bottom<=y4[9:0];
			  
			left_crossover<=y1-y4; //Q7.10 --> 17 bits
			right_crossover<=y3-y4;
        
			memory_initial_flag<=1;
		end
		
	end
end

always @(posedge clk) begin // FARKLI ALWAYS BLOÐUNDA 
    if (reset) second_initial_flag<=0;
    else begin
        if(!reset && memory_initial_flag) begin
        	rows<=clipped_top-clipped_bottom;
        	clipped_bottom<=new_y4[16:10]; // 7 bits
        	second_initial_flag<=1;
        end
    end
end

//=====================================================================================================================================

always @(posedge clk) begin
    if (reset) begin
        x_right_and_x_left_completed <=0 ;
        i<=0;
        next_second_initial_flag_state <= 3'b000;
    end
	if(!reset && second_initial_flag) begin
		case(next_second_initial_flag_state)  // states machine
			3'b000 : begin	
				new_fraction_bottom<={7'b0000000,fraction_bottom}; // Q7.10 --> bit operation
				new_i<={i,10'b0};
				next_second_initial_flag_state <= 3'b001 ;
			end
			3'b001 : begin	
				m[i] <=new_i  +  new_fraction_bottom;
				next_second_initial_flag_state <= 3'b010;
			end
			/*3'b010 : begin
				//x_left_nf[i] <=( m[i]>=left_crossover )*(x2-(x1-x2)/(y1-y2)*(rows-m[i]+2*fraction_bottom)) + (m[i] < left_crossover)*(x4+(x1-x4)/(y1-y4)*m[i]) ; //ceilsiz
				x_left_nf[i] <=( m[i]>=left_crossover );
				x_right_nf[i] <=( m[i] >= right_crossover )*( x2 - (x3-x2)/(y3-y2)*(rows-m[i]+2*fraction_bottom) ) + (m[i] < right_crossover )*( x4 + (x3-x4)/(y3-y4)*m[i]);
				next_second_initial_flag_state <= 3'b011;
			end*/
			3'b010 : begin
//				x1x2_div_y1y2 <= ((x1-x2) / (y1-y2)) << 10 ; 
//				x1x4_div_y1y4 <= ((x1-x4) / (y1-y4)) << 10 ;
//				x3x2_div_y3y2 <= ((x3-x2) / (y3-y2)) << 10 ;
//				x3x4_div_y3y4 <= ((x3-x4) / (y3-y4)) << 10 ;
				x1x2_div_y1y2   <= ((x1-x2) / (y1-y2)) << 10 ; 
				x1x4_div_y1y4   <= ((x1-x4) / (y1-y4)) << 10 ; 
				x3x2_div_y3y2   <= ((x3-x2) / (y3-y2)) << 10 ;
				x3x4_div_y3y4   <= ((x3-x4) / (y3-y4)) << 10 ;
				next_second_initial_flag_state <= 3'b100;
			end
//			3'b011 : begin
                
//                x1x2_div_y1y2<=x1x2_div_y1y2_reg[26:20];
//                x1x4_div_y1y4<=((x1-x4) / (y1-y4))<<10;
//                x3x2_div_y3y2<=x3x2_div_y3y2_reg[26:20];
//                x3x4_div_y3y4<=x3x4_div_y3y4_reg[26:20];
//		        next_second_initial_flag_state <= 3'b100;	
			
//			end
			3'b100 : begin
				if ( m[i] >= left_crossover ) begin
					x_left_nf <= x2 - x1x2_div_y1y2*({rows,10'b0000000000} - m[i] + ({7'b0000000,fraction_bottom}<<1)) ;
				end
				else if (m[i] < left_crossover) begin
					x_left_nf <= (x4 + x1x4_div_y1y4 * m[i]) ;
				end
				if ( m[i] >= right_crossover ) begin
					x_right_nf <=  x2 - x3x2_div_y3y2 *({rows,10'b0000000000} - m[i]+ ({7'b0000000,fraction_bottom}<<1));
				end
				else if (m[i] < right_crossover) begin
					x_right_nf <= ( x4 + x3x4_div_y3y4 * m[i]) ;
				end
				next_second_initial_flag_state <= 3'b101;
			end
			3'b101 : begin	
				 x_left_nf_new <=x_left_nf + 33'b0000000000000_10000000000000000000; // rounding (ceil)
				 next_second_initial_flag_state <= 3'b110;
			end
			3'b110 : begin
				x_left[i]  <=x_left_nf_new[26:20]; //bit operation
				x_right[i] <=x_right_nf[26:20];
				// x_right[i]<=x_right_nf[i]>>10; // 10 bit saga kaydýr
				next_second_initial_flag_state <= 3'b111;
			end
			3'b111 : begin
				if (i<=rows) begin 
					vec_length<=vec_length+x_right[i]-x_left[i]+1;
					i<=i+1;	
				end
			    else if(i>rows) begin
					i<=0;
					x_right_and_x_left_completed<=1;
				end
				next_second_initial_flag_state <= 3'b000 ;
			end
		endcase
	end
end

always @(posedge clk) begin //x_r and y_r builder part
    if(reset) begin
        span_flag<=0;
        To_x_right_From_x_left_flag<=0;
        n<=0;
        t<=0;
        z<=0;
        a<=0;
    end
    else begin // the main of this always
        if((n<rows) && x_right_and_x_left_completed && span_flag==0 ) begin
            if ( x_right[n] >= x_left[n] ) begin // each bits equal to 7 bits now
                spanin_boyutu = (x_right[n]- x_left[n] + cursor) + 1 ;
                if(t<spanin_boyutu) begin // for span olusturucu
                    if(t==0) span[0]<= cursor;
                    else begin
                        span[t]<= span[t-1]+1;
                    end
                    t<=t+1;
                end
                if(t>=spanin_boyutu) begin 
                    t<=0;
                    span_flag<=1; // FLAG	
                end
            end
        end
            
        if((n<rows) && To_x_right_From_x_left_flag==0) begin      
            if ( x_right[n] >= x_left[n] ) begin
                To_x_right_From_x_left_boyutu = x_right[n] - x_left[n] ;	
                if(z<To_x_right_From_x_left_boyutu) begin // for x_r oluþturucu
                    if(z==0) begin
                        To_x_right_From_x_left[z]<= x_left[n];
                    end
                    else begin
                        To_x_right_From_x_left[z]<= To_x_right_From_x_left[z-1]+1;
                    end
                    z<=z+1;
                end
                if(z>=To_x_right_From_x_left_boyutu) begin
                    z<=0;
                    To_x_right_From_x_left_flag<=1; // FLAG	
                end
            end	
        end
        
        
        if ( x_right[n] >= x_left[n] ) begin // x_r and y_r are builded
           if (n<rows) begin //*-* n'in artacagi kosul
               if(x_right_and_x_left_completed && span_flag==1 && To_x_right_From_x_left_flag==1 ) begin //*-* n'in artacagi kosul
        	      k<=span[a];
        	      if(a<spanin_boyutu) begin
        	          x_r[k]<=To_x_right_From_x_left[a] ;
        		      y_r[k]<=m[n]+y4 ;
        		     a<=a+1;
        	      end
        	      if(a>=spanin_boyutu) begin //*-* n'in artacagi kosul
        		     a<=0;
        		     span_flag<=0; 
        		     To_x_right_From_x_left_flag<=0;
        		     cursor <= cursor + x_right[n] - x_left[n] + rows;
        	      end
               end
           end
        end
        if(a>=spanin_boyutu && x_right_and_x_left_completed && span_flag==1 && To_x_right_From_x_left_flag==1 && n<rows) n<=n+1;
    end	
end

always @(posedge clk) begin // for max and min //bos_sayac eklenecek
	if(reset)begin
		max_x_r_state<=0;
	end
	else begin
		if(n>0)begin //taking after the one clk cycle
			case(max_x_r_state)
			2'b00: begin
				took_buff_x_r<=x_r[counter];
				took_buff_y_r<=y_r[counter];
				max_x_r_state<=2'b01;
			end
			
			2'b01:begin
				if(took_buff_x_r>=x_r[counter]) begin
					xmaxbuff<=took_buff_x_r;
					xminbuff<=x_r[counter];
				end
				if(took_buff_x_r<x_r[counter]) begin
					xmaxbuff<=x_r[counter];
					xminbuff<=took_buff_x_r;
				end
				if(took_buff_y_r>=y_r[counter]) begin
					ymaxbuff<=took_buff_x_r;
					yminbuff<=x_r[counter];
				end
				if(took_buff_y_r<y_r[counter]) begin
					ymaxbuff<=x_r[counter];
					yminbuff<=took_buff_x_r;
				end
				max_x_r_state<=2'b00;
			end
		  endcase
		  counter<=counter+1;
		  if(counter>4300) begin
		      counter<=0;
		      rg_completed_flag<=1;
		  end
		end
	end
 end
 
 assign x_r_one={x_r[counter],10'b0000000000};
 assign y_r_one=y_r[counter];
 
 
assign outmaxmin = (selmaxmin == 2'b00) ? ymaxbuff : 
                    (selmaxmin== 2'b01) ? yminbuff : 
                    (selmaxmin== 2'b10) ? xmaxbuff : 
                    (selmaxmin== 2'b11) ? xminbuff : 1'bx;



endmodule

