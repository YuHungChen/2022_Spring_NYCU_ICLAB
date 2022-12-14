`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/22 21:31:51
// Design Name: 
// Module Name: CC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CC(out_n , in_n0 , in_n1 , in_n2 , in_n3 , in_n4 , in_n5, opt,  equ  );
output signed [9:0] out_n ;
input [3:0] in_n0 , in_n1 , in_n2 , in_n3 , in_n4 , in_n5 ;
input [2:0] opt ;
input equ ; 
wire signed[4:0]first_out_0, first_out_1, first_out_2, first_out_3, first_out_4,first_out_5;
wire signed[4:0]second_out_0, second_out_1, second_out_2, second_out_3, second_out_4, second_out_5 ;
wire signed[4:0]tmp_0, tmp_1, tmp_2, tmp_3,tmp_4, tmp_5 ;
wire signed[4:0]out_0, out_1, out_2, out_3, out_4, out_5 ;
wire signed[4:0]sort_0, sort_1, sort_2, sort_3, sort_4, sort_5 ;
wire signed[4:0]new_out_0 ,new_out_1 ,new_out_2 ,new_out_3 ,new_out_4 ,new_out_5 ; 

wire signed [4:0] value0, value1, value2, value3, value4, value5 ;
assign   value0 = (opt[0])? {in_n0[3],in_n0} : {1'b0, in_n0} ;
assign   value1 = (opt[0])? {in_n1[3],in_n1} : {1'b0, in_n1} ;
assign   value2 = (opt[0])? {in_n2[3],in_n2} : {1'b0, in_n2} ;
assign   value3 = (opt[0])? {in_n3[3],in_n3} : {1'b0, in_n3} ;
assign   value4 = (opt[0])? {in_n4[3],in_n4} : {1'b0, in_n4} ;
assign   value5 = (opt[0])? {in_n5[3],in_n5} : {1'b0, in_n5} ;

two_comparator U0 (.in0(value0),
                 .in1(value1),
                 .out0(first_out_0),
                 .out1(second_out_0) ) ;
                 
two_comparator U1 (.in0(value2),
                 .in1(value3),
                 .out0(first_out_1),
                 .out1(second_out_1) ) ;
two_comparator U2 (.in0(value4),
                 .in1(value5),
                 .out0(first_out_2),
                 .out1(second_out_2) ) ;
two_comparator U3 (.in0(first_out_0),
                 .in1(first_out_1),
                 .out0(first_out_3),
                 .out1(second_out_3) ) ;
two_comparator U4 (.in0(second_out_1),
                 .in1(first_out_2),
                 .out0(first_out_4),
                 .out1(second_out_4) ) ;
two_comparator U5 (.in0(second_out_0),
                 .in1(second_out_2),
                 .out0(first_out_5),
                 .out1(second_out_5) ) ;
two_comparator U6 (.in0(first_out_3),
                 .in1(first_out_4),
                 .out0(out_0),
                 .out1(tmp_0) ) ;
two_comparator U7 (.in0(second_out_3),
                 .in1(first_out_5),
                 .out0(tmp_1),
                 .out1(tmp_2) ) ;
two_comparator U8 (.in0(second_out_4),
                 .in1(second_out_5),
                 .out0(tmp_3),
                 .out1(out_5) ) ;
two_comparator U9 (.in0(tmp_0),
                 .in1(tmp_1),
                 .out0(out_1),
                 .out1(tmp_4) ) ;
two_comparator U10 (.in0(tmp_2),
                 .in1(tmp_3),
                 .out0(tmp_5),
                 .out1(out_4) ) ;
two_comparator U11 (.in0(tmp_4),
                 .in1(tmp_5),
                 .out0(out_2),
                 .out1(out_3) ) ;
                 
descending U13     (.order(opt[1]),
                  .in0(out_0),
                  .in1(out_1), 
                  .in2(out_2),
                  .in3(out_3),  
                  .in4(out_4),
                  .in5(out_5),
                  .out_0(sort_0),
                  .out_1(sort_1),    
                  .out_2(sort_2),
                  .out_3(sort_3),
                  .out_4(sort_4),
                  .out_5(sort_5)          );
                              
MovAverage_or_normalization U12 ( .MovAverage(opt[2]),
                              .in0(sort_0),
                              .in1(sort_1), 
                              .in2(sort_2),
                              .in3(sort_3),  
                              .in4(sort_4),
                              .in5(sort_5),
                              .out_0 (new_out_0) ,
                              .out_1 (new_out_1) ,
                              .out_2 (new_out_2) ,
                              .out_3 (new_out_3) ,
                              .out_4 (new_out_4) ,
                              .out_5 (new_out_5)  ) ; 
                              
compute_out U14 (   .out_n (out_n),
                  .equ  (equ) , 
                  .in0(new_out_0),
                  .in1(new_out_1), 
                  .in2(new_out_2),
                  .in3(new_out_3),  
                  .in4(new_out_4),
                  .in5(new_out_5) ) ;
                                             
endmodule

module two_comparator(in0,in1,out0,out1);
            
input signed [4:0] in0 , in1 ;
output reg signed [4:0]out0, out1;

always@(in0, in1)
begin
    if (in0 < in1 )
         begin
            out0 = in1 ;
            out1 = in0 ;
         end
    else
        begin
            out0 = in0 ;
            out1 = in1 ; 
        end
end

endmodule

module MovAverage_or_normalization(out_0 , out_1, out_2, out_3, out_4, out_5,
                                 MovAverage,
                                in0 , in1 , in2 , in3 , in4 , in5 
                                );

//output reg signed [9:0]out_n;
output wire signed[4:0] out_0 , out_1, out_2, out_3, out_4, out_5 ;
//input equ ;

input MovAverage;
input signed[4:0] in0 , in1 , in2 , in3 , in4 , in5;

wire signed[4:0] sign_out_[1:5] ;
//  MovAverage  ( for signed and Unsigned)
assign sign_out_[1] = ( in0 * 2 + in1)/3 ;
assign sign_out_[2] = (sign_out_[1] * 2 + in2)/3 ;
assign sign_out_[3] = (sign_out_[2] * 2 + in3)/3 ;
assign sign_out_[4] = (sign_out_[3] * 2 + in4)/3 ;
assign sign_out_[5] = (sign_out_[4] * 2 + in5)/3 ;

wire signed[4:0] normalize_1 ,normalize_2, normalize_3, normalize_4, normalize_5 ;
assign normalize_1 = in1 - in0 ;
assign normalize_2 = in2 - in0 ; 
assign normalize_3 = in3 - in0 ;
assign normalize_4 = in4 - in0 ;
assign normalize_5 = in5 - in0 ;


assign out_0 = (MovAverage) ? in0 : 5'b0 ;
assign out_1 = (MovAverage) ? sign_out_[1] : normalize_1 ;
assign out_2 = (MovAverage) ? sign_out_[2] : normalize_2 ;
assign out_3 = (MovAverage) ? sign_out_[3] : normalize_3 ;
assign out_4 = (MovAverage) ? sign_out_[4] : normalize_4 ;
assign out_5 = (MovAverage) ? sign_out_[5] : normalize_5 ;

endmodule

module descending(order, in0 ,in1 ,in2 ,in3 ,in4 ,in5 , out_0, out_1, out_2, out_3, out_4, out_5);
input order ;
input  signed[4:0] in0 , in1 , in2 , in3 , in4 , in5;
output reg signed [4:0] out_0, out_1, out_2, out_3, out_4, out_5;

always@(*)
begin
    if(order)
        begin
            out_0 = in0 ;
            out_1 = in1 ;
            out_2 = in2 ;
            out_3 = in3 ;
            out_4 = in4 ;
            out_5 = in5 ;
        end
    else
        begin
            out_0 = in5 ;
            out_1 = in4 ;
            out_2 = in3 ;
            out_3 = in2 ;
            out_4 = in1 ;
            out_5 = in0 ;
        end
end
endmodule

module compute_out( out_n,
                  equ, 
                  in0 , in1 , in2 , in3 , in4 , in5);
output reg signed [9:0]out_n;
input  signed[4:0] in0 , in1 , in2 , in3 , in4 , in5 ;
input equ ; 
wire signed[4:0] temp ;
assign temp = in1-in0 ;

always @(*)
begin
     if(equ)
		 if ( (temp[4]) ^ (in5[4]) )
			out_n = (in0 -in1) * (in5) ;
		else
			out_n = (in1- in0) * ( in5 ) ;
     else
        out_n = ( (in3 + in4*4) * ( in5 ))/ 3 ;
end

endmodule