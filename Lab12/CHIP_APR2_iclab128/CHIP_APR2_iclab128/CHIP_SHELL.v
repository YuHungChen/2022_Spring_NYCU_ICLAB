module CHIP(    
        // Input signals
    clk,
    rst_n,
    in_valid,
    keyboard,
    answer,
    weight,
    match_target,
    // Output signals
    out_valid,
    result,
    out_value
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input [4:0] keyboard;
input [4:0] answer;
input [3:0] weight;
input [2:0] match_target;
output [4:0] result;
output [10:0] out_value;
input clk, rst_n, in_valid;
output out_valid;

wire   C_clk;
wire   C_rst_n;
wire   C_in_valid;
wire  [4:0] C_keyboard,C_answer;
wire  [3:0] C_weight;
wire  [2:0] C_match_target;

wire  C_out_valid;
wire  [4:0] C_result;
wire  [10:0] C_out_value;

wire BUF_clk;
CLKBUFX20 buf0(.A(C_clk),.Y(BUF_clk));


WD u_WD(
    // Input signals
    .clk(BUF_clk),
    .rst_n(C_rst_n),
    .in_valid(C_in_valid),
    .keyboard(C_keyboard),
    .answer(C_answer),
    .weight(C_weight),
    .match_target(C_match_target),
    // Output signals
    .out_valid(C_out_valid),
    .result(C_result),
    .out_value(C_out_value)
);


// Input Pads  #20
P8C I_CLK     			  ( .Y(C_clk),         .P(clk),         .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1) );
P8C I_RESET  			  ( .Y(C_rst_n),       .P(rst_n),       .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_VALID  			  ( .Y(C_in_valid),    .P(in_valid),    .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
		
P4C I_keyboard_0   		  ( .Y(C_keyboard[0]), .P(keyboard[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_keyboard_1   		  ( .Y(C_keyboard[1]), .P(keyboard[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_keyboard_2   		  ( .Y(C_keyboard[2]), .P(keyboard[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_keyboard_3   		  ( .Y(C_keyboard[3]), .P(keyboard[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_keyboard_4   		  ( .Y(C_keyboard[4]), .P(keyboard[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );

P4C I_answer_0   		  ( .Y(C_answer[0]), .P(answer[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_answer_1   		  ( .Y(C_answer[1]), .P(answer[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_answer_2   		  ( .Y(C_answer[2]), .P(answer[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_answer_3    		  ( .Y(C_answer[3]), .P(answer[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_answer_4    		  ( .Y(C_answer[4]), .P(answer[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );

P4C I_weight_0    		  ( .Y(C_weight[0]), .P(weight[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_weight_1    		  ( .Y(C_weight[1]), .P(weight[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_weight_2    		  ( .Y(C_weight[2]), .P(weight[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_weight_3    		  ( .Y(C_weight[3]), .P(weight[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );

P4C I_match_target_0      ( .Y(C_match_target[0]), .P(match_target[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_match_target_1      ( .Y(C_match_target[1]), .P(match_target[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );
P4C I_match_target_2      ( .Y(C_match_target[2]), .P(match_target[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0) );


// Output Pads  #17
P8C O_VALID    ( .A(C_out_valid), 	 .P(out_valid),    .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P8C O_result_0    ( .A(C_result[0]), .P(result[0]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_result_1    ( .A(C_result[1]), .P(result[1]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_result_2    ( .A(C_result[2]), .P(result[2]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_result_3    ( .A(C_result[3]), .P(result[3]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_result_4    ( .A(C_result[4]), .P(result[4]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));


P8C O_out_value_0     ( .A(C_out_value[0]), .P(out_value[0]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_1     ( .A(C_out_value[1]), .P(out_value[1]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_2     ( .A(C_out_value[2]), .P(out_value[2]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_3     ( .A(C_out_value[3]), .P(out_value[3]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_4     ( .A(C_out_value[4]), .P(out_value[4]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_5     ( .A(C_out_value[5]), .P(out_value[5]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_6     ( .A(C_out_value[6]), .P(out_value[6]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_7     ( .A(C_out_value[7]), .P(out_value[7]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_8     ( .A(C_out_value[8]), .P(out_value[8]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_9     ( .A(C_out_value[9]), .P(out_value[9]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_out_value_10    ( .A(C_out_value[10]), .P(out_value[10]), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));


// IO power 

// 4 set for 16 outputs    #8 
PVDDR VDDP0 () ; 
PVSSR GNDP0 () ;
PVDDR VDDP1 () ; 
PVSSR GNDP1 () ;
PVDDR VDDP2 () ; 
PVSSR GNDP2 () ;
PVDDR VDDP3 () ; 
PVSSR GNDP3 () ;

// 3 set for 20 inputs  + 1 output   #6

PVDDR VDDP4 () ; 
PVSSR GNDP4 () ;
PVDDR VDDP5 () ; 
PVSSR GNDP5 () ;
PVDDR VDDP6 () ; 
PVSSR GNDP6 () ;


// Core power   #8

PVDDC VDDC0 () ;
PVSSC GNDC0 () ; 
PVDDC VDDC1 () ;
PVSSC GNDC1 () ; 
PVDDC VDDC2 () ;
PVSSC GNDC2 () ; 
PVDDC VDDC3 () ;
PVSSC GNDC3 () ; 


//  total #59  , each side 15 , add 1 pad filler 



endmodule