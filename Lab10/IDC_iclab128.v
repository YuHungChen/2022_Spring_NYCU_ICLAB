// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on
module IDC(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	in_data,
	op,
	// Output signals
	out_valid,
	out_data
);


// INPUT AND OUTPUT DECLARATION  
input		clk;
input		rst_n;
input		in_valid;
input		cg_en;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid; 
output reg  signed [6:0] out_data;


//  state_parameter 

parameter ST_IN_IMG = 'd0 ;

parameter ST_Action = 'd1 ; 
parameter ST_Move_point = 'd2 ; 
parameter ST_Out = 'd3 ; 
parameter ST_IDLE = 'd4 ; 
parameter ST_reset = 'd5 ; 
// parameter ST_Wait_invalid = 'd12 ; 

integer k ; 

//  register 
reg [2:0] count_x , count_y ; 
reg [2:0] current_state , next_state ; 
reg [2:0] operation_point_x , operation_point_y ;   // 0 to 6    //  if one of value is larger than 4  ==> output will be Zoom out

reg signed [6:0] img_origin [0:7][0:7] ; 
// reg signed [6:0] img_final  [0:7][0:7] ; 
reg [3:0] action [0:15] ;
reg [3:0] last_action ; 

// reg [1:0] Direction ; //  0: UP , 1 : Right , 2 : Down , 3 : Left   ;  

reg [3:0] count_action ; 
reg mid_avg_done_and_no_move ; 
reg out_flag ; 

reg signed [6:0] temp_value [0:3] ; 

reg to_sleep_op_flag ; 
// GATED    // 
wire G_sleep_OP ; 
wire G_clock_OP ; 
assign G_sleep_OP = (cg_en & !( !to_sleep_op_flag ) ) ;    //  maybe I need to use counter to control this sleep ; 
GATED_OR GATED_OP (
	.CLOCK      (clk) , 
	.SLEEP_CTRL (G_sleep_OP), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_OP)
) ;

wire G_sleep_ACT ; 
wire G_clock_ACT ; 
assign G_sleep_ACT = (cg_en  & !( current_state != ST_Out ) ) ;   //  change !in_valid  to (count_x == 'd7 && count_y == 'd7 )

GATED_OR GATED_IMG (
	.CLOCK      (clk) , 
	.SLEEP_CTRL (G_sleep_ACT), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_ACT)
) ;

wire G_sleep_POI ; // operation_opint 
wire G_clock_POI ; 
assign G_sleep_POI = (cg_en  &  !(next_state == ST_Move_point || (next_state == ST_reset  )  )   ) ; 

GATED_OR GATED_POI (
	.CLOCK      (clk) , 
	.SLEEP_CTRL (G_sleep_POI), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_POI)
) ;

wire G_sleep_Out ; 
wire G_clock_Out ; 
assign G_sleep_Out = (cg_en & !(current_state == ST_Out  || out_flag   ) ) ;    //  maybe I need to use counter to control this sleep ; 
GATED_OR GATED_Out (
	.CLOCK      (clk) , 
	.SLEEP_CTRL (G_sleep_Out), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_Out)
);


wire G_clock_IMG[0:7][0:7] ;
reg  sleep_ctrl[0:7][0:7] ; 
GATED_OR GATED_IMG_0_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][0])
);

GATED_OR GATED_IMG_0_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][1])
);

GATED_OR GATED_IMG_0_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][2])
);

GATED_OR GATED_IMG_0_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][3])
);

GATED_OR GATED_IMG_0_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][4])
);

GATED_OR GATED_IMG_0_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][5])
);

GATED_OR GATED_IMG_0_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][6])
);

GATED_OR GATED_IMG_0_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[0][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[0][7])
);

GATED_OR GATED_IMG_1_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][0])
);

GATED_OR GATED_IMG_1_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][1])
);

GATED_OR GATED_IMG_1_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][2])
);

GATED_OR GATED_IMG_1_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][3])
);

GATED_OR GATED_IMG_1_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][4])
);

GATED_OR GATED_IMG_1_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][5])
);

GATED_OR GATED_IMG_1_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][6])
);

GATED_OR GATED_IMG_1_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[1][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[1][7])
);

GATED_OR GATED_IMG_2_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][0])
);

GATED_OR GATED_IMG_2_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][1])
);

GATED_OR GATED_IMG_2_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][2])
);

GATED_OR GATED_IMG_2_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][3])
);

GATED_OR GATED_IMG_2_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][4])
);

GATED_OR GATED_IMG_2_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][5])
);

GATED_OR GATED_IMG_2_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][6])
);

GATED_OR GATED_IMG_2_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[2][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[2][7])
);

GATED_OR GATED_IMG_3_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][0])
);

GATED_OR GATED_IMG_3_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][1])
);

GATED_OR GATED_IMG_3_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][2])
);

GATED_OR GATED_IMG_3_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][3])
);

GATED_OR GATED_IMG_3_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][4])
);

GATED_OR GATED_IMG_3_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][5])
);

GATED_OR GATED_IMG_3_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][6])
);

GATED_OR GATED_IMG_3_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[3][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[3][7])
);

GATED_OR GATED_IMG_4_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][0])
);

GATED_OR GATED_IMG_4_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][1])
);

GATED_OR GATED_IMG_4_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][2])
);

GATED_OR GATED_IMG_4_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][3])
);

GATED_OR GATED_IMG_4_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][4])
);

GATED_OR GATED_IMG_4_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][5])
);

GATED_OR GATED_IMG_4_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][6])
);

GATED_OR GATED_IMG_4_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[4][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[4][7])
);

GATED_OR GATED_IMG_5_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][0])
);

GATED_OR GATED_IMG_5_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][1])
);

GATED_OR GATED_IMG_5_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][2])
);

GATED_OR GATED_IMG_5_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][3])
);

GATED_OR GATED_IMG_5_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][4])
);

GATED_OR GATED_IMG_5_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][5])
);

GATED_OR GATED_IMG_5_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][6])
);

GATED_OR GATED_IMG_5_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[5][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[5][7])
);

GATED_OR GATED_IMG_6_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][0])
);

GATED_OR GATED_IMG_6_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][1])
);

GATED_OR GATED_IMG_6_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][2])
);

GATED_OR GATED_IMG_6_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][3])
);

GATED_OR GATED_IMG_6_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][4])
);

GATED_OR GATED_IMG_6_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][5])
);

GATED_OR GATED_IMG_6_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][6])
);

GATED_OR GATED_IMG_6_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[6][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[6][7])
);

GATED_OR GATED_IMG_7_0(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][0]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][0])
);

GATED_OR GATED_IMG_7_1(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][1]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][1])
);

GATED_OR GATED_IMG_7_2(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][2]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][2])
);

GATED_OR GATED_IMG_7_3(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][3]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][3])
);

GATED_OR GATED_IMG_7_4(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][4]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][4])
);

GATED_OR GATED_IMG_7_5(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][5]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][5])
);

GATED_OR GATED_IMG_7_6(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][6]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][6])
);

GATED_OR GATED_IMG_7_7(
	.CLOCK      (clk) , 
	.SLEEP_CTRL (sleep_ctrl[7][7]), 
	.RST_N		(rst_n) ,
	.CLOCK_GATED(G_clock_IMG[7][7])
);








wire signed [6:0] AVG_value ;
wire signed [6:0] Mid_point_value; 

wire signed [7:0] tmp_add_1 , tmp_add_2 ;
wire signed [8:0] tmp_add_3 ; 

wire signed [6:0] max , middle_1 , middle_2 , min ; 

find_middle_point U1 
			(
				.one      (img_origin[operation_point_x      ][operation_point_y      ]),
				.two      (img_origin[operation_point_x + 'd1][operation_point_y      ]),
				.three    (img_origin[operation_point_x      ][operation_point_y + 'd1]),
				.four     (img_origin[operation_point_x + 'd1][operation_point_y + 'd1]),
				.max      (max),
				.middle_1 (middle_1),
				.middle_2 (middle_2),
				.min      (min)
				
			);

assign tmp_add_1 = (max + min ) ; 
assign tmp_add_2 = (middle_1 + middle_2) ; 
assign tmp_add_3 = tmp_add_1 + tmp_add_2 ; 

assign AVG_value =  tmp_add_3 / 4 ; 
assign Mid_point_value = tmp_add_2 / 2 ; 

genvar i, j ; 
integer l ;


always@(*)begin
	if (last_action == 'd0)begin
		for (k=0 ; k<= 3 ; k=k+1)
			temp_value[k] = Mid_point_value ;  
	end else if (last_action == 'd1)begin
		for (k=0 ; k<= 3 ; k=k+1)
			temp_value[k] = AVG_value ;
	end else if (last_action == 'd2)begin
			temp_value[0] = img_origin[operation_point_x      ][operation_point_y + 'd1] ;
			temp_value[1] = img_origin[operation_point_x      ][operation_point_y      ] ;
			temp_value[2] = img_origin[operation_point_x + 'd1][operation_point_y + 'd1] ;
			temp_value[3] = img_origin[operation_point_x + 'd1][operation_point_y      ] ;
	end else if (last_action == 'd3)begin
			temp_value[0] = img_origin[operation_point_x + 'd1][operation_point_y      ] ;
			temp_value[1] = img_origin[operation_point_x + 'd1][operation_point_y + 'd1] ;
			temp_value[2] = img_origin[operation_point_x      ][operation_point_y      ] ;
			temp_value[3] = img_origin[operation_point_x      ][operation_point_y + 'd1] ;
	end else begin   // if (last_action == 'd4 )
			temp_value[0] = img_origin[operation_point_x      ][operation_point_y      ] * (-'d1) ; 
			temp_value[1] = img_origin[operation_point_x + 'd1][operation_point_y      ] * (-'d1) ;
			temp_value[2] = img_origin[operation_point_x      ][operation_point_y + 'd1] * (-'d1) ;
			temp_value[3] = img_origin[operation_point_x + 'd1][operation_point_y + 'd1] * (-'d1) ;
	end
end 

// Design 
// ====  for image  ==========
// always@ (posedge G_clock_IMG , negedge rst_n) begin
	// if (!rst_n) begin
		// for(k=0 ; k<= 7 ; k=k+1)begin
			// for (l=0 ; l<=7 ; l=l+1)begin
				// img_origin[k][l] <= 'd0 ; 
			// end
		// end
	// end else if ( current_state != ST_Out  )begin
		// if (in_valid)
			// img_origin[count_x][count_y] <= in_data ;
		
		// if (last_action <= 'd4 && current_state == ST_Action)begin
			// img_origin[operation_point_x      ][operation_point_y      ] <= temp_value[0] ; 
			// img_origin[operation_point_x + 'd1][operation_point_y      ] <= temp_value[1] ; 
			// img_origin[operation_point_x      ][operation_point_y + 'd1] <= temp_value[2] ; 
			// img_origin[operation_point_x + 'd1][operation_point_y + 'd1] <= temp_value[3] ; 
		// end 
		
	// end	
// end 

generate
	for (i=0 ; i<=7 ; i=i+1)begin
		for (j=0 ; j<=7 ; j=j+1)begin
			always@(*)begin
				if (cg_en)begin
					if (  current_state == ST_Action && ( (i == operation_point_x && j == operation_point_y) || (i == operation_point_x && j == operation_point_y +'d1 ) ||  (i == operation_point_x +'d1  && j == operation_point_y )   ||(i == operation_point_x +'d1 && j == operation_point_y +'d1 )) )begin
						sleep_ctrl[i][j] = 'd0 ; 
					end else if (i == count_x && j == count_y ) begin
						if (current_state == ST_Out)begin
							sleep_ctrl[i][j] = 'd1 ;
						end else begin
							sleep_ctrl[i][j] = 'd0 ; 
						end
					end else begin
						sleep_ctrl[i][j] = 'd1 ;
					end 
				end else begin
					sleep_ctrl[i][j] = 'd0 ; 
				end
			end
		end
	end
	
endgenerate

generate
	for (i=0 ; i<=7 ; i=i+1)begin
		for (j=0 ; j<=7 ; j=j+1)begin
			always@(posedge G_clock_IMG[i][j] , negedge rst_n )begin
				if (!rst_n)begin
					img_origin[i][j] <= 'd0 ; 
				end else if (!sleep_ctrl[i][j] ) begin
					if (i == count_x && j == count_y && in_valid && current_state != ST_Out )begin
						img_origin[i][j] <= in_data ; 
					end 
					
					if (last_action <= 'd4 && current_state == ST_Action)begin 
						if (i == operation_point_x && j == operation_point_y) begin
							img_origin[i][j] <= temp_value[0] ; 
						end else if (i == operation_point_x + 'd1 && j == operation_point_y)begin
							img_origin[i][j] <= temp_value[1] ; 
						end else if (i == operation_point_x && j == operation_point_y +'d1) begin
							img_origin[i][j] <= temp_value[2] ; 
						end else if (i == operation_point_x + 'd1 && j == operation_point_y +'d1)begin
							img_origin[i][j] <= temp_value[3] ; 
						end 
					end 
				end
				
			end
		end
	end 
endgenerate

always@ (posedge G_clock_ACT , negedge rst_n) begin
	if (!rst_n) begin
		count_x <= 'd0 ;
		count_y <= 'd0 ;
	end else if ( current_state != ST_Out  ) begin
		if (in_valid)begin
			count_y <= count_y + 'd1 ; 
			if (count_y == 'd7 )begin
				count_x <= count_x +'d1  ;
			end
		end 
	end
end 

always@ (posedge clk , negedge rst_n) begin
	if (!rst_n) begin
		to_sleep_op_flag <= 'd0 ;
	end else if (count_action == 'd14) begin
		to_sleep_op_flag <= 'd1 ;
	end else if (out_flag)begin
		to_sleep_op_flag <= 'd0 ; 
	end
end 


always@ (posedge G_clock_ACT , negedge rst_n)begin
	if(!rst_n) begin
		count_action <= 'd0 ;
	end else if ( current_state != ST_Out)begin
		if (in_valid && !to_sleep_op_flag)begin
			if (count_action == 'd14 )
				count_action <= 'd0 ; 
			else 
				count_action <= count_action + 'd1 ;
		end else if (next_state == ST_Action || next_state == ST_Move_point)begin
			count_action <= count_action + 'd1 ;
		end else if (count_action == 'd15)begin
			count_action <= 'd0 ;
		end
	end 
end

always@ (posedge G_clock_OP , negedge rst_n) begin
	if (!rst_n) begin
		for (k=0 ; k<=15 ; k=k+1) begin
			action[k] <= 'd0 ;
		end 
	end else if (!to_sleep_op_flag) begin
		if (in_valid)
			action[count_action] <= op ; 
	end
end


always@ (posedge G_clock_ACT , negedge rst_n)begin
	if(!rst_n)begin
		last_action <= 'd0 ;
	end else if (current_state != ST_Out)begin
		last_action <= action[count_action] ; 
	end
end

reg [2:0] next_point_x , next_point_y ; 
always@(*)begin
	if (action[count_action] == 'd5)begin
		if (operation_point_x == 'd0) 
			next_point_x = 'd0 ; 
		else 
			next_point_x = operation_point_x - 'd1 ;
	end else if (action[count_action] == 'd7)begin
		if (operation_point_x == 'd6)
			next_point_x = 'd6 ;
		else 
			next_point_x = operation_point_x + 'd1 ;
	end else begin
		next_point_x = operation_point_x ; 
	end
end

always@(*)begin
	if (action[count_action] == 'd6)begin
		if (operation_point_y == 'd0) 
			next_point_y = 'd0 ; 
		else 
			next_point_y = operation_point_y - 'd1 ;
	end else if (action[count_action] == 'd8)begin
		if (operation_point_y == 'd6)
			next_point_y = 'd6 ;
		else 
			next_point_y = operation_point_y + 'd1 ;
	end else begin
		next_point_y = operation_point_y ; 
	end
end


// ======  for operation_point_x , operation_point_y ===============  
always@(posedge G_clock_POI , negedge rst_n) begin
	if(!rst_n)begin
		operation_point_x <= 'd3 ;
		operation_point_y <= 'd3 ;
	end else if (next_state == ST_Move_point)begin
			operation_point_x <= next_point_x;
			operation_point_y <= next_point_y;
	end else if (next_state == ST_reset) begin
			operation_point_x <= 'd3 ;
			operation_point_y <= 'd3 ;
	end 

end


// output
reg [1:0] count_out_x , count_out_y ;

always@(posedge G_clock_Out , negedge rst_n) begin
	if(!rst_n) begin
		count_out_x <= 'd0 ;
		count_out_y <= 'd0 ; 
	end else if (current_state == ST_Out ) begin
		if (!out_flag)
			count_out_y <= count_out_y + 'd1 ; 
			
		if (count_out_y == 'd3)begin
			count_out_x <= count_out_x + 'd1 ;
		end 
	end 
end

always@(posedge G_clock_Out , negedge rst_n) begin
	if(!rst_n) begin
		out_flag <= 'd0 ;
	end else if (out_flag )begin
		out_flag <= 'd0 ;
	end else if (current_state == ST_Out) begin
		if (count_out_x == 'd3 && count_out_y == 'd3)
			out_flag <= 'd1 ; 
	end	
end

wire zoom_in_or_zoom_out_flag ; 
assign zoom_in_or_zoom_out_flag = (operation_point_x >= 4  || operation_point_y >= 4 )? 1 :0 ; 
 
 
 
reg signed [6:0] output_value ;  
always@(*)begin
	if (zoom_in_or_zoom_out_flag) begin
		output_value = img_origin[ count_out_x * 2 ][count_out_y * 2]  ; 
	end else begin
		output_value = img_origin[ (operation_point_x +'d1)  + count_out_x][ (operation_point_y+'d1) + count_out_y] ; 
	end
end 
 
always@(posedge G_clock_Out , negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 'd0 ;
		out_data  <= 'd0 ; 
	end else if (out_flag)begin
		out_valid <= 'd0 ;
		out_data  <= 'd0 ;
	end else if (current_state == ST_Out  )begin
		out_valid <= 'd1 ; 
		out_data  <= output_value ; 
	end
end


// FSM
always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		current_state <= ST_IN_IMG ;
	end else begin
		current_state <= next_state ; 
	end
end

wire change_state_flag ; 



assign change_state_flag =    ( (count_x  > operation_point_x) && (count_y > operation_point_y) ) ? 1 :
						   (count_x  > (operation_point_x + 'd1 ) )							? 1 :
						   (count_x == 'd0 && count_y == 'd0 && to_sleep_op_flag    )    ? 1 : 0 ; 



always@(*) begin
	
	case (current_state) 
		ST_IN_IMG : begin
					if ( change_state_flag )begin
						if (action[count_action] <= 'd4)begin
							next_state = ST_Action ; 
						end else begin
							next_state = ST_Move_point ; 
						end 
		
					end else begin
						next_state = ST_IN_IMG ; 
					end
				end
		ST_Action : begin
					if (count_action == 'd15)begin
						if ( (count_x == 'd7 && (count_y == 'd7) ) || ( count_x == 'd0 && count_y == 'd0 ) )
							next_state = ST_Out ; 
						else
							next_state = ST_IDLE ; 
					end else if ( change_state_flag )begin
						if (action[count_action] <= 'd4)begin
							next_state = ST_Action ; 
						end else begin
							next_state = ST_Move_point ; 
						end
					end else begin
						next_state = ST_IN_IMG ; 
					end
				end
		ST_Move_point : begin
					if (count_action == 'd15)begin
						if ( (count_x == 'd7 && ( count_y == 'd7) ) || ( count_x == 'd0 && count_y == 'd0 ) )
							next_state = ST_Out ; 
						else
							next_state = ST_IDLE ; 
					end else if ( change_state_flag )begin
						if (action[count_action] <= 'd4)begin
							next_state = ST_Action ; 
						end else begin
							next_state = ST_Move_point ; 
						end
					end else begin
						next_state = ST_IN_IMG ; 
					end
				end
		ST_Out : begin
					if ( out_flag )begin
						next_state = ST_reset ; 
					end else begin
						next_state = ST_Out ; 
					end
				end
		ST_IDLE :   if ( (count_x == 'd7 && count_y == 'd7)  )begin
						next_state = ST_Out ; 
					end else begin
						next_state = ST_IDLE ; 
					end
		ST_reset : next_state = ST_IN_IMG ; 
		
		default : next_state = ST_IN_IMG ; 
	endcase
	
end





endmodule // IDC


module find_middle_point ( one, two , three, four, middle_1 , middle_2 , max , min) ; 
	input signed [6:0] one, two , three , four ; 
	output signed [6:0] middle_1 , middle_2 , max , min ; 
	
	wire signed [6:0]  tmp_bigger_1 , tmp_bigger_2 ; 
	wire signed [6:0] tmp_smaller_1 , tmp_smaller_2 ; 
		
	assign tmp_bigger_1  = (one   > two  )? one   : two ;
	assign tmp_smaller_1 = (one   > two  )? two   : one ;
	
	assign tmp_bigger_2  = (three > four )? three : four  ; 
	assign tmp_smaller_2 = (three > four )? four  : three ;
	
	assign max      = (tmp_bigger_1 > tmp_bigger_2)? tmp_bigger_1 : tmp_bigger_2 ; 
	assign middle_1 = (tmp_bigger_1 > tmp_bigger_2)? tmp_bigger_2 : tmp_bigger_1 ; 
	
	assign middle_2 = (tmp_smaller_1 > tmp_smaller_2)? tmp_smaller_1 : tmp_smaller_2 ; 
	assign min      = (tmp_smaller_1 > tmp_smaller_2)? tmp_smaller_2 : tmp_smaller_1 ;
	
endmodule