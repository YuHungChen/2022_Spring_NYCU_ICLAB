module ESCAPE(
    //Input Port
    clk,
    rst_n,
    in_valid1,
    in_valid2,
    in,
    in_data,
    //Output Port
    out_valid1,
    out_valid2,
    out,
    out_data
);
//==================INPUT OUTPUT==================//
    input clk, rst_n, in_valid1, in_valid2;
    input [1:0] in;
    input [8:0] in_data;    
    output reg	out_valid1, out_valid2;
    output reg [2:0] out;
    output reg [8:0] out_data;
//================================================//    

parameter Store_value = 3'd0 ;
parameter Block      = 3'd1 ; 
parameter Move      = 3'd2 ; 
parameter Compute      = 3'd3 ; 
//==================Register==================//
reg [4:0]count_row_number , count_column_number ;
wire final_block ;  
reg current_dead_road , past_dead_road; 
integer i,j ;
reg [2:0]hostage_amount ; 
reg is_hostage ; 
reg [1:0] maze_map [0:18][0:18];
reg [1:0]maze_map_reg [1:17][1:17] ; 
reg [4:0] player_x , player_y ; 
reg Move_Right , Move_Down , Move_Up , Move_Left, Got_trap ; 
reg [2:0] hostage_saved ; 
reg touch_end ; 
reg signed [9:0]key[1:4] ;
reg signed [8:0]sort_key[0:3] ; 

reg get_away ; 
reg go_back ; 

reg [2:0]count_out ; 
wire Start ; 
// assign side_up = 0 ;
//=================Current_state=======================// 
reg [2:0] current_state ;
reg [2:0] next_state ;    
always@(posedge clk , negedge rst_n)
begin
    if(!rst_n)
        current_state <= Store_value ;
    else
        current_state <= next_state ; 
end 

//=================Next_state=======================// 
always@(*)
begin
    case(current_state)
        Store_value :   begin
							if (count_column_number == 17 & count_row_number==17)
								next_state = Block ;
							else
								next_state = Store_value ; 
						end
		Block 		:	begin
							if ( final_block  == 1)
							    begin
							         next_state = Move ; 
								end
							else
								next_state = Block ; 
						end
        Move 		:   begin
							if(get_away)
								next_state = Compute ;
							else
								next_state = Move ;
						end	
		Compute		:	begin
		                  if (hostage_amount==0)
		                      begin
		                          if (count_out-2 == 1)
		                              next_state = Store_value ;
                                  else
                                      next_state = Compute ;  
		                      end
		                 else
		                      begin
		                            if (count_out-2 == hostage_amount)
                                        next_state = Store_value ;
                                    else
                                        next_state = Compute ;  
		                      end
		                    
						end
        default : next_state = Store_value ;
    endcase
end



//==================Design==================//

assign Start = (player_x==1 && player_y==1&&  hostage_saved==0 && touch_end==0)? 0:1 ; 
assign final_block = (current_dead_road != past_dead_road) ? 1 : 0 ; 



//All_operation U5 (	.hostage_number(hostage_amount) ,
//					.in0(key[1]),
//					.in1(key[2]),
//					.in2(key[3]),
//					.in3(key[4]),
//					.out0(sort_key[0]),
//					.out1(sort_key[1]),
//					.out2(sort_key[2]),
//					.out3(sort_key[3]));


always@(*)
begin
	for (i=0 ; i<=18 ; i=i+1)
		begin
			for (j=0 ; j<=18 ; j=j+1)
				begin
					if (i==0 || i==18 || j==0 || j==18)
						maze_map[i][j] = 0 ;
					else
						maze_map[i][j] = maze_map_reg[i][j]; 
				end
		end		
end


//================Store Value==================//

always@(posedge clk, negedge rst_n)
begin
    if(!rst_n)
        begin
	//  ==============Store_value parameter======== //
            count_row_number <= 1 ;
            count_column_number <= 1 ;
			hostage_amount <= 0 ;
            for (i=1 ; i<=17 ; i=i+1)
                begin
                    for(j=1 ; j<=17 ; j=j+1)
                        begin
							maze_map_reg[i][j] <= 0 ;
                        end
                end
	//  ==============Block parameter======== //			
            past_dead_road <=0 ; 
            current_dead_road<=0 ;
	//  ==============Move parameter======== //		
			Move_Right <= 0 ;
			Move_Down  <= 1 ;
			Move_Left  <= 0 ;
			Move_Up    <= 0 ;
			player_x   <= 1 ;
			player_y   <= 1 ; 
			hostage_saved <= 0 ;
			go_back <=  0  ;
			touch_end <= 0 ;
			get_away <= 0 ;
			Got_trap <= 0 ;
			is_hostage <= 0 ;
			for (i=1 ; i<=4 ; i = i+1)
				begin
					key[i] <= 0 ;
				end
        end
    else if (current_state == Store_value)
        begin
            if(in_valid1)
                begin
                    maze_map_reg[count_row_number][count_column_number] <= in ; 
                    if (in == 3)
                        hostage_amount <= hostage_amount +1 ;
                        
                    if (count_column_number == 17)
                        begin
                            count_column_number <= 1 ;
                            count_row_number <= count_row_number +1 ; 
                        end
                    else
                        begin
                            count_column_number <= count_column_number +1 ;
                            count_row_number <= count_row_number  ; 
                        end
					
				end	
            else
                begin
                    count_row_number <= 1 ;
                    count_column_number <= 1 ;
                    hostage_amount <= 0  ;
                    key[1] <= 0 ;
                end   
        end
	else if (current_state == Block)
		begin
		    past_dead_road <= past_dead_road + 'd1 ;
		    if (current_dead_road != past_dead_road)
		      begin
		          past_dead_road <= 0 ;
		          current_dead_road <= 0 ;
		      end
			for (i=1 ; i<=17 ; i=i+1)
				begin
					for(j=1 ; j<=17 ; j=j+1 )
						begin
						    if (  (maze_map [i][j] == 1)  ||  (maze_map[i][j]==2 ) )
						        begin
						             if (  (  ( ( maze_map[i+1][j]==0)&&( maze_map[i][j+1]==0 )&& (maze_map[i][j-1]==0) ) ||   ( ( maze_map[i+1][j]==0)&&( maze_map[i-1][j]==0 )&& (maze_map[i][j-1]==0) ) || ( ( maze_map[i+1][j]==0)&&( maze_map[i-1][j]==0 )&& (maze_map[i][j+1]==0) ) || ( ( maze_map[i-1][j]==0)&&( maze_map[i][j+1]==0 )&& (maze_map[i][j-1]==0) )  )   ) 
								        begin                                          //      Only Up corner                                                              //            Only Right corner                                              //  Only Left Cormer                                                    //  Only Down corner                                                                                                       
								        	if ( (i==1 & j==1) || (i==17 & j==17) )  //  if it's happend on the starting point or finish point, then continue
												begin
													maze_map_reg [i][j] <= maze_map_reg [i][j] ;
//													current_dead_road <= current_dead_road ;
												end
											else
												begin
													maze_map_reg [i][j] <= 0 ;
													current_dead_road <= current_dead_road + 'd1 ;
												end
								        end
								    
						        end
						   else
								begin
									maze_map_reg [i][j] <= maze_map_reg [i][j] ; 
								end
						end
				end
		end
	else if (current_state == Move)
		begin
		    if (is_hostage)
				begin
					if (in_valid2)
						begin
							go_back <= 1  ; 
							key[hostage_saved] <= {{in_data[8]},in_data} ; 
						end	
					else if (go_back)
					    is_hostage <= 0 ;
					else
						is_hostage <= is_hostage ;
				end
				
			else if (maze_map[player_y][player_x] == 2  && (Got_trap==0) )
				begin		//  can't move
					Got_trap <= Got_trap + 'd1 ;
				end
				
			else if (player_y==17 && player_x ==17 && hostage_saved == hostage_amount)
			   begin
			         go_back <= 0 ;
			         player_y <= 1 ;
			         player_x <= 1 ;
			         Move_Down <= 1 ;
			         Move_Right <= 0 ;
			         touch_end <= 0 ;
			         hostage_saved <= 0 ;
			         get_away <= 0 ;
			   end
			else
				begin
					Got_trap <= 0 ;
					if (Move_Right)
						begin
							if (maze_map[player_y-1][player_x] == 0)         		//  Up
								begin
									if (maze_map[player_y][player_x+1] == 0) 		 //  Right
										begin
											if (maze_map[player_y+1][player_x] == 0) // Down
												begin
													is_hostage <= 1 ;
													hostage_saved <= hostage_saved + 1 ; 
													Move_Right <= 0 ;
													Move_Left  <= 1 ;   //  next_state consider to go backward
													player_x   <= player_x - 1 ;
													player_y   <= player_y ; 
												end
											else
												begin
													if (player_x==17 && player_y==16 )
														begin
															if (hostage_saved == hostage_amount)
																begin
																	get_away <= 1 ;
																	Move_Down <= 1 ;	
																	Move_Right <= 0 ;
																	player_x   <= player_x ;
																	player_y   <= player_y+1 ;
																end
															else
																begin
																    
																	Move_Left  <= 1 ;
																	Move_Right <= 0 ;
																	player_x   <= player_x -1 ;
																	player_y   <= player_y ; 
																	touch_end    <= 1 ; 
																end
														end
													else
														begin	
															Move_Down <= 1 ;	
															Move_Right <= 0 ;
															player_x   <= player_x ;
															player_y   <= player_y+1 ;
														end
												end
										end
									else
										begin
											if (player_x==16 && player_y==17 )
												begin
													if (hostage_saved == hostage_amount)
														begin
															get_away <= 1 ;
															Move_Right <= 1 ;
															player_x   <= player_x +1 ;
															player_y   <= player_y ;
														end
													else
														begin
															if (maze_map[16][17]!=0)
																begin
																	Move_Right <= 1 ;
																	go_back    <= 0 ;
																	touch_end <= 1 ;
																	player_x   <= player_x +1 ;
																	player_y   <= player_y ;
																end
															else
																begin
																	Move_Left  <= 1 ;
																	Move_Right <= 0 ;
																	player_x   <= player_x -1 ;
																	player_y   <= player_y ; 
																	touch_end    <= 1 ; 
																end
														end
												end
											else
												begin
												    if (touch_end && hostage_saved == hostage_amount)
												        begin
												            if (maze_map[player_y+1][player_x] ==0)
												                begin
												                    Move_Right <= 1 ;
                                                                    player_x   <= player_x +1 ;
                                                                    player_y   <= player_y ;
												                end
												            else
												                begin
												                    Move_Right <= 0 ;
												                    Move_Down  <= 1 ;
																	if (player_x==17 && player_y==16)
																		get_away <= 1 ;
												                    player_x <= player_x ;
												                    player_y <= player_y +1 ;
												                end
                                                        end
                                                    else
                                                        begin
                                                            Move_Right <= 1 ;
                                                            player_x   <= player_x +1 ;
                                                            player_y   <= player_y ;
                                                            if(go_back)
                                                               begin
                                                                   if (maze_map[player_y+1][player_x] == 0)
                                                                       begin
                                                                         go_back <= 1 ;
                                                                       end
                                                                   else
                                                                       begin
                                                                          maze_map_reg[player_y][player_x-1] <=0 ;
                                                                          go_back  <= 0 ;
                                                                       end
                                                               end
                                                        end
												end
										end
								end
							else
								begin
									if(touch_end && (hostage_saved == hostage_amount)  && !( (maze_map[player_y+1][player_x] == 0)&&(maze_map[player_y][player_x+1] == 0)  ) )
										begin																// Down 									// Right
											if (maze_map[player_y+1][player_x] == 0)    // can't Down
												begin
												    //Move_Right   <= 1 ;
													if (player_x==16 && player_y==17 )
															get_away <= 1 ; 
													player_x  	 <= player_x +1 ;
													player_y     <= player_y ; 
												end
											else 										// can't Right
												begin
													if (player_x==17 && player_y==16 )
															get_away <= 1 ;
													Move_Down  <= 1 ;
													Move_Right <= 0 ;
													player_x   <= player_x ;
													player_y   <= player_y + 1 ;
												end
										end
									else
										begin
											Move_Up <= 1 ;
											Move_Right <= 0 ;
											player_x   <= player_x ;
											player_y   <= player_y -1 ;
											if(go_back)
											   begin
											        if (maze_map[player_y][player_x+1] !=0  || maze_map[player_y+1][player_x]!=0)
														begin
															maze_map_reg[player_y][player_x-1] <= 0;
															go_back <= 0 ;
														end
													else
														begin
															go_back <= 1 ;
														end
											   end
										end
								end
						end
						
					if (Move_Down)
						begin
							if (maze_map[player_y][player_x+1] == 0)				// Right
								begin
									if (maze_map[player_y+1][player_x] == 0)		// Down
										begin
											if (maze_map[player_y][player_x-1] == 0)// Left
												begin
													is_hostage <= 1 ;
													hostage_saved <= hostage_saved + 1 ; 
													Move_Down  <= 0 ;
													Move_Up    <= 1 ;   //  next_state consider to go backward
													player_x   <= player_x ;
													player_y   <= player_y-1 ; 
												end
											else
												begin
													Move_Left <= 1 ;
													Move_Down <= 0 ;
													player_x   <= player_x -1;
													player_y   <= player_y ;
												end
										end
									else
										begin
										    if (touch_end == 1 && hostage_saved == hostage_amount)
                                                begin
                                                    if (maze_map[player_y][player_x -1] ==0 )
                                                        begin
                                                            if (player_x==17 && player_y==16 )
								                                get_away <= 1 ; 
                                                            player_x   <= player_x ;
                                                            player_y   <= player_y + 1 ;
                                                        end
                                                    else
                                                        begin
                                                            Move_Left <= 1 ;
                                                            Move_Down <= 0 ;
                                                            player_x  <= player_x - 1 ;
                                                            player_y  <= player_y ;  
                                                        end    
                                                end
										    else
										       begin
                                                    if (player_x==17 && player_y==16 )
                                                        begin
                                                            if (hostage_saved == hostage_amount)
                                                                begin
                                                                    get_away <= 1 ;
        //															Move_Down <= 1 ;
                                                                    player_x   <= player_x ;
                                                                    player_y   <= player_y + 1 ;
                                                                end
                                                            else
                                                                begin
                                                                    if (maze_map[17][16]!=0)
                                                                        begin
                                                                            Move_Down <= 1 ;
                                                                            go_back   <= 0 ;
                                                                            touch_end <= 1 ;
                                                                            player_x   <= player_x ;
                                                                            player_y   <= player_y + 1 ;
                                                                        end
                                                                    else	
                                                                        begin
                                                                            if (maze_map[player_y][player_x-1] == 0)
                                                                                begin
                                                                                    Move_Down  <= 0 ;
                                                                                    Move_Up	   <= 1 ;
                                                                                    player_x   <= player_x ;
                                                                                    player_y   <= player_y - 1 ; 
                                                                                    touch_end    <= 1 ; 
                                                                                end
                                                                            else
                                                                                begin
																					if (go_back)
																						begin
																						maze_map_reg[player_y-1][player_x] <= 0 ;
																						go_back <= 0 ;
																						end
                                                                                    touch_end  <= 1 ;
                                                                                    Move_Left  <= 1 ;
                                                                                    Move_Down  <= 0 ;
                                                                                    player_x   <= player_x - 1 ;
                                                                                    player_y   <= player_y ;
                                                                                end
                                                                        end
                                                                end
                                                        end
                                                    else
                                                        begin	
        //													Move_Down <= 1 ;
                                                            player_x   <= player_x ;
                                                            player_y   <= player_y + 1 ;
                                                            if (go_back)
                                                               begin
                                                                    if (maze_map[player_y][player_x-1] == 0)// Left
                                                                        begin
                                                                            go_back   <= 1  ;
                                                                        end
                                                                    else
                                                                        begin
                                                                            maze_map_reg[player_y-1][player_x] <= 0 ;
                                                                            go_back    <= 0 ;
                                                                        end
                                                               end
                                                        end
                                              end
										end
								end
							else
								begin
								    if (touch_end == 1 && hostage_saved == hostage_amount )
								        begin
								            if (maze_map[player_y][player_x-1] == 0)
								                begin
								                    if (maze_map[player_y+1][player_x] == 0)
								                        begin
								                            if (player_x==16 && player_y==17 )
								                                get_away <= 1 ; 
								                            Move_Down <= 0 ;
								                            Move_Right <= 1 ;
                                                            player_x   <= player_x + 1 ;
                                                            player_y   <= player_y ;
								                        end
								                    else
								                        begin
//								                            Move_Down <= 1 ;
															if (player_x==17 && player_y==16 )
																get_away <= 1 ;
								                            player_x  <= player_x ;
								                            player_y  <= player_y + 1 ;
								                        end
								                end
								            else 
								                begin
								                    Move_Left <= 1 ;
								                    Move_Down <= 0 ;
								                    player_x  <= player_x - 1 ;
								                    player_y  <= player_y ; 
								                end
								        end
								    else
								        begin
                                            if (player_x==16 && player_y==17 )
                                                        begin
                                                            if (hostage_saved == hostage_amount)
                                                                begin
                                                                    get_away   <= 1 ;
                                                                    Move_Down  <= 0 ;
                                                                    Move_Right <= 1 ;
                                                                    player_x   <= player_x + 1 ;
                                                                    player_y   <= player_y ;
                                                                end
                                                            else
                                                                begin
                                                                    if (maze_map[player_y][player_x-1] !=0)
                                                                        begin
                                                                            touch_end <= 1 ;
                                                                            Move_Left <= 1 ;
                                                                            Move_Down  <= 0 ;
                                                                            player_x  <= player_x - 1 ;
                                                                            player_y  <= player_y ;
                                                                        end
                                                                    else
                                                                        begin
                                                                            Move_Up	   <= 1 ;
																			Move_Down  <= 0 ;
                                                                            player_x   <= player_x ;
                                                                            player_y   <= player_y - 1 ; 
                                                                            touch_end    <= 1 ; 
                                                                        end
                                                                end
                                                        end
                                            else
                                                begin
                                                    Move_Down  <= 0 ;
                                                    Move_Right <= 1 ;
                                                    player_x   <= player_x + 1;
                                                    player_y   <= player_y  ;
                                                    if (go_back)   //  go to save hostage then back
                                                        begin
                                                            if (maze_map[player_y+1][player_x] == 0)  // down
                                                                begin
                                                                    if (maze_map[player_y][player_x-1] == 0)// Left
                                                                        begin
                                                                            go_back   <= 1  ;
                                                                        end
                                                                    else
                                                                        begin
                                                                            maze_map_reg[player_y-1][player_x] <= 0 ;
                                                                            go_back    <= 0 ;
                                                                        end
                                                                end
                                                            else
                                                                begin
                                                                    maze_map_reg[player_y-1][player_x] <= 0 ;
                                                                    go_back    <= 0 ; 
                                                                end
                                                        end
                                               end
                                         end
								end
						end
						
					if (Move_Left)
						begin
							if (maze_map[player_y+1][player_x] == 0)					// Down
								begin
									if (maze_map[player_y][player_x-1] == 0)			// Left
										begin
											if (maze_map[player_y-1][player_x] == 0)	// Up
												begin
													is_hostage <= 1 ;
													hostage_saved <= hostage_saved + 1 ; 
													Move_Right <= 1 ;	//  next_state consider to go backward
													Move_Left  <= 0 ;   
													player_x   <= player_x+1 ;
													player_y   <= player_y  ; 
												end
											else
												begin
													Move_Up <= 1 ;	
													Move_Left <= 0 ;
													player_x   <= player_x ;
													player_y   <= player_y -1  ;
												end
										end
									else
										begin
										    if (touch_end==1 && hostage_saved == hostage_amount)
										      begin
										          if(maze_map[player_y-1][player_x]==0)
										              begin
										                  player_x <= player_x - 1;
										                  player_y <= player_y  ;
										              end
										          else
										              begin
										                  Move_Up <= 1;
										                  Move_Left <= 0 ;
										                  player_x <= player_x ;
										                  player_y <= player_y -1 ;
										              end
										      end
										    else
										      begin
        //											Move_Left  <= 1 ;
                                                    player_x   <= player_x -1 ;
                                                    player_y   <= player_y ;
                                                    if (go_back)
                                                       begin
                                                          if(maze_map[player_y-1][player_x] == 0)
                                                             go_back<= 1 ;
                                                          else
                                                             begin
                                                                maze_map_reg[player_y][player_x+1] <= 0 ;
                                                                go_back    <= 0 ;
                                                             end
                                                       end
                                              end
										end
								end
							else
								begin
								    if (touch_end == 1 && hostage_saved == hostage_amount )
								        begin
								             if (maze_map [player_y -1][player_x] ==0)
								                begin
								                    if (maze_map[player_y][player_x-1] ==0)
								                        begin
								                            Move_Down <= 1 ;
								                            Move_Left <= 0 ;
								                            player_x  <= player_x ;
								                            player_y  <= player_y + 1 ;
								                        end
								                    else
								                        begin
								                            player_x <= player_x - 1;
								                            player_y <= player_y ;
								                        end
								                end
								             else
								                begin
								                    Move_Up   <= 1 ;
								                    Move_Left <= 0 ;
								                    player_x  <= player_x ;
								                    player_y  <= player_y - 1;
								                end
								        end
								   else
								        begin
                                            Move_Down <= 1 ;
                                            Move_Left <= 0 ;
                                            player_x   <= player_x ;
                                            player_y   <= player_y +1 ;
                                            if (go_back)   //  go to save hostage then back
                                                begin
                                                    if (maze_map[player_y][player_x-1] == 0)  // left
                                                        begin
                                                            if (maze_map[player_y-1][player_x] == 0)// Up
                                                                begin
                                                                    go_back   <= 1  ;
                                                                end
                                                            else
                                                                begin
                                                                    maze_map_reg[player_y][player_x+1] <= 0 ;
                                                                    go_back    <= 0 ;
                                                                end
                                                        end
                                                    else
                                                        begin
                                                            maze_map_reg[player_y][player_x+1] <= 0 ;
                                                            go_back    <= 0 ; 
                                                        end
                                                end
                                       end
								end
						end
					
					if (Move_Up)
						begin
							if (maze_map[player_y][player_x-1] == 0)    				// Left
								begin
									if (maze_map[player_y-1][player_x] == 0)			// Up
										begin
											if (maze_map[player_y][player_x+1] == 0)	// Right
												begin
													is_hostage <= 1 ;
													hostage_saved <= hostage_saved + 1 ;
													Move_Up    <= 0 ;
													Move_Down  <= 1 ;   //  next_state consider to go backward
													player_x   <= player_x ;
													player_y   <= player_y +1 ; 
												end
											else
												begin
													Move_Right <= 1 ;
													Move_Up    <= 0 ;
													player_x   <= player_x + 1;
													player_y   <= player_y ;
												end
										end
									else
										begin
										    if (maze_map[player_y][player_x+1] == 0)
										        begin
//                                                Move_Up <= 1 ;
										            player_x   <= player_x ;
                                                    player_y   <= player_y - 1 ; 
										        end
										    else
										        begin
                                                    if (touch_end &&(hostage_saved == hostage_amount) )
										                  begin
                                                                Move_Right <= 1 ;
                                                                Move_Up    <= 0 ;
                                                                player_x   <= player_x +1 ; 
                                                                player_y   <= player_y ; 
										                  end
										            else  if  (go_back)
										                  begin
										                      go_back <= 0;
										                      maze_map_reg[player_y+1][player_x] <= 0;
										                      player_x   <= player_x ;
                                                              player_y   <= player_y - 1 ; 
										                  end
										            else
										                  begin
										                      player_x   <= player_x ;
                                                              player_y   <= player_y - 1 ; 
										                  end
										        end
										        
										end
								end
							else
								begin
									if(touch_end && (hostage_saved == hostage_amount)  )
										begin																
											if (maze_map[player_y][player_x+1] != 0)   // Right
												begin
													Move_Right <= 1 ;
													Move_Up    <= 0 ;
													player_x   <= player_x+1 ;
													player_y   <= player_y ; 
												end
											else if (maze_map[player_y-1][player_x] != 0 ) // UP 
												begin
//													Move_Up   <= 1 ;
													player_x  <= player_x ;
													player_y  <= player_y-1 ; 
												end
											else
												begin
													Move_Left <= 1 ;
													Move_Up  <= 0 ;
													player_x   <= player_x - 1;
													player_y   <= player_y  ;
												end
										end
									else
										begin
											Move_Left <= 1 ;
											Move_Up  <= 0 ;
											player_x   <= player_x - 1;
											player_y   <= player_y  ;
											if (go_back)
												begin
													if (maze_map[player_y-1][player_x] != 0  || maze_map[player_y][player_x+1] !=0   )
														begin
															maze_map_reg [player_y+1] [player_x] <= 0;
															go_back <= 0 ;
														end
												end
										end
								end
						end
				end
		end
end

wire signed [8:0] excess[0:3] ;
wire signed [8:0] half_of_range ;

All_operation U5 (	.hostage_number(hostage_amount) ,
					.in0(key[1]),
					.in1(key[2]),
					.in2(key[3]),
					.in3(key[4]),
					.excess_0(excess[0]),
					.excess_1(excess[1]),
					.excess_2(excess[2]),
					.excess_3(excess[3]),
					.half_of_range (half_of_range));

reg signed [8:0] excess_reg [0:3] ;
reg signed [8:0] half_of_range_reg  ; 
reg [8:0] out_data_reg [0:3] ; 
// reg out_valid1_reg ; 
always@(posedge clk , negedge rst_n)
begin
    if (!rst_n)
        begin
            count_out <= 0 ;
			// out_valid1_reg <= 0 ;
			for (i=0 ; i <=4 ; i=i+1)
				out_data_reg[i]   <= 0 ;
				
			out_valid1 <=0 ;
			out_data <= 0 ;
			for (i=0 ; i <=3 ; i=i+1)
			 begin
			     excess_reg[i] <= 0 ;
			 end
			 half_of_range_reg <= 0 ;
        end
    else if (current_state == Compute)
        begin
             if (count_out ==0 )
	           begin
	               count_out <= count_out + 1 ; 
	               half_of_range_reg <=  half_of_range ;
	               excess_reg[0] <= excess[0] ;
	               excess_reg[1] <= excess[1] ;
	               excess_reg[2] <= excess[2] ;
	               excess_reg[3] <= excess[3] ;
				   out_valid1 <= 0 ;
				   out_data <= 0 ;
	           end
			else if (count_out == 1 )
				begin
					out_data_reg[0]  <= sort_key[0];
					out_data_reg[1]  <= sort_key[1];
					out_data_reg[2]  <= sort_key[2];
					out_data_reg[3]  <= sort_key[3];
					count_out 	     <= count_out +1 ;
					out_valid1  <= 0 ;
					out_data    <= 0 ;
				end
			else if(count_out-2 < hostage_amount || (count_out==2 && hostage_amount==0) )
				begin
				    out_valid1 <= 1 ;
					count_out <= count_out +1 ;
					out_data <= out_data_reg[count_out-2];
				end
			else 
				begin
				    out_data   <= 0;
				    out_valid1 <=0 ;
					count_out  <= 0 ;
					// out_valid1_reg <= 0 ;
				end
        end
end

always@(*)
begin
    if (hostage_amount >1)
        begin
                if (hostage_amount >2)
                    begin
                        sort_key[0] = (excess_reg[0]-half_of_range_reg) ;
                        sort_key[1] = ( (excess_reg[1]-half_of_range_reg)+sort_key[0]*2 )/3 ;
                        sort_key[2] = ( (excess_reg[2]-half_of_range_reg)+sort_key[1]*2 )/3 ;
                        sort_key[3] = ( (excess_reg[3]-half_of_range_reg)+sort_key[2]*2 )/3 ;
                    end
                else
                    begin
                        sort_key[0] = excess_reg[0] - (excess_reg[0] + excess_reg[1]) / 2  ; 
                        sort_key[1] = excess_reg[1] - (excess_reg[0] + excess_reg[1] ) /2  ;
                        sort_key[2] = 0 ;
                        sort_key[3] = 0 ;
                    end
        end
   else
            begin
                sort_key[0] = key[1];
                sort_key[1] = 0;
                sort_key[2] = 0;
                sort_key[3] = 0; 
            end
        end
        //=============Output Logic==========================//  
always@(posedge clk , negedge rst_n)
begin
    if (!rst_n)
        begin
            out <= 0 ;
            out_valid2 <= 0 ;
        end
    else if (Start)
        begin
            if (is_hostage)
                begin
                    out <= 0 ;
                    out_valid2 <= 0 ;
                end
            else if (Got_trap)
                    begin
                        out <= 4 ;
                        out_valid2 <= 1 ; 
                        end
                    else if (Move_Right)
                    begin
                        out <= 0 ;
                        out_valid2 <= 1 ;
                        end
                    else if (Move_Down)
                        begin
                            out <= 1 ;
                            out_valid2 <= 1 ;
                    end
                else if (Move_Left)
                    begin
                        out <= 2 ;
                        out_valid2 <= 1 ;
                    end
                else if (Move_Up)
                    begin
                        out <= 3 ;
                        out_valid2 <= 1 ;
                    end
                else
                    begin
                        out <= 0 ;
                        out_valid2 <= 0 ;
                    end
            end
	else
		begin
			out <= 0 ;
			out_valid2 <= 0 ;
		end
end
//==========================================//  



endmodule



module two_comparator(in0,in1,out0,out1);
            
input signed [9:0] in0 , in1 ;
output reg signed [9:0]out0, out1;

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

module All_operation (hostage_number, in0,in1,in2,in3 ,   half_of_range,  excess_0 , excess_1 , excess_2, excess_3 );

input [2:0] hostage_number ; 
input signed [9:0] in0 , in1, in2, in3 ;
wire signed[1:0]  tag0 , tag1 , tag2 , tag3  ; 
//output reg signed [8:0]out0, out1, out2, out3;

//reg signed [9:0] excess[0:3] ;
 output reg signed [8:0] excess_0 , excess_1 , excess_2  , excess_3 ;
 output reg signed [8:0]half_of_range ; 
 
wire signed [9:0]big_1 , big_2  , small_1 , small_2    ;
wire signed [9:0]tmp_1 , tmp_2 ; 
wire signed [9:0]sort_0, sort_1, sort_2 , sort_3 ; 
wire signed [9:0] new_in_3 ; 
wire signed [9:0] new_out_1 , new_out_2 ; 
assign new_in_3 = (hostage_number ==4 )? in3 : in2 ; 

wire signed [7:0] compute_excess [0:3] ;
wire signed [7:0] compute_excess_two_hostage [0:1] ; 
assign compute_excess[0] = (hostage_number ==4) ? (sort_0[3:0]-3)+ (sort_0[7:4]-'d3)*'d10  :   compute_excess_two_hostage[0] ; 
assign compute_excess[1] = (hostage_number ==4) ? (sort_1[3:0]-3)+ (sort_1[7:4]-'d3)*'d10 :  compute_excess_two_hostage[1]  ; 
assign compute_excess[2] = (sort_2[3:0]-3)+ (sort_2[7:4]-'d3)*'d10 ; 
assign compute_excess[3] = (sort_3[3:0]-3)+ (sort_3[7:4]-'d3)*'d10 ; 

assign compute_excess_two_hostage[0] = (big_1  [3:0]-3)+ (big_1  [7:4]-'d3)*'d10 ; 
assign compute_excess_two_hostage[1] = (small_1[3:0]-3)+ (small_1[7:4]-'d3)*'d10 ; 

//wire signed [9:0] one_subtract ; 
//reg signed [9:0]half_of_range ; 
wire xor_0_1 , xor_1_2 ; 
wire define_tag_0 , define_tag_1 ; 

assign define_tag_0 = (hostage_number==4) ? sort_0[9] : big_1   [9] ;
assign define_tag_1 = (hostage_number==4) ? sort_1[9] : small_1 [9] ;

assign tag0 = (define_tag_0 )? -1 : 1 ;
assign tag1 = (define_tag_1 )? -1 : 1 ;
assign tag2 = (sort_2[9])? -1 : 1 ;
assign tag3 = (sort_3[9])? -1 : 1 ;



assign xor_0_1 = (tag0[1] ^ tag1[1]) ; 
// assign xor_3_4 = (tag3[1] ^ tag4[1]) ; 
assign xor_1_2 = (tag1[1] ^ tag2[1]) ; 

//assign one_subtract  = excess[1]-half_of_range ;


//	==== sorting  ==============
two_comparator U0 (	.in0(in0),
					.in1(in1),
					.out0(big_1),
					.out1(small_1)) ; 

two_comparator U1 (	.in0(in2),
					.in1(new_in_3),
					.out0(big_2),
					.out1(small_2)) ; 

two_comparator U2 (	.in0(big_1),
					.in1(big_2),
					.out0(sort_0),
					.out1(tmp_1)) ;

two_comparator U3 (	.in0(small_1),
					.in1(small_2),
					.out0(tmp_2),
					.out1(sort_3)) ; 
			
two_comparator U4 (	.in0(tmp_1),
					.in1(tmp_2),
					.out0(sort_1),
					.out1(sort_2) ); 

two_comparator U5 (	.in0(small_1),         // to compute   out value for hostage ==3 
 					.in1(tmp_1),
					.out0(new_out_1),
					.out1(new_out_2) ); 

// ======  EXCESS 3 ===========
always@(*)
begin
    if (hostage_number%2 ==0 )
        begin                     // 4 , 2 
           excess_0 =  ( compute_excess[0] )*tag0 ; 
            excess_1 =  ( compute_excess[1] )*tag1 ; 
            excess_2 =  ( compute_excess[2] )*tag2 ; 
            excess_3 =  ( compute_excess[3] )*tag3 ; 
            
        end
    else 
        begin                      // 3
            excess_0 = sort_0 ;
            excess_1 = new_out_1 ; 
            excess_2 = new_out_2 ;
            excess_3 = 0    ;  
        end
end
//   get  maximun + minimum  ; 
always@(*)
begin
    if (hostage_number == 3)
        begin
            half_of_range = (excess_0 + excess_2 ) / 2 ; 
        end
	else if (xor_0_1)
		begin
			half_of_range = ( excess_0 + excess_1 ) / 2 ; 
		end
	else if (xor_1_2)	
		begin
			half_of_range = ( excess_0 + excess_2 ) / 2 ; 
		end
	else	
		begin
		    if (hostage_number == 4)
			      half_of_range = ( excess_0 + excess_3 ) / 2 ;
			else
			      half_of_range =  ( excess_0 + excess_2 ) / 2 ; 
		end
end



endmodule


