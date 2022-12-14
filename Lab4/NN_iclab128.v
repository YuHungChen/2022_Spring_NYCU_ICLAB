module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_i,
	in_valid_k,
	in_valid_o,
	Image1,
	Image2,
	Image3,
	Kernel1,
	Kernel2,
	Kernel3,
	Opt,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;
parameter inst_arch = 2;

parameter ST_Store_value = 'd0 ;
parameter ST_Out  		  = 'd1 ; 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [inst_sig_width+inst_exp_width:0] Image1, Image2, Image3;
input [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;



//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [2:0] current_state ;
reg [2:0] next_state ;
// =========Store_value paramenters======
reg [inst_sig_width + inst_exp_width : 0 ] Kerna_1_reg [0:3][0:8]  ; 
reg [inst_sig_width + inst_exp_width : 0 ] Kerna_2_reg [0:3][0:8] ; 
reg [inst_sig_width + inst_exp_width : 0 ] Kerna_3_reg [0:3][0:8] ; 

reg [inst_sig_width + inst_exp_width : 0 ] Image_1_reg [1:4][1:4] ;
reg [inst_sig_width + inst_exp_width : 0 ] Image_2_reg [1:4][1:4] ;
reg [inst_sig_width + inst_exp_width : 0 ] Image_3_reg [1:4][1:4] ;


reg [1:0] Opt_reg ; 

reg [2:0] count_value_given_column ; 
reg [2:0] count_value_given_row ; 
integer i , j ; 
// padding image1
wire [inst_sig_width + inst_exp_width : 0 ] image_1_padding [0:5] [0:5];
wire [inst_sig_width + inst_exp_width : 0 ] image_2_padding [0:5] [0:5];
wire [inst_sig_width + inst_exp_width : 0 ] image_3_padding [0:5] [0:5];

assign image_1_padding [0][0] = (Opt_reg[1])? 0 : Image_1_reg[1][1] ;
assign image_1_padding [0][1] = (Opt_reg[1])? 0 : Image_1_reg[1][1] ;
assign image_1_padding [1][0] = (Opt_reg[1])? 0 : Image_1_reg[1][1] ;
 
assign image_1_padding [0][2] = (Opt_reg[1])? 0 : Image_1_reg[1][2] ;
assign image_1_padding [0][3] = (Opt_reg[1])? 0 : Image_1_reg[1][3] ;
assign image_1_padding [0][4] = (Opt_reg[1])? 0 : Image_1_reg[1][4] ;

assign image_1_padding [2][0] = (Opt_reg[1])? 0 : Image_1_reg[2][1] ;
assign image_1_padding [3][0] = (Opt_reg[1])? 0 : Image_1_reg[3][1] ;
assign image_1_padding [4][0] = (Opt_reg[1])? 0 : Image_1_reg[4][1] ;

assign image_1_padding [5][5] = (Opt_reg[1])? 0 : Image_1_reg[4][4] ;
assign image_1_padding [4][5] = (Opt_reg[1])? 0 : Image_1_reg[4][4] ;
assign image_1_padding [5][4] = (Opt_reg[1])? 0 : Image_1_reg[4][4] ;

assign image_1_padding [5][0] = (Opt_reg[1])? 0 : Image_1_reg[4][1] ;
assign image_1_padding [5][1] = (Opt_reg[1])? 0 : Image_1_reg[4][1] ;
assign image_1_padding [5][2] = (Opt_reg[1])? 0 : Image_1_reg[4][2] ;
assign image_1_padding [5][3] = (Opt_reg[1])? 0 : Image_1_reg[4][3] ;
 
assign image_1_padding [0][5] = (Opt_reg[1])? 0 : Image_1_reg[1][4] ;
assign image_1_padding [1][5] = (Opt_reg[1])? 0 : Image_1_reg[1][4] ;
assign image_1_padding [2][5] = (Opt_reg[1])? 0 : Image_1_reg[2][4] ;
assign image_1_padding [3][5] = (Opt_reg[1])? 0 : Image_1_reg[3][4] ; 

// padding image2
assign image_2_padding [0][0] = (Opt_reg[1])? 0 : Image_2_reg[1][1] ;
assign image_2_padding [0][1] = (Opt_reg[1])? 0 : Image_2_reg[1][1] ;
assign image_2_padding [1][0] = (Opt_reg[1])? 0 : Image_2_reg[1][1] ;
 
assign image_2_padding [0][2] = (Opt_reg[1])? 0 : Image_2_reg[1][2] ;
assign image_2_padding [0][3] = (Opt_reg[1])? 0 : Image_2_reg[1][3] ;
assign image_2_padding [0][4] = (Opt_reg[1])? 0 : Image_2_reg[1][4] ;

assign image_2_padding [2][0] = (Opt_reg[1])? 0 : Image_2_reg[2][1] ;
assign image_2_padding [3][0] = (Opt_reg[1])? 0 : Image_2_reg[3][1] ;
assign image_2_padding [4][0] = (Opt_reg[1])? 0 : Image_2_reg[4][1] ;

assign image_2_padding [5][5] = (Opt_reg[1])? 0 : Image_2_reg[4][4] ;
assign image_2_padding [4][5] = (Opt_reg[1])? 0 : Image_2_reg[4][4] ;
assign image_2_padding [5][4] = (Opt_reg[1])? 0 : Image_2_reg[4][4] ;

assign image_2_padding [5][0] = (Opt_reg[1])? 0 : Image_2_reg[4][1] ;
assign image_2_padding [5][1] = (Opt_reg[1])? 0 : Image_2_reg[4][1] ;
assign image_2_padding [5][2] = (Opt_reg[1])? 0 : Image_2_reg[4][2] ;
assign image_2_padding [5][3] = (Opt_reg[1])? 0 : Image_2_reg[4][3] ;
 
assign image_2_padding [0][5] = (Opt_reg[1])? 0 : Image_2_reg[1][4] ;
assign image_2_padding [1][5] = (Opt_reg[1])? 0 : Image_2_reg[1][4] ;
assign image_2_padding [2][5] = (Opt_reg[1])? 0 : Image_2_reg[2][4] ;
assign image_2_padding [3][5] = (Opt_reg[1])? 0 : Image_2_reg[3][4] ; 

// padding image3
assign image_3_padding [0][0] = (Opt_reg[1])? 0 : Image_3_reg[1][1] ;
assign image_3_padding [0][1] = (Opt_reg[1])? 0 : Image_3_reg[1][1] ;
assign image_3_padding [1][0] = (Opt_reg[1])? 0 : Image_3_reg[1][1] ;
 
assign image_3_padding [0][2] = (Opt_reg[1])? 0 : Image_3_reg[1][2] ;
assign image_3_padding [0][3] = (Opt_reg[1])? 0 : Image_3_reg[1][3] ;
assign image_3_padding [0][4] = (Opt_reg[1])? 0 : Image_3_reg[1][4] ;

assign image_3_padding [2][0] = (Opt_reg[1])? 0 : Image_3_reg[2][1] ;
assign image_3_padding [3][0] = (Opt_reg[1])? 0 : Image_3_reg[3][1] ;
assign image_3_padding [4][0] = (Opt_reg[1])? 0 : Image_3_reg[4][1] ;

assign image_3_padding [5][5] = (Opt_reg[1])? 0 : Image_3_reg[4][4] ;
assign image_3_padding [4][5] = (Opt_reg[1])? 0 : Image_3_reg[4][4] ;
assign image_3_padding [5][4] = (Opt_reg[1])? 0 : Image_3_reg[4][4] ;

assign image_3_padding [5][0] = (Opt_reg[1])? 0 : Image_3_reg[4][1] ;
assign image_3_padding [5][1] = (Opt_reg[1])? 0 : Image_3_reg[4][1] ;
assign image_3_padding [5][2] = (Opt_reg[1])? 0 : Image_3_reg[4][2] ;
assign image_3_padding [5][3] = (Opt_reg[1])? 0 : Image_3_reg[4][3] ;
 
assign image_3_padding [0][5] = (Opt_reg[1])? 0 : Image_3_reg[1][4] ;
assign image_3_padding [1][5] = (Opt_reg[1])? 0 : Image_3_reg[1][4] ;
assign image_3_padding [2][5] = (Opt_reg[1])? 0 : Image_3_reg[2][4] ;
assign image_3_padding [3][5] = (Opt_reg[1])? 0 : Image_3_reg[3][4] ; 

//  ============== pipeline zero  parameter=======================
reg [3:0] count_x ;
reg [1:0] count_y ;
reg [1:0] count_x_reg ;
reg [1:0] count_y_reg ;  
reg [1:0] count_y_shift ; 
wire [2:0] y_origin_plus_y_shift ;
wire [2:0] x_shift_0 , x_shift_1 , x_shift_2 ;
wire [3:0] kernal_y_shift_0 , kernal_y_shift_1 , kernal_y_shift_2  ; 

reg [1:0] count_kernal_reg ;
reg [2:0] count_kernal_y_reg ; 
reg [2:0] count_out_x , count_out_y ; 
reg valid_value ; 
//  ============== out    parameter =============================
wire finish ; 
wire finish_output ;

reg count_out_shift_x , count_out_shift_y ; 

assign y_origin_plus_y_shift = count_y_reg + count_y_shift ; 
assign x_shift_0			 = count_x_reg+ 'd0 ; 
assign x_shift_1			 = count_x_reg+ 'd1 ; 
assign x_shift_2			 = count_x_reg+ 'd2 ; 
assign kernal_y_shift_0		 = count_kernal_y_reg+ 'd0 ; 
assign kernal_y_shift_1		 = count_kernal_y_reg+ 'd1 ; 
assign kernal_y_shift_2		 = count_kernal_y_reg+ 'd2 ; 
assign finish   			 = (count_out_shift_x && count_out_shift_y) ?　1 : 0 ;    //  can change the state to output value
assign finish_output	     = (count_out_x == 7 && count_out_y == 7) ?　  1 : 0 ;    //  output is done , so reset all value and set all valid signal to zero 


always@(posedge clk , negedge rst_n)
begin
    if(!rst_n)
        current_state <= ST_Store_value ;
    else
        current_state  <= next_state ; 
end

always@(*)
begin
	case (current_state)
	ST_Store_value :	begin
							if (finish)
								next_state = ST_Out ;
							else
								next_state = ST_Store_value ; 
						end
	ST_Out			: 	begin
							if (finish_output)
								next_state = ST_Store_value ; 
							else
								next_state = ST_Out ;
						end
	default : next_state = ST_Store_value ; 
	
	endcase
end

// ==========Store_value ================
always@(posedge clk , negedge rst_n)
begin
    if(!rst_n)
        begin
			// =========Store_value paramenters======
			count_value_given_column <= 1 ;
			count_value_given_row    <= 1 ;
			Opt_reg                  <= 0 ;
			valid_value 			<= 0 ;
			for (i=1 ; i<=4 ; i=i+1)
				begin
					for(j=1 ; j <=4 ; j=j+1)
						begin
							Image_1_reg [i][j] <= 0 ;
							Image_2_reg [i][j] <= 0 ;
							Image_3_reg [i][j] <= 0 ;
						end
				end
			for (i=0 ; i<=3 ; i=i+1)
				begin
					for(j=0 ; j <=8 ; j=j+1)
						begin
							Kerna_1_reg [i][j] <= 0 ;
							Kerna_2_reg [i][j] <= 0 ;
							Kerna_3_reg[i][j] <= 0 ;
						end
				end
			count_x     <= 'd0 ; 
			count_y     <= 'd0 ;
        end
    else
        begin
            if (in_valid_o)
                begin
					Opt_reg <= Opt  ;
					count_value_given_column <= 1 ;
					count_value_given_row    <= 1 ; 
                end
            else if (in_valid_i)    
                begin
					count_value_given_row    <= count_value_given_row    + 'd1 ;
					Image_1_reg [count_value_given_column ][count_value_given_row ] <= Image1 ;
					Image_2_reg [count_value_given_column ][count_value_given_row ] <= Image2 ;
					Image_3_reg [count_value_given_column ][count_value_given_row ] <= Image3 ;
					if (count_value_given_row == 4)
						begin
							count_value_given_row    <= 1 ;
							count_value_given_column <= count_value_given_column + 'd1 ;
						end
						
                end
           else if (in_valid_k)
                begin
					Kerna_1_reg[count_y][count_x] <= Kernel1 ;
					Kerna_2_reg[count_y][count_x] <= Kernel2 ;
					Kerna_3_reg[count_y][count_x] <= Kernel3 ;
					
					count_x     <= count_x + 'd1 ;
					if (count_x == 'd8)
						begin
							count_y  <= count_y + 'd1 ;
							count_x  <= 'd0 ;
							valid_value <= 1 ;
						end
                end
			else if (finish_output)
				valid_value <= 'd0 ;
        end
end

// ======== paramenters======
reg [inst_sig_width + inst_exp_width : 0 ] image_1_all [0:5] [0:5];
reg [inst_sig_width + inst_exp_width : 0 ] image_2_all [0:5] [0:5];
reg [inst_sig_width + inst_exp_width : 0 ] image_3_all [0:5] [0:5];

//   pipeline  zero 
always@(*)
begin
	for (i=0 ; i<=5 ; i = i+1)
		begin
			for (j=0 ; j<=5 ; j=j+1)
				begin
					if (j==0  || i==0 || j==5 || i==5 )
						begin
							image_1_all[i][j] <= image_1_padding[i][j] ; 
							image_2_all[i][j] <= image_2_padding[i][j] ; 
							image_3_all[i][j] <= image_3_padding[i][j] ; 
						end
					else
						begin
							image_1_all[i][j] <= Image_1_reg[i][j] ; 
							image_2_all[i][j] <= Image_2_reg[i][j] ; 
							image_3_all[i][j] <= Image_3_reg[i][j] ; 
						end
				end
		end
end
// always@(posedge clk , negedge rst_n)
// begin   
    // if (!rst_n)
        // begin	
			// // kernal_value1 <= 'd0;
			// // kernal_value2 <= 'd0;
			// // kernal_value3 <= 'd0;
			// // valid_value   <= 'd0 ; 
            // for (i=0 ; i<=5 ; i=i+1)
				// begin
					// for(j=0 ; j <=5 ; j=j+1)
						// begin
							// image_1_all [i][j] <= 0 ;
							// image_2_all [i][j] <= 0 ;
							// image_3_all [i][j] <= 0 ;
						// end
				// end
        // end
    // else 
        // begin
			// for (i=0 ; i<=5 ; i = i+1)
                // begin
                    // for (j=0 ; j<=5 ; j=j+1)
                        // begin
                            // if (j==0  || i==0 || j==5 || i==5 )
                                // begin
                                    // image_1_all[i][j] <= image_1_padding[i][j] ; 
                                    // image_2_all[i][j] <= image_2_padding[i][j] ; 
                                    // image_3_all[i][j] <= image_3_padding[i][j] ; 
                                // end
                            // else
                                // begin
                                    // image_1_all[i][j] <= Image_1_reg[i][j] ; 
                                    // image_2_all[i][j] <= Image_2_reg[i][j] ; 
                                    // image_3_all[i][j] <= Image_3_reg[i][j] ; 
                                // end
                        // end
                // end
        // end
// end

//   pipeline  one
wire [inst_sig_width + inst_exp_width : 0 ]  pipeline_one2two[0:8]  ;
reg  [inst_sig_width + inst_exp_width : 0 ]  pipeline_one2two_reg [0:8] ;
reg valid_reg_2 ; 
wire [7:0] status_1[0:8] ; 
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U1 ( .a(image_1_all[y_origin_plus_y_shift][x_shift_0]) , .b(Kerna_1_reg[count_kernal_reg][kernal_y_shift_0]) , .rnd(3'b000) , .z(pipeline_one2two[0]), .status(status_1[0]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U2 ( .a(image_1_all[y_origin_plus_y_shift][x_shift_1]) , .b(Kerna_1_reg[count_kernal_reg][kernal_y_shift_1]) , .rnd(3'b000) , .z(pipeline_one2two[1]), .status(status_1[1]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U3 ( .a(image_1_all[y_origin_plus_y_shift][x_shift_2]) , .b(Kerna_1_reg[count_kernal_reg][kernal_y_shift_2]) , .rnd(3'b000) , .z(pipeline_one2two[2]), .status(status_1[2]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U4 ( .a(image_2_all[y_origin_plus_y_shift][x_shift_0]) , .b(Kerna_2_reg[count_kernal_reg][kernal_y_shift_0]) , .rnd(3'b000) , .z(pipeline_one2two[3]), .status(status_1[3]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U5 ( .a(image_2_all[y_origin_plus_y_shift][x_shift_1]) , .b(Kerna_2_reg[count_kernal_reg][kernal_y_shift_1]) , .rnd(3'b000) , .z(pipeline_one2two[4]), .status(status_1[4]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U6 ( .a(image_2_all[y_origin_plus_y_shift][x_shift_2]) , .b(Kerna_2_reg[count_kernal_reg][kernal_y_shift_2]) , .rnd(3'b000) , .z(pipeline_one2two[5]), .status(status_1[5]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U7 ( .a(image_3_all[y_origin_plus_y_shift][x_shift_0]) , .b(Kerna_3_reg[count_kernal_reg][kernal_y_shift_0]) , .rnd(3'b000) , .z(pipeline_one2two[6]), .status(status_1[6]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U8 ( .a(image_3_all[y_origin_plus_y_shift][x_shift_1]) , .b(Kerna_3_reg[count_kernal_reg][kernal_y_shift_1]) , .rnd(3'b000) , .z(pipeline_one2two[7]), .status(status_1[7]) );
DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U9 ( .a(image_3_all[y_origin_plus_y_shift][x_shift_2]) , .b(Kerna_3_reg[count_kernal_reg][kernal_y_shift_2]) , .rnd(3'b000) , .z(pipeline_one2two[8]), .status(status_1[8]) );


always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=8 ; i=i+1)
				begin
					pipeline_one2two_reg [i] <= 0 ;
				end
			count_kernal_reg		<= 'd0 ;
			count_kernal_y_reg		<= 'd0 ;
			count_x_reg 			<= 'd0 ; 
			count_y_reg 			<= 'd0 ; 
			count_y_shift 			<= 'd0 ;
			valid_reg_2	 			<= 'd0 ;
		end
	else 
		begin
			if (finish_output)
				begin
					valid_reg_2   	   <= 'd0 ;
					count_y_reg        <= 'd0 ;
					count_kernal_y_reg <= 'd0 ;
					count_kernal_reg   <= 'd0 ;
					count_y_shift	   <= 'd0 ;
					count_x_reg		   <= 'd0 ;
				end
			else if (valid_value)
						begin
							valid_reg_2 <= 'd1 ;
							for (i=0 ; i<=8 ; i=i+1)
								pipeline_one2two_reg [i]<= pipeline_one2two[i] ;
								
							if (count_y_reg == 2 )
								begin
									count_y_reg        <= 'd0 ;
									count_kernal_y_reg <= 'd0 ; 
									
									if (count_x_reg == 3)
										begin
											count_x_reg   <= 'd0 ; 
											if (count_y_shift == 3)
												begin
													count_kernal_reg <= count_kernal_reg +'d1 ;
													count_y_shift    <= 'd0 ;
													//   after count_kernal_reg become 0 again , all value have been computed ;  
												end
											else
												count_y_shift <= count_y_shift +'d1 ;
										end
									else
										begin
											count_x_reg		   <= count_x_reg + 'd1 ;
											
										end
								end
							else
								begin
									count_y_reg        <= count_y_reg        +'d1 ;
									count_kernal_y_reg <= count_kernal_y_reg +'d3 ;
								end
						end
			// else
				// valid_reg_2 <= 'd0 ;
		end
end

//   pipeline  two   
wire [inst_sig_width + inst_exp_width : 0 ] tmp [0:3] ;
wire [inst_sig_width + inst_exp_width : 0 ] pipeline_two2three [0:2]  ;
reg [inst_sig_width + inst_exp_width : 0 ] pipeline_two2three_reg [0:2] ;
reg valid_two2three ; 
wire [7:0] status_inst_two_0 , status_inst_two_1 , status_inst_two_2 ,status_inst_two_3 ,status_inst_two_4 , status_inst_two_5;

DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) S1 (.a (pipeline_one2two_reg[0]),   .b(pipeline_one2two_reg[1]), .c(pipeline_one2two_reg[2]) , .rnd(3'b000) , .z(pipeline_two2three[0]) , .status(status_inst_two_0)) ;
DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) S2 (.a (pipeline_one2two_reg[3]),   .b(pipeline_one2two_reg[4]), .c(pipeline_one2two_reg[5]) , .rnd(3'b000) , .z(pipeline_two2three[1]) , .status(status_inst_two_1)) ;
DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) S3 (.a (pipeline_one2two_reg[6]),   .b(pipeline_one2two_reg[7]), .c(pipeline_one2two_reg[8]) , .rnd(3'b000) , .z(pipeline_two2three[2]) , .status(status_inst_two_2)) ;



always@(posedge clk, negedge rst_n)
begin
	if (!rst_n)
		begin
			valid_two2three <= 0 ; 
		end
	else
		begin
			if(finish_output)
				valid_two2three <= 0 ;
			else if(valid_reg_2)
				begin
					valid_two2three  <= 1 ;
				end
		end
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=2 ; i=i+1)
				begin
					pipeline_two2three_reg [i] <= 0;
				end
		end
	else
		begin
			pipeline_two2three_reg[0] <= pipeline_two2three[0] ;
			pipeline_two2three_reg[1] <= pipeline_two2three[1] ;
			pipeline_two2three_reg[2] <= pipeline_two2three[2] ;
		end
end

//   pipeline  three
wire [inst_sig_width + inst_exp_width : 0 ] pipeline_three2four ; 
reg  [inst_sig_width + inst_exp_width : 0 ] pipeline_three2four_reg [0:2] ;
wire [inst_sig_width + inst_exp_width : 0 ] tmp_three ; 
wire [7:0] status_inst_three_0 , status_inst_three_1 ; 
reg [1:0] three_count ; 
reg valid_three2four ; 
DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) S4 (.a (pipeline_two2three_reg[0]),   .b(pipeline_two2three_reg[1]), .c(pipeline_two2three_reg[2]) , .rnd(3'b000) , .z(pipeline_three2four) , .status(status_inst_three_0)) ; 


always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=2 ; i=i+1)
				pipeline_three2four_reg[i] <= 0 ;
			three_count <= 0 ;
			valid_three2four <= 0 ;
		end
	else
		begin
			if (finish_output)
				begin
					valid_three2four <= 0 ;
					three_count		 <= 0 ;
				end
 			else if (valid_two2three)
				begin
					if (three_count == 2)
						begin
							three_count       <= 0  ;
							valid_three2four <= 1 ;
						end
					else
						begin
							three_count       <= three_count + 'd1 ;
							valid_three2four <= 0 ;
						end
					pipeline_three2four_reg[three_count] <= pipeline_three2four ; 
				end
			
		end
end

//   pipeline  four
// wire [inst_sig_width + inst_exp_width : 0 ] pipe_four_tmp[0:3] ; 
wire [inst_sig_width + inst_exp_width : 0 ] four_2_activate ; 
reg  [inst_sig_width + inst_exp_width : 0 ] four_2_activate_reg ;
reg  [inst_sig_width + inst_exp_width : 0 ] four_2_activate_reg_neg ;
wire [inst_sig_width + inst_exp_width : 0 ] tmp_four ; 
wire sign_number ; 
wire [7:0] status_inst_four_0 , status_inst_four_1;  
reg valid_four2five ;

assign sign_number = (four_2_activate[31])? 0:1 ; 
DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) S5 (.a (pipeline_three2four_reg[0]),   .b(pipeline_three2four_reg[1]), .c(pipeline_three2four_reg[2]) , .rnd(3'b000) , .z(four_2_activate) , .status(status_inst_four_0)) ; 

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			valid_four2five			<= 'd0;
		end
	else
		begin
			if (finish_output)
				valid_four2five <= 'd0 ;
			else if (valid_three2four)
				begin
					valid_four2five			<= 'd1 ;
				end
			else
				valid_four2five <= 'd0 ;
		end
end

always@ (posedge clk , negedge rst_n)
begin
	if (!rst_n)	
		begin
			four_2_activate_reg     <= 'd0; 
			four_2_activate_reg_neg <= 'd0;
		end
	else
		begin
			four_2_activate_reg     <= four_2_activate ;
			four_2_activate_reg_neg <= {sign_number,  four_2_activate[30:0]} ;
		end
end
//   pipeline  five (activation function) 
wire [7:0] status_inst_five [0:2] ;
wire [inst_sig_width + inst_exp_width : 0 ] e_x  ;
wire [inst_sig_width + inst_exp_width : 0 ] e_neg_x ; 
wire [inst_sig_width + inst_exp_width : 0 ] zero_point_one_x ; 

reg	 [inst_sig_width + inst_exp_width : 0 ] number_x_five ; 
reg  [inst_sig_width + inst_exp_width : 0 ] e_x_reg ;  
reg  [inst_sig_width + inst_exp_width : 0 ] e_neg_x_reg ;  
reg	 [inst_sig_width + inst_exp_width : 0 ]	Leaky_relu_out_reg ; 
reg  valid_five2six ; 
wire [inst_sig_width + inst_exp_width : 0 ] Leaky_relu_out ; 

assign zero_point_one_x = 32'b0_0111_1011__1001_1001_1001_1001_1001_101 ;
DW_fp_exp # (inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) E1 ( .a(four_2_activate_reg)     , .z(e_x)     , .status(status_inst_five [0])    );
DW_fp_exp # (inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) E2 ( .a(four_2_activate_reg_neg) , .z(e_neg_x) , .status(status_inst_five [1])    );

DW_fp_mult #(inst_sig_width , inst_exp_width , inst_ieee_compliance)   U10 ( .a( zero_point_one_x ) , .b(four_2_activate_reg) , .rnd(3'b000) , .z(Leaky_relu_out) , .status(status_inst_five [2]) );



always@(posedge clk, negedge rst_n)
begin
	if (!rst_n)
		begin
			valid_five2six	   <= 0 ;
		end
	else
		begin
			if (finish_output)
				valid_five2six <= 0 ;
			else if (valid_four2five )
				begin
					valid_five2six		<= 1 ; 
				end
			else
				valid_five2six <= 0 ;
		end
			
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			number_x_five 	   <= 0 ;
			e_x_reg 		   <= 0 ;
			e_neg_x_reg 	   <= 0 ;
			Leaky_relu_out_reg <= 0 ;
		end
	else
		begin
			number_x_five 	    <= four_2_activate_reg ; 
			e_x_reg 			<= e_x ;
			e_neg_x_reg			<= e_neg_x ;
			Leaky_relu_out_reg  <= Leaky_relu_out ; 
		end
end



//   pipeline  six (activation function) two  
wire [7:0] status_inst_six_0 , status_inst_six_1 , status_inst_six_2 ;
wire [inst_sig_width + inst_exp_width : 0 ] plus_ex, subtract_ex, one_plus_ex ;
reg valid_six2quotient ;
reg [inst_sig_width + inst_exp_width : 0 ] devidend  , devisor ; 
reg	 [inst_sig_width + inst_exp_width : 0 ] number_x_six ;
reg [inst_sig_width + inst_exp_width : 0 ] Leaky_relu_six ; 
wire [inst_sig_width + inst_exp_width : 0 ] one_floating; 
assign one_floating = 32'b0_0111_1111__0000_0000_0000_0000_0000_000 ; 
DW_fp_add # (inst_sig_width, inst_exp_width, inst_ieee_compliance)     A11 (.a(e_x_reg),  .b(e_neg_x_reg), .rnd(3'b000) , .z(plus_ex) , .status(status_inst_six_0)  ) ;
DW_fp_addsub #  (inst_sig_width, inst_exp_width, inst_ieee_compliance) AS1 (.a(e_x_reg),  .b(e_neg_x_reg), .rnd(3'b000) , .op(1'd1) , .z (subtract_ex) , .status(status_inst_six_1))  ;
DW_fp_add # (inst_sig_width, inst_exp_width, inst_ieee_compliance)     A12 (.a(one_floating),  .b(e_neg_x_reg), .rnd(3'b000) , .z(one_plus_ex) , .status(status_inst_six_2)  ) ;

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			valid_six2quotient <= 'd0 ; 
		end
	else
		begin
			if (finish_output)
				valid_six2quotient	 <= 'd0; 
			else if (valid_five2six)
				begin
					valid_six2quotient	 <= 'd1; 
				end
			else
				valid_six2quotient <= 'd0 ;
 		end
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			devidend <= 'd0 ;
			devisor  <= 'd0 ;
		end
	else
		begin
			if (Opt_reg[0])
				begin
					devidend <= subtract_ex ; 
					devisor  <= plus_ex  ; 
				end
			else
				begin
					devidend <= one_floating ;
					devisor  <= one_plus_ex  ;
				end
		end
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			number_x_six	<= 'd0 ;
			Leaky_relu_six  <= 'd0 ;
		end
	else
		begin
			Leaky_relu_six   <= Leaky_relu_out_reg ; 
			number_x_six	 <= number_x_five ; 
		end
end

// pipeline  seven (shuffling)
wire [inst_sig_width + inst_exp_width : 0 ] quotient; 
reg [inst_sig_width + inst_exp_width : 0 ] quotient_reg; 
reg [inst_sig_width + inst_exp_width : 0 ] out_data[0:7][0:7] ;
reg valid_quotient_2_seven ; 
reg	 [inst_sig_width + inst_exp_width : 0 ] number_x_seven ;
reg [inst_sig_width + inst_exp_width : 0 ] Leaky_relu_seven ; 

wire [7:0] status_7 ;

DW_fp_div # (inst_sig_width, inst_exp_width, inst_ieee_compliance) D1 (.a(devidend) , .b(devisor) , .rnd(3'b000), .z(quotient) , .status(status_7) ) ;


//  pipeline_quotient 
always@(posedge clk, negedge rst_n)
begin
	if (!rst_n)
		begin
			quotient_reg <= 'd0;
			number_x_seven	<= 'd0 ;
			Leaky_relu_seven  <= 'd0 ;
		end
	else
		begin
			quotient_reg <= quotient ; 
			Leaky_relu_seven   <= Leaky_relu_six ; 
			number_x_seven	 <= number_x_six ; 
		end
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			valid_quotient_2_seven <='d0 ;
		end
	else
		begin
			if (finish_output)
				valid_quotient_2_seven <= 'd0 ;
			else if (valid_six2quotient)
				valid_quotient_2_seven <= 'd1 ;
			else
				valid_quotient_2_seven <= 'd0 ; 
		end
end


// pipeline  seven (shuffling)
reg [2:0] count_2_4_6_x , count_2_4_6_y ;

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=7 ; i=i+1)
				begin
					for (j=0 ; j<= 7 ; j=j+1)
						begin
							out_data[i][j] <=0 ;
						end
				end
			count_2_4_6_y     <= 'd0 ;
			count_2_4_6_x     <= 'd0 ; 
			count_out_shift_y <= 'd0 ;
			count_out_shift_x <= 'd0 ;
			
		end
	else
		begin
			if (finish_output)
				begin
					count_2_4_6_x <= 'd0 ;
					count_2_4_6_y <= 'd0 ;
					count_out_shift_x <= 'd0 ;
					count_out_shift_y <= 'd0 ;
				end
		    else if (valid_quotient_2_seven)
				begin
					if (count_2_4_6_x == 6 )
						begin
							count_2_4_6_x <= 'd0 ;
							
							if (count_2_4_6_y == 6)
								begin
									count_2_4_6_y <= 'd0 ;
									count_out_shift_x <= count_out_shift_x + 'd1 ;
									if (count_out_shift_x )
										begin
										count_out_shift_y <=  count_out_shift_y + 'd1 ;
										end
								end
							else
								count_2_4_6_y <= count_2_4_6_y + 'd2 ;
							
						end
					else
						begin
							count_2_4_6_x <= count_2_4_6_x + 'd2 ;
						end
					
					case (Opt_reg)
					2'b00 :	begin
								if (number_x_seven[31])
									out_data[count_2_4_6_y + count_out_shift_y ][count_2_4_6_x + count_out_shift_x] <= 'd0  ; 
								else
									out_data[count_2_4_6_y + count_out_shift_y ][count_2_4_6_x + count_out_shift_x] <= number_x_seven ;
							end
					2'b01 :	begin
								if (number_x_seven[31])
									out_data[count_2_4_6_y + count_out_shift_y ][count_2_4_6_x + count_out_shift_x] <= Leaky_relu_seven   ; 
								else
									out_data[count_2_4_6_y + count_out_shift_y ][count_2_4_6_x + count_out_shift_x] <= number_x_seven;
							end
					default : out_data[count_2_4_6_y + count_out_shift_y ][count_2_4_6_x + count_out_shift_x] <=  quotient_reg ; 
					endcase 
				end
				
			
		end
end


//  ============Output logic=======  
always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			out 		<= 0 ;
			out_valid   <= 0 ;
			count_out_x <= 0 ;
			count_out_y <= 0 ;
		end
	else if (current_state == ST_Out)
		begin
			out         <= out_data[count_out_y][count_out_x] ; 
			out_valid   <=  1  ;
			if (count_out_x == 7 )
				begin
					count_out_x <= count_out_x + 1 ;
					count_out_y <= count_out_y +  1 ;
				end
			else
				count_out_x <= count_out_x + 1 ;
		end
	else 
		begin
			out_valid <= 0 ;
			out 	  <= 0 ;
		end
end

endmodule