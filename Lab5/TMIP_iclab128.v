module TMIP(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
	img_size,
    template, 
    action,
	
// output signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);

input        clk, rst_n, in_valid, in_valid_2;
input [15:0] image, template;
input [4:0]  img_size;
input [2:0]  action;

output reg        out_valid;
output reg [3:0]  out_x, out_y; 
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

parameter ST_in = 'd8 ;
parameter ST_out = 'd9 ; 
reg [3:0] current_state ;
reg [3:0] next_state ; 

parameter Convolution = 'd0 ;
parameter Max_pooling = 'd1 ;
parameter Horizontal_f = 'd2 ;
parameter Vertical_f   = 'd3 ;
parameter Left_diagonal_f = 'd4 ;
parameter Right_diagonal_f = 'd5 ;
parameter Zoom_i       = 'd6 ;
parameter Shortcut_brightness = 'd7;

integer i,j  ;


reg [5:0] img_size_reg;
wire finish_output ; 
// assign valid_size = (img_size_reg==0) ? 0 : 1 ;    // to check whether in_valid is first time or not ; 

reg wen_1, wen_2   ; 
reg cen_1 ,cen_2   ;
reg signed [39:0] my_out , max ;
reg [4:0] current_x ,  current_y , max_x , max_y ;

wire signed [15:0]Q_data_from_1_or_2  ;
// ===================  Compute   RAM  Address ==================
reg [3:0] count_to_img_size ;
reg [3:0] count_number_of_row_done ;
reg [1:0] count_zoom_in_set ; 
reg [3:0] count_9  ;
reg [1:0] count_3  ; 
reg RAM1 , RAM2 ; 


wire start  ;
wire [7:0] square ; 
wire finish_action_horizon ;
wire finish_action_maxpool ;
wire finish_action_vertical ;
// wire finish_short_cut ; 
wire finish_zoom_in   ;
wire finish_conv ; 
wire one_row_col_done ; 
// =======================================================



reg [7:0] count_img_addr[0:1] ;
reg even ; 
wire  signed [15:0] RAM_Read_1 ; 
wire  signed [39:0] RAM_Read_2 ; 

wire  signed [15:0] RAM_Data_1 ;
wire  signed [39:0] RAM_Data_2 ; 

reg  signed [15:0] tmp_value ; 
reg [7:0] count_out ; 
reg starting_flag_n ;
reg img_size_4_short_cut_flag ;

assign finish_output = (count_out== square)? 1 :0 ; 

assign RAM_Data_1 = (in_valid)? image :
					(current_state == Max_pooling 	|| 	current_state == Zoom_i   || 	current_state == Shortcut_brightness ) ? tmp_value : RAM_Read_2[15:0]   ;
					

assign RAM_Data_2 = (in_valid)? image :
				    (current_state == Convolution 			 ) ? my_out	    :
					(current_state == Max_pooling 	|| 	current_state == Zoom_i   || 	current_state == Shortcut_brightness ) ? tmp_value : RAM_Read_1   ;
					
assign Q_data_from_1_or_2  = (wen_1 == 1 )? RAM_Read_1 : RAM_Read_2[15:0] ; 


//    ================ Convolution parameter ==================== 
reg [15:0]kernal_3_3[0:8] ;  
reg [3:0]count_kernal ;
wire signed [15:0] kernal_number [1:9] ;
assign kernal_number[1] = 																         kernal_3_3[4] ;
assign kernal_number[2] = (current_y == img_size_reg -1) ? 							  		 0 : kernal_3_3[5] ;
assign kernal_number[3] = (current_y == img_size_reg -1 || current_x == img_size_reg -1 ) ?  0 : kernal_3_3[8] ;
assign kernal_number[4] = (current_x == img_size_reg -1) ?  							     0 : kernal_3_3[7] ;
assign kernal_number[5] = (current_y == 0            || current_x == img_size_reg -1 ) ?     0 : kernal_3_3[6] ;
assign kernal_number[6] = (current_y == 0           ) ? 							  		 0 : kernal_3_3[3] ;
assign kernal_number[7] = (current_y == 0            || current_x == 0            ) ? 		 0 : kernal_3_3[0] ;
assign kernal_number[8] = (current_x == 0           ) ? 							  		 0 : kernal_3_3[1] ;
assign kernal_number[9] = (current_y == img_size_reg -1 || current_x == 0         ) ? 		 0 : kernal_3_3[2] ;



												//	  6 7 8 
												//	  5 0 1
										        //	  4 3 2	
always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)									
		begin
			my_out <= 'd0 ;
		end
	else if (current_state == Convolution)
		begin
			if (count_9 == 0)
				my_out <= 'd0 ;
			else
				begin
					if (kernal_number [count_9] != 0)
						my_out <= my_out + Q_data_from_1_or_2 * kernal_number[count_9] ; 
				end
			     // if (count_9 == 1)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[4] ;
				// end
			// else if (count_9 == 2)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[5] ;
				// end
			// else if (count_9 == 3)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[8] ;
				// end
			// else if (count_9 == 4)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[7] ;
				// end
			// else if (count_9 == 5)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[6] ;
				// end
			// else if (count_9 == 6)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[3] ;
				// end
			// else if (count_9 == 7)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[0] ;
				// end
			// else if (count_9 == 8)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[1] ;
				// end
			// else if (count_9 == 9)
				// begin
					// my_out = Q_data_from_1_or_2 * kernal_3_3[2] ;
				// end
		end
end

always@(posedge clk , negedge rst_n)   // tmp_value  for Max_pooling , Zoom_i , Shortcut_brightness
begin
	if(!rst_n)
		begin
			tmp_value <= 'd0 ;
		end
	else if (current_state == Max_pooling)
		begin
			if (count_zoom_in_set == 1)
				tmp_value <= Q_data_from_1_or_2 ; 
			else if (Q_data_from_1_or_2 > tmp_value)
				tmp_value <= Q_data_from_1_or_2 ;
		end
	else if (current_state == Zoom_i) 
		begin
		    if (count_zoom_in_set == 0)
				tmp_value <= Q_data_from_1_or_2  ; 
			else if (count_zoom_in_set == 1 )
				tmp_value <= ( (Q_data_from_1_or_2 * 2 ) / 3  ) + 20 ;
			else if (count_zoom_in_set == 2 )
				tmp_value <= (Q_data_from_1_or_2 >>> 1) ;
			else   // count_zoom_in_set  == 3
				tmp_value <= Q_data_from_1_or_2 / 3   ;
		end
	else if (current_state == Shortcut_brightness)
		begin
			tmp_value <=  ( Q_data_from_1_or_2 >>> 1 )  + 50 ;
		end
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)
		begin
			max   <= 'd0 ;
			max_x <= 'd0 ;
			max_y <= 'd0 ;
		end
	else if (current_state == Convolution)
		begin
			if (count_9 == 0 )
				begin
					if(my_out > max  || count_img_addr[1] == 0)
						begin
							max    <= my_out ;
							max_x  <= current_x ;
							max_y  <= current_y ; 
						end
				end
		end
	// else if (finish_conv)
		// begin
			
		// end
end

always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)
		begin
			current_x <= 0 ;
			current_y <= 0 ;
		end
	else if (current_state == Convolution)
		begin
			if (count_9 == 0 && starting_flag_n  && !start)
				begin
					if (current_y == img_size_reg-1 )
						begin
							current_y <= 'd0 ;
							current_x <= current_x + 1 ;
						end
					else
						current_y <= current_y + 'd1 ;
				end
		end	
	else
		begin
			current_x <= 'd0 ;
			current_y <= 'd0 ;
		end
end



assign start = (cen_1 & cen_2) ? 1: 0 ;
assign finish_action_horizon = (count_img_addr[RAM2] == square && starting_flag_n && !start) ? 1 : 0 ;
							   // (count_img_addr[RAM1] == square  && img_size_reg==8   ) ? 1 :
							   // (count_img_addr[RAM1] == square  && img_size_reg==4   ) ? 1 : 0 ;
assign finish_action_maxpool = (count_img_addr[RAM2] == 63 && img_size_reg == 16 && count_zoom_in_set==1 && !start ) ? 1 : 
							   (count_img_addr[RAM2] == 16 && img_size_reg ==  8 && count_zoom_in_set==1 && !start) ? 1 : 0 ;  

assign finish_action_vertical =(count_img_addr[RAM2] == 0 && starting_flag_n && !start )? 1 :0 ; 

// assign finish_short_cut		 = (count_img_addr[RAM2] == square && starting_flag_n && !start ) ? 1 : 0 ;
							   // (count_img_addr[RAM2] == square  && img_size_reg==8   ) ? 1 :
							   // (count_img_addr[RAM2] == square  && img_size_reg==4   ) ? 1 : 0 ;

assign finish_zoom_in		 = (count_img_addr[RAM2] == square-img_size_reg && !start ) ?  1 : 0 ; 

assign finish_conv			 = (count_img_addr[RAM2] == square  && count_9 == 0 && !start) ?  1 : 0 ; 
							   
assign one_row_col_done       =(count_to_img_size == img_size_reg-1)? 1:0 ; 
// assign one_row_done_for_vertical = (count_img_addr_1 == 0			  )? 1:0 ; 

assign square = (img_size_reg == 16) ? 255 : 		// 255-1
				(img_size_reg == 8 ) ? 63  : 		// 63 -1
				(img_size_reg == 4 ) ? 15  : 5 ;	// 15 -1

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_9  <= 'd0 ;
		end
	else if (count_9 == 'd9)
		begin
			count_9  <= 'd0 ;
		end
	else if (current_state == Convolution)
		begin
			if (cen_1)
				count_9 <= 'd0 ;
			else
				count_9  <= count_9 + 'd1 ;
		end
	else
		count_9  <= 'd0 ;
end

reg [1:0] stall_three_cycle ;

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		count_3 <= 'd0 ;
	else if (count_3 == 'd3)
		count_3 <= 'd0 ;
	else if (stall_three_cycle ==3 )
		count_3 <= count_3 + 'd1 ;
	else 
		count_3 <= 'd0 ;
end

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_to_img_size  <= 'd0 ;
		end
	else if (count_to_img_size == img_size_reg - 'd1 )
		begin
			count_to_img_size  <= 'd0 ;
		end
	else if (cen_1 == 0)
		begin
			count_to_img_size  <= count_to_img_size + 'd1 ;
		end
	else
		count_to_img_size  <= 'd0 ;
end

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_number_of_row_done <= 'd0 ;
		end
	else if (start)
		begin
			count_number_of_row_done <= 'd0 ;
		end
	else if (count_to_img_size == 'd1)
		begin
			count_number_of_row_done <= count_number_of_row_done + 'd1 ;
		end
end

always@ (posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_zoom_in_set <= 'd0 ;
		end
	else if (cen_1)
		begin
			count_zoom_in_set <= 'd0 ;
		end
	else if (current_state == Max_pooling)
		begin
			count_zoom_in_set  <= count_zoom_in_set + 'd1 ;
		end
	else if (starting_flag_n && (current_state == Zoom_i  ) )
		begin
			count_zoom_in_set  <= count_zoom_in_set + 'd1 ;
		end	
	else
		begin
			count_zoom_in_set <= 'd0 ;
		end
end

wire address_plus_1 ; 
assign address_plus_1 = (count_zoom_in_set == 3) ? 1 : 0 ; 

reg [4:0] count_zoom_set_move ;
always@ (posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_zoom_set_move <= 'd0 ;
		end
	else if (start)
		begin
			count_zoom_set_move <= 'd0 ;
		end
	else if (count_zoom_set_move == img_size_reg  && count_zoom_in_set=='d0)
		begin
			count_zoom_set_move <= 'd0 ;
		end
	else if (count_zoom_in_set == 1 || count_zoom_in_set == 3)
		begin
			count_zoom_set_move <= count_zoom_set_move + 'd1 ;
		end
end




always@(posedge clk , negedge rst_n )
begin
	if(!rst_n )
		starting_flag_n <= 'd1 ;
	else if (start)
		starting_flag_n <= 'd0 ;
	else 
		starting_flag_n <= 'd1 ;
end

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)	
		img_size_4_short_cut_flag <= 'd0;
	else if (current_state == Shortcut_brightness)
		begin
			if (start && img_size_reg == 4)
				img_size_4_short_cut_flag <= 'd1 ;
		end
	else
		img_size_4_short_cut_flag <= 'd0 ;
end

always@(posedge clk , negedge rst_n)
begin	
	if(!rst_n)
		begin
			stall_three_cycle <= 'd0 ;
		end
	else if (current_state == Max_pooling)
		begin
			if (cen_1)
				stall_three_cycle <= 'd0 ; 
			else if (stall_three_cycle != 3)
				stall_three_cycle <= stall_three_cycle + 'd1 ;
			else if (finish_action_maxpool)
				stall_three_cycle <= 'd0 ; 
		end
	else if (current_state == Zoom_i  )
		begin
			if (stall_three_cycle != 3)
				stall_three_cycle <= stall_three_cycle + 'd1 ;
			else if (finish_zoom_in)
				stall_three_cycle <= 'd0 ; 
		end
	else if (current_state == Shortcut_brightness)
		begin
			if (stall_three_cycle != 3)
				stall_three_cycle <= stall_three_cycle + 'd1 ;
			else if (finish_action_horizon)
				stall_three_cycle <= 'd0 ;
		end
	else
		stall_three_cycle <= 'd0 ; 
end
				
always@(posedge clk, negedge rst_n)   // mem operation  
begin
	if (!rst_n)
		begin
			count_img_addr[0]  <= 'd0 ;
			count_img_addr[1]  <= 'd0 ;
			wen_1    		   <= 'd0 ;
			wen_2    		   <= 'd0 ;
			cen_1		 	   <= 'd0 ;
			cen_2		 	   <= 'd0 ;
			RAM1			  <= 'd0 ;
			RAM2			  <= 'd1 ;
			
			// horizontal_f_value 
		end
	else
		begin
			if (in_valid)
				begin
					count_img_addr[RAM1] <=  count_img_addr[RAM1] + 'd1 ;  
					count_img_addr[RAM2] <=  count_img_addr[RAM2] + 'd1 ;   
					if (finish_action_horizon)  // same as horizon
						begin
							cen_1 <= 'd1 ;
							cen_2 <= 'd1 ;
						end
					// wen_1 		 <= 0 ;
					// wen_2		 <= 0 ; 
					// cen_1		 <= 0 ;
					// cen_2		 <= 0 ;
				end
			else if (in_valid_2)
				begin
					count_img_addr[RAM1] <= 'd0 ;
					count_img_addr[RAM2] <= 'd0 ;
					if (even)    // RAM2 40 bit
						begin				// if the number of action is even , then write in 16bit first , so its last_state is read . 
							wen_1 <= 'd1;  
							wen_2 <= 'd0;
							RAM1  <= 'd0;
							RAM2  <= 'd1;
						end
					else
						begin
							wen_1 <= 'd0; 
							wen_2 <= 'd1;
							RAM1  <= 'd1;
							RAM2  <= 'd0;
						end
				end
			else if (current_state == Convolution)   // each action should reset addr ;   // each state should change the state of WEN 
				begin
					if (start)													//	  6 7 8 
						begin													//	  5 0 1
							cen_1 <= 0 ;										//	  4 3 2	
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM1] <= 'd0 ;
							count_img_addr[RAM2] <= 'd0 ;
						end
					else
						begin
							if (finish_conv)
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
							// if (!starting_flag_n)
								// count_img_addr[RAM1] <= count_img_addr[RAM1] ; 
							// else
							if (count_9 == 0 && starting_flag_n  && !start)
								begin
									count_img_addr[RAM2] <= count_img_addr[RAM2]  + 'd1 ;
								end
							// if (!starting_flag_n)
								// count_img_addr[RAM1] <= count_img_addr[RAM1] ; 
						    if (count_9 == 'd8  || count_9 == 'd1)
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1]  + img_size_reg ;
								end
							else if (count_9 == 'd0 || count_9 == 'd6  || count_9 == 'd7  )
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1]  + 'd1; 
								end
							else if (count_9 == 'd2 || count_9 == 'd3)
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1] - 'd1 ;
								end
							else if (count_9 == 'd4 || count_9 == 'd5)
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1] - img_size_reg ;
								end
							
						end
				end
			else if (current_state == Max_pooling)
				begin
													//   0 3 --> 0 3 -->
					if (start )						// 	 1 2 	 1 2
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM1] <= 'd0 ;
							count_img_addr[RAM2] <= 'd0 ;
						end
					else
						begin
							if (finish_action_maxpool)
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
							if (count_zoom_in_set == 1 && stall_three_cycle==3)
								count_img_addr[RAM2] <= count_img_addr[RAM2]  + 'd1 ;
							
							if (count_zoom_in_set ==3 && count_zoom_set_move == img_size_reg-1)
								count_img_addr[RAM1] <= count_img_addr[RAM1]  + (img_size_reg + 'd1 ) ;
							else if (count_zoom_in_set == 1 || count_zoom_in_set == 3 )
								count_img_addr[RAM1] <= count_img_addr[RAM1]  + 'd1 ;
							else if (count_zoom_in_set == 0 )
								count_img_addr[RAM1] <= count_img_addr[RAM1]  + img_size_reg ;
							else if (count_zoom_in_set == 2) 
								count_img_addr[RAM1] <= count_img_addr[RAM1]  - img_size_reg ;
								
						end
				
				end
			else if (current_state == Horizontal_f)
				begin
					
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM2] <= img_size_reg-1 ; // RAM2 last_state = RAM1
							count_img_addr[RAM1] <= 'd0			   ; // RAM1 last_state = RAM2
							//count_img_addr[RAM0] <= 'd0 ;
						end
					else
						begin
							if (finish_action_horizon)
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
						
							if (one_row_col_done)
								count_img_addr[RAM1] <= count_img_addr[RAM1] + (img_size_reg*2-1)  ;
							else
								count_img_addr[RAM1] <= count_img_addr[RAM1]  - 'd1 ;
							
							if (starting_flag_n)
								count_img_addr[RAM2] <= count_img_addr[RAM2]  + 'd1 ;
						end
				
				end
			else if (current_state == Vertical_f)
				begin
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM2] <= img_size_reg-1 ;  //  start at top    right corner 
							count_img_addr[RAM1] <= square ;        //  start at bottom_right corner 
						end
					else
						begin
							if (finish_action_vertical)
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
							if (starting_flag_n)
								count_img_addr[RAM2] <= count_img_addr[RAM2]  - 'd1 ;
							
							if (one_row_col_done)
								count_img_addr[RAM1] <= count_img_addr[RAM1] + (img_size_reg*2-1)  ;
							else
								count_img_addr[RAM1] <= count_img_addr[RAM1]  - 'd1 ;
						end
						
				end
			else if (current_state == Left_diagonal_f)
				begin
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM2] <= square ;  //  start at top    left corner   // Read address
							count_img_addr[RAM1] <= 'd0    ;  //  start at bottom_right corner  // Write address
							
						end
					else
						begin
							if (finish_action_horizon)   // same sa finish_action of horizon 
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
							
							if (one_row_col_done)
								begin
									count_img_addr[RAM1] <= square  - count_number_of_row_done ; 
								end
							else 
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1]  - img_size_reg ;
								end
								
							if (starting_flag_n)
								count_img_addr[RAM2] <= count_img_addr[RAM2]  + 'd1 ;
						end
						
				end
			else if (current_state == Right_diagonal_f)
				begin
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM2] <= 'd0 ;  // Read address
							count_img_addr[RAM1] <= 'd0 ;  // write address       
							
						end
					else
						begin
							if (finish_action_horizon)   // same sa finish_action of horizon
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
							
							if (one_row_col_done)
								begin
									count_img_addr[RAM1] <= count_number_of_row_done ; 
								end
							else
								begin
									count_img_addr[RAM1] <= count_img_addr[RAM1]  + img_size_reg ;
								end
								
							if (starting_flag_n)
								count_img_addr[RAM2] <= count_img_addr[RAM2]  + 'd1 ;
						end
				end
			else if (current_state == Zoom_i)
				begin
					if (start )
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM1] <= 'd0 ; // Write address
							count_img_addr[RAM2] <= 'd0 ; // Read address  
							
						end
					else
						begin
							if (finish_zoom_in)   // same sa finish_action of horizon 
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
								
							if (count_3 == 'd1 )
								count_img_addr[RAM1] <= count_img_addr[RAM1]  + 'd1 ;
							
							if (count_zoom_set_move == img_size_reg  && count_3=='d3)
								begin
									count_img_addr[RAM2] <= count_img_addr[RAM2]  + (img_size_reg + 'd1 )  ; 
								end
							else if (count_3 == 0 && stall_three_cycle==3)
								begin
									count_img_addr[RAM2] <= count_img_addr[RAM2]  + img_size_reg ;
								end
							else if (count_3 == 2)
								begin
									count_img_addr[RAM2] <= count_img_addr[RAM2]  - img_size_reg ;
								end
							else if (count_3 == 1 || count_3 == 3)
								begin
									count_img_addr[RAM2] <= count_img_addr[RAM2]  +  'd1  ; 
								end
						end
				end
			else if (current_state == Shortcut_brightness)
				begin
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= ~wen_1 ;
							wen_2 <= ~wen_2 ;
							RAM1  <= RAM2   ;
							RAM2  <= RAM1   ; 
							count_img_addr[RAM1] <= 'd0 ;  // Write address
							
							if (img_size_reg == 4)
								begin
									count_img_addr[RAM2] <= 'd0 ;     // Read address
								end
							else if (img_size_reg == 8)
								begin
									count_img_addr[RAM2] <= 'd18 ;    // Read address
								end
							else
								begin
									count_img_addr[RAM2] <= 'd68 ;    // Read address
								end
							
						end
					else
						begin
							if (finish_action_horizon)   // same sa finish_action of horizon 
								begin
									cen_1 <= 1 ;
									cen_2 <= 1 ;
								end
								
							if (img_size_4_short_cut_flag)
								count_img_addr[RAM1] <= count_img_addr[RAM1] + 'd1 ;
							else if (one_row_col_done)
								count_img_addr[RAM1] <= count_img_addr[RAM1] + img_size_reg + 'd1 ;
							else
								count_img_addr[RAM1] <= count_img_addr[RAM1] + 'd1 ;
							
							if (stall_three_cycle==3)
								count_img_addr[RAM2] <= count_img_addr[RAM2] + 'd1 ;
						end
				end
			else if (current_state == ST_out)
				begin
					if (start)
						begin
							cen_1 <= 0 ;
							cen_2 <= 0 ;
							wen_1 <= 0 ;
							wen_2 <= 1 ;
							count_img_addr[RAM1] <= 'd0 ;							
							count_img_addr[RAM2] <= 'd0 ;  
							
						end
					else
						begin
							if (finish_output)  
								begin
									// cen_1 <= 1 ;
									// cen_2 <= 1 ;
									wen_1 <= 'd0 ;
									wen_2 <= 'd0 ;
									count_img_addr[0]  <= 'd0 ;
								    count_img_addr[1]  <= 'd0 ;
									RAM1			  <= 'd0 ;
									RAM2			  <= 'd1 ;
								end
							else
								count_img_addr[1] <= count_img_addr[1] + 'b1 ;
						end
				end
			// else if (finish_output)
				// begin
					// count_img_addr[0]  <= 'd0 ;
					// count_img_addr[1]  <= 'd0 ;
					// wen_1    		   <= 'd0 ;
					// wen_2    		   <= 'd0 ;
					// cen_1		 	   <= 'd0 ;
					// cen_2		 	   <= 'd0 ;
					// RAM1			  <= 'd0 ;
					// RAM2			  <= 'd1 ;
				// end
		end
end



RAM_16 U_SRAM  (.Q(RAM_Read_1),.CLK(clk),.CEN(cen_1),.WEN(wen_1),.A(count_img_addr[0]),.D(RAM_Data_1),.OEN(1'b0));// 256 words  / 16 bit
RAM_40 U_SRAM2 (.Q(RAM_Read_2),.CLK(clk),.CEN(cen_2),.WEN(wen_2),.A(count_img_addr[1]),.D(RAM_Data_2),.OEN(1'b0));// 256 words  /  40 bit


always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_kernal <= 'd0 ; 
		end
	else if (in_valid)
		begin
			if (count_kernal != 9)
				count_kernal <= count_kernal + 'd1 ;
		end
	else
		count_kernal <= 'd0 ; 
end

always@(posedge clk, negedge rst_n)		//  store template value 
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=8 ; i=i+1)
			begin
				kernal_3_3[i] <= 0  ;
			end
		end
	else if (in_valid)
		begin
			if (count_kernal < 9 )
				begin
					kernal_3_3 [count_kernal] <= template ;
				end
			
		end
end

reg count_img_size ; 
always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			count_img_size <= 'd0 ;
		end
	else if (in_valid)
		begin
			count_img_size <= 'd1 ;
		end
	else 
		begin
			count_img_size <= 'd0 ; 
		end
end

always@(posedge clk , negedge rst_n)  // get_image_size
begin
	if (!rst_n)
		begin
			img_size_reg <= 'd0 ;
		end	
	else if (current_state == Max_pooling )
		begin
			if (finish_action_maxpool)
				begin
					if (img_size_reg == 'd16)
						img_size_reg <= 'd8 ;
					else
						img_size_reg <= 'd4 ;
				end
		end
	else if (current_state == Zoom_i )
		begin
			if (start)
				begin
					if (img_size_reg == 'd4)
						img_size_reg <= 'd8 ;
					else
						img_size_reg <= 'd16 ;
				end
		end
	else if (current_state == Shortcut_brightness )
		begin
			if (start)
				begin
					if (img_size_reg == 'd16)
						img_size_reg <= 'd8 ;
					else
						img_size_reg <= 'd4 ;
				end
		end
	else
		begin
			if (in_valid)
				begin
					if (! count_img_size )
						img_size_reg <= img_size ; 
				end
		end
end 

reg [2:0] action_reg [0:15] ; 
reg [4:0] count_action_number ;
reg finish_sort ; 
reg [4:0] tmp_size_store ;

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin	
			tmp_size_store <= 'd0 ;
		end
	else if (in_valid)
		tmp_size_store <= img_size_reg ;
	else if (in_valid_2)
		begin
			if (tmp_size_store == 4)
				begin
					if(action == Zoom_i)
						tmp_size_store <= 'd8 ;
				end
			else if (tmp_size_store == 8)
				begin
					if (action == Zoom_i)
						tmp_size_store <= 'd16 ;
					else if (action == Max_pooling || action == Shortcut_brightness)
						tmp_size_store <= 'd4 ;
				end
			else 
				begin
					if (action == Max_pooling || action == Shortcut_brightness)
						tmp_size_store <= 'd8 ;
				end
		end
		
end
// wire added ;

// assign added = (finish_action_vertical || finish_short_cut || finish_action_horizon) ? 0 : 1 ; 
// always@(posedge clk , negedge rst_n)
// begin
	// if(!rst_n)
		// added <= 0 ;
	// else if (finish_action_vertical || finish_short_cut || finish_action_horizon)
		// added <= 0 ;
	// else
		// added 
// end

always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		even <= 'd0 ;
	else if (in_valid_2)
		begin
			if (tmp_size_store == 'd4 && (action == Max_pooling ))
				even <= even ;
			else if (tmp_size_store == 'd16 && action == Zoom_i)
				even <= even ; 
			else
				even <= even +'d1 ;
		end
	else
		even <= 'd0 ;
end

always@(posedge clk , negedge rst_n)
begin
	if (!rst_n)begin
			count_action_number <= 'd0 ;
	end
	// else if (in_valid) begin
		// count_action_number <= 'd0 ;
	// end
	else if (in_valid_2)begin
		if (action == Convolution)
			count_action_number <= 'd1 ;
		else if (tmp_size_store == 'd4 && (action == Max_pooling ) )
			begin
				count_action_number <= count_action_number ;
			end
		else if (tmp_size_store == 'd16 && (action == Zoom_i) )
			begin
				count_action_number <= count_action_number ;
			end
		else if (count_action_number != 0)
			begin
				if (action == action_reg[count_action_number -1 ] && (action== 2 || action==3 || action==4 || action==5) )
					count_action_number <= count_action_number - 'd1 ;
				else
					count_action_number <= count_action_number + 'd1 ;
			end
		else 
			count_action_number <= count_action_number + 'd1 ;

	end
	else if (current_state == Max_pooling)begin
			if (finish_action_maxpool  )
				count_action_number <= count_action_number + 'd1 ;
	end
	else if (current_state == Horizontal_f)begin
			if (finish_action_horizon)
				count_action_number <= count_action_number + 'd1 ;
	end
	else if (current_state == Vertical_f)begin
			if (finish_action_vertical)
				count_action_number <= count_action_number + 'd1 ;
	end
	else if (current_state == Left_diagonal_f)begin
			if (finish_action_horizon)
				count_action_number <= count_action_number + 'd1 ;
	end
	else if (current_state == Right_diagonal_f)begin
			if (finish_action_horizon)
				count_action_number <= count_action_number + 'd1 ;				
	end
	else if (current_state == Zoom_i)begin     // when starting action , count the number of action we do .  
		if (finish_zoom_in )
			count_action_number <= count_action_number + 'd1 ;
	end
	else if ( current_state == Shortcut_brightness)begin
			if (finish_action_horizon)
				count_action_number <= count_action_number + 'd1 ;
	end
	else
		count_action_number <= 'd0 ;
	// else if (current_state == ST_out  )begin
			// count_action_number <= 'd1 ;
	// end
	 
end

always@(posedge clk , negedge rst_n)   // 
begin
	if (!rst_n)
		begin
			for (i=0 ; i<=15; i=i+1)begin
				action_reg[i] <= 0 ;
			end
		end
	else if (in_valid_2)
		begin
			if (tmp_size_store == 'd4 && (action == Max_pooling ) )
				action_reg[count_action_number] <= 'd0 ;
			else if (tmp_size_store == 'd16 && action == Zoom_i)
				action_reg[count_action_number] <= 'd0 ;
			else
				action_reg[count_action_number] <= action  ; 
		end
	// else if (finish_output)
		// begin
			// action_reg[0] <= 'd0;
		// end
	// else if (finish_action_horizon)
		// begin
		
		// end
	// else if (finish_action_vertical)
		// begin
		
		// end
	// else if (finish_short_cut)
		// begin
		
		// end
	// else
		// begin
		
		// end
		
end

reg finish_get_value ;
always@(*)
begin
    if (in_valid_2 && (action == Convolution) )
		finish_get_value = 'd1 ;
	else	
		finish_get_value = 'd0 ;
end

// finite state maching
always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		current_state <= ST_in ;
	else
		current_state <= next_state ; 
end

always@(*)
begin
	case(current_state)
		ST_in :	begin
			if (finish_get_value )
				begin
					if (count_action_number == 0)
						next_state = Convolution ;
					else
						next_state = action_reg[0] ; 
				end
			else
				next_state = ST_in ; 
		end
		Convolution : begin
			if (finish_conv)
				next_state = ST_out ;
			else
				next_state = Convolution ; 
		end
		Max_pooling : begin
			if (finish_action_maxpool  )
				next_state = action_reg[count_action_number] ;
			else
				next_state = Max_pooling ; 
		end
		Horizontal_f : begin
			if (finish_action_horizon)
				next_state = action_reg[count_action_number] ;
			else
				next_state = Horizontal_f ;
		end
		Vertical_f   : begin
			if (finish_action_vertical)
				next_state = action_reg[count_action_number] ;
			else
				next_state = Vertical_f ;
		end
		Left_diagonal_f : begin
			if (finish_action_horizon)
				next_state = action_reg[count_action_number] ;
			else
				next_state = Left_diagonal_f ;
		end
		Right_diagonal_f : begin
			if (finish_action_horizon)
				next_state = action_reg[count_action_number] ;
			else
				next_state = Right_diagonal_f ;
		end
		Zoom_i			: begin
			if (finish_zoom_in )
				next_state = action_reg[count_action_number] ;
			else
				next_state = Zoom_i ;
		end
		Shortcut_brightness : begin
			if (finish_action_horizon)
				next_state = action_reg[count_action_number] ;
			else
				next_state = Shortcut_brightness ;
		end
		ST_out 				: begin
			if (finish_output)
				next_state = ST_in ;
			else
				next_state = ST_out ;
		end
		
		default : next_state = ST_in ; 
	
	endcase
end






reg [1:0] stop_one_cycle; 

// Output Assignment
always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		out_valid      <= 'd0;
		out_x          <= 'd0;
		out_y          <= 'd0;
		out_value      <= 'd0;
		count_out      <= 'd0;
		stop_one_cycle <= 'd0;
	end
	else if(current_state == ST_out  ) begin 
		if (stop_one_cycle !=2)
			begin
				stop_one_cycle <= stop_one_cycle + 'd1 ;
				out_valid      <= 'd0;
				out_x          <= 'd0;
				out_y          <= 'd0;
				out_value      <= 'd0;
				count_out      <= 'd0;
			end
		else
			begin
				out_valid   <= 'd1;
				out_x       <= max_x;
				out_y       <= max_y;
				out_value   <= RAM_Read_2 ;      // 40 bit 
				count_out   <= count_out +'d1 ;
			end
	end 
	else begin
		out_valid      <= 'd0;
		out_x          <= 'd0;
		out_y          <= 'd0;
		out_value      <= 'd0;
		count_out      <= 'd0;
		stop_one_cycle <= 'd0; 
	end
end

reg dirty_flag [0:8] ;
reg [8:0] valid_9_corner ;
always@(*)
begin
	if (max_x == 'd0 && max_y == 'd0)    // top_left corner
		begin
			valid_9_corner = 9'b000_011_011 ;
		end
	else if (max_x == 0 && max_y== img_size_reg - 1 ) // top_Right corner
		begin
			valid_9_corner = 9'b000_110_110 ;
		end
	else if ( (max_x == img_size_reg - 1) && (max_y == img_size_reg - 1) ) // bottom_right
		begin
			valid_9_corner = 9'b110_110_000 ;
		end
	else if ( (max_x ==  img_size_reg - 1) && (max_y == 0 ) ) // bottom_left
		begin
			valid_9_corner = 9'b011_011_000 ;
		end
	else if ( max_x == 'd0)
		begin
			valid_9_corner = 9'b000_111_111 ;
		end
	else if ( (max_y == img_size_reg - 1) )
		begin
			valid_9_corner = 9'b110_110_110 ;
		end
	else if ( (max_x == img_size_reg - 1)  )
		begin
			valid_9_corner = 9'b111_111_000 ;
		end
	else if ( max_y == 0  )
		begin
			valid_9_corner = 9'b011_011_011 ;
		end
	else
		begin
			valid_9_corner = 9'b111_111_111 ;
		end
end 

always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		out_img_pos <= 'd0;
		for (i=0 ; i<=8 ;i=i+1 )
			dirty_flag[i] <= 'd0 ;
	end
	else if(current_state == ST_out && stop_one_cycle == 2) begin 
		if (valid_9_corner [8] && dirty_flag[8]==0)
			begin
				out_img_pos  <= (max_y - 1)+ (max_x -1)*img_size_reg ; 
				dirty_flag[8]<= 'd1 ;
			end
		else if (valid_9_corner [7] && dirty_flag[7]==0)
			begin
				out_img_pos  <= (max_y    )+ (max_x -1)*img_size_reg ; 
				dirty_flag[7]<= 'd1 ;
			end
		else if (valid_9_corner [6] && dirty_flag[6]==0)
			begin
				out_img_pos  <= (max_y + 1)+ (max_x -1)*img_size_reg ; 
				dirty_flag[6]<= 'd1 ;
			end
		else if (valid_9_corner [5] && dirty_flag[5]==0)
			begin
				out_img_pos  <= (max_y - 1 )+ (max_x   )*img_size_reg ; 
				dirty_flag[5]<= 'd1 ;
			end
		else if (valid_9_corner [4] && dirty_flag[4]==0)
			begin
				out_img_pos  <= (max_y     )+ (max_x   )*img_size_reg ; 
				dirty_flag[4]<= 'd1 ;
			end
		else if (valid_9_corner [3] && dirty_flag[3]==0)
			begin
				out_img_pos  <= (max_y + 1 )+ (max_x   )*img_size_reg ; 
				dirty_flag[3]<= 'd1 ;
			end
		else if (valid_9_corner [2] && dirty_flag[2]==0)
			begin
				out_img_pos  <= (max_y - 1)+ (max_x +1)*img_size_reg ; 
				dirty_flag[2]<= 'd1 ;
			end
		else if (valid_9_corner [1] && dirty_flag[1]==0)
			begin
				out_img_pos  <= (max_y    )+ (max_x +1)*img_size_reg ; 
				dirty_flag[1]<= 'd1 ;
			end
		else if (valid_9_corner [0] && dirty_flag[0]==0)
			begin
				out_img_pos  <= (max_y + 1)+ (max_x +1)*img_size_reg ; 
				dirty_flag[0]<= 'd1 ;
			end
		else
			begin
				out_img_pos <= 'd0 ;
			end
	end 
	else begin
		out_img_pos <= 'd0;
		for (i=0 ; i<=8 ;i=i+1 )
			dirty_flag[i] <= 'd0 ;
	end
end

endmodule
