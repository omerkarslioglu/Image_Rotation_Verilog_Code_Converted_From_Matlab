`timescale 1ns / 1ps

module matrix_product(clk,reset,aci,selection,selected_value);

    input clk,reset;
    input [2:0] aci,selection; //0=0 , 1=15, 2=30 ...
    //mp_process_completed_flag
    output signed [32:0] selected_value;
    reg signed [32:0] matrix_selected_value;
    
    reg signed [32:0] a00,a01,a02,a03,a10,a11,a12,a13;//matrix output locations 33 bits , FORMAT : Q_13_20
    
    reg mp_process_completed_flag=0;
    
    reg mode_switch,eksi;
    wire signed [16:0] out;
    
    sincostop a(.mode_switch(mode_switch),.out(out),.reset(reset),.clk(clk),.aci(aci),.eksi(eksi));// mode=0 -> cos mode=1 -> sin
    
    //reg [6:0] size='b0111111; //64-1 = 63 bit from 64x64
    
    reg signed [16:0] cos_aci;
    reg signed [16:0] sin_aci;
    reg signed [16:0] sin_eksi_aci;
    
    reg signed [16:0] midpoint=17'b1100000_1000000000; //-31.5  ---> (-(64-1)/2)
    
    reg [2:0] i=3'b000;
    reg [2:0] j=3'b000;
    
    reg signed [16:0] ara_toplam00;
    
    reg signed [16:0] size=17'b0111111_0000000000;
    
    always @(posedge clk) begin 
        if(reset) begin
            mp_process_completed_flag<=0;
            i<=3'b000;
        end
        case(i)
        3'b000 : begin
            mode_switch<=0;
            eksi<=0;    
            i<=3'b001;
        end
        3'b001 : begin
            mode_switch<=1;
            eksi<=0;
            cos_aci<=out;
            i<=3'b010;
        end
        3'b010 : begin
            mode_switch<=1;
            eksi<=1;
            sin_aci<=out;
            i<=3'b011;
        end
        3'b011 : begin
            sin_eksi_aci<=out;
            i<=3'b000;
            mp_process_completed_flag<=1;
        end
        /*3'b100 : begin
            mp_process_completed_flag<=1; // degisecek
            i<=3'b000;
        end */
        endcase
    end
    
    always @(posedge clk) begin //ASENKRON RESET
        
        if(reset) begin
            j <= 3'b000;
        end
        
        else if (mp_process_completed_flag==1) begin
            case(j)
                3'b000 : begin
                    a00<=midpoint*(cos_aci+sin_aci);
                    j<=3'b001;
                end
                3'b001 : begin
                    a01<=midpoint*cos_aci+(size+midpoint)*sin_aci; 
                    j<=3'b010;
                end
                3'b010 : begin
                    a02<=(size+midpoint)*(cos_aci+sin_aci);  
                    j<=3'b011; 
                end
                3'b011 : begin
                    a03<=((size+midpoint)*cos_aci)+(midpoint*sin_aci); 
                    j<=3'b100;  
                end
                3'b100 : begin
                    a10<=midpoint*(sin_eksi_aci+cos_aci);   
                    j<=3'b101; 
                end
                3'b101 : begin
                    a11<=(midpoint*sin_eksi_aci)+((size+midpoint)*cos_aci);   
                    j<=3'b110;
                end
                3'b110 : begin
                    a12<=(size+midpoint)*(sin_eksi_aci+cos_aci);    
                    j<=3'b111;
                end
                3'b111 : begin
                    a13<=((size+midpoint)*sin_eksi_aci)+(midpoint*cos_aci);   
                    j<=3'b000;  
                end
         endcase
        
        case(selection) //basic mux 8 to 1
            3'b000 : matrix_selected_value<=a00;
            3'b001 : matrix_selected_value<=a01;
            3'b010 : matrix_selected_value<=a02;
            3'b011 : matrix_selected_value<=a03;
            3'b100 : matrix_selected_value<=a10;
            3'b101 : matrix_selected_value<=a11;
            3'b110 : matrix_selected_value<=a12;
            3'b111 : matrix_selected_value<=a13;
        endcase 
          /*  ara_toplam00<=cos_aci+sin_aci;
            a00<=midpoint*(cos_aci+sin_aci);
            a01<=midpoint*cos_aci+(size+midpoint)*sin_aci;
            a02<=(size+midpoint)*(cos_aci+sin_aci);
            a03<=((size+midpoint)*cos_aci)+(midpoint*sin_aci); //?
        
            a10<=midpoint*(sin_eksi_aci+cos_aci);
            a11<=(midpoint*sin_eksi_aci)+((size+midpoint)*cos_aci);
            a12<=(size+midpoint)*(sin_eksi_aci+cos_aci);
            a13<=((size+midpoint)*sin_eksi_aci)+(midpoint*cos_aci);  //? */   
        end 
    end
    
    assign selected_value=matrix_selected_value ;
    
endmodule
