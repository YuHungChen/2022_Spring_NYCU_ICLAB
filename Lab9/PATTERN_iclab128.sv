`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
integer first_flag ; 
integer total_cycles ; 
integer cycles;  
integer patcount ; 
integer player_count ; 
bit temp_value ;
// integer gap ; 
integer invalid_op ; 

integer player_id_data ; 
integer full_money ; 
logic [15:0] initial_money ; 
logic [10:0] money_addr_first ;
bit Monery_overflow , exp_not_zero , used_bracer, change_or_not; 
integer Def ; 



//================================================================
// wire & registers 
//================================================================

Action 	     now_action ; 
Error_Msg    err_msg ;
Bag_Info     My_bag  ;
PKM_Info     My_POK , Def_POK ; 
 
parameter PATNUM = 1000 ; 
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";

logic [7:0] golden_DRAM[ (65536+0) : ((65536+256*8)-1) ] ; 
initial $readmemh(DRAM_p_r, golden_DRAM);

// parameter SEED = 107501008 ; 

class random_item_class;
	rand Item    	Item_data;
	constraint limit {
		Item_data	inside{ Berry, Medicine, Candy, Bracer, Water_stone, Fire_stone, Thunder_stone };
	}
endclass

class random_money_class;
	rand Money 		Money_data;
	constraint limit {
		Money_data	inside{ [1:10000] };
	}
endclass

class random_type_class;
	rand PKM_Type   Type_data ; 
	constraint limit {
		Type_data	inside{ Grass, Fire, Water, Electric, Normal };
	}
endclass

class random_act;
	randc Action     act_data ; 
	constraint limit {
		act_data	inside{ Buy, Sell, Deposit, Use_item, Check, Attack };
	}
endclass

// class defender;
	// rand Player_id  defender_id ; 
// endclass


class gap_in_valid ; 
	rand int gap_in_valid_num ;
	rand int gap_out_valid ; 
	constraint limit {
		gap_in_valid_num	inside{[1:1]};
		gap_out_valid inside {[1:1]} ; 
	}
endclass

// parameter timeout = 100000;
int	i;
int latency, latency_flag;


random_item_class  ITEM  = new();
random_money_class MONEY = new();
random_type_class  TYPE  = new();
random_act ACTION= new(); 
gap_in_valid gap = new();
// defender	Def  = new(); 
// logic [2:0]btn_decode;
// bit f_buy_pass;
// bit f_rtn_coin_pass = 0;
// coin coin_tmp;



function logic [9:0] price_buy_item;
	input Item item_class;
	price_buy_item  =	(item_class == Berry     )?16:
						(item_class == Medicine  )?128:
						(item_class == Candy     )?300:
						(item_class == Bracer    )?64 : 800  ;  //  800 for stone
endfunction

function logic [9:0] price_sell_item;
	input Item item_class;
	price_sell_item  =	(item_class == Berry     )?12:
						(item_class == Medicine  )?96:
						(item_class == Candy     )?225:
						(item_class == Bracer    )?48 : 600  ;  //  600 for stone
endfunction

function logic [9:0] price_buy_POK;
	input PKM_Type type_class;
	price_buy_POK  =	(type_class == Grass     )?100:
						(type_class == Fire      )?90:
						(type_class == Water     )?110:
						(type_class == Electric  )?120 : 130  ;  //  800 for stone
endfunction



integer player_addr , defender_addr; 
		
initial begin	
inf.rst_n    = 1'b1;
inf.id_valid   = 'd0 ;
inf.act_valid  = 'd0 ;
inf.item_valid = 'd0 ;
inf.type_valid = 'd0 ;
inf.amnt_valid = 'd0 ;

// gap = 'd1;
player_id_data = 'd0 ;
player_count = 'd0;
first_flag = 1; 
total_cycles = 0 ;
used_bracer  = 0 ;
reset_task ; 
for (patcount=0 ; patcount < PATNUM ; patcount=patcount+1 ) begin
	
	input_task ; 
	compute_answer ; 
	write_to_DRAM ; 
	wait_out_valid_task ;
	check_answer ; 
	repeat(gap.gap_out_valid) @ (negedge clk ) ;
	// $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
end
pass_task;
end

task pass_task ; begin
	$finish ; 
end endtask


task input_task ; begin
	// gap_in_valid gap = new();
	 ITEM.randomize() ;
	MONEY.randomize() ;
	 TYPE.randomize() ;
   ACTION.randomize() ; 
		
	if (patcount <= 10 ) begin
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Buy ;
	
	end else if (patcount <= 31 ) begin    // Buy -> Sell -> Buy -> Sell -> Buy -> Sell -> Buy -> Sell .....   Sell -> Buy  -> Deposit 
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Sell ;
	end else if (patcount <= 52 )begin
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Deposit ;
	end else if (patcount <= 73) begin
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Use_item ;
	end else if (patcount <= 94) begin
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Check ;
	end else if (patcount <= 115) begin
										if (patcount % 2 == 0 )
											now_action = Buy ;
										else 
											now_action = Attack ;
	end else if (patcount <= 126) begin
										if (patcount % 2 == 0 )
											now_action = Sell ;
										else 
											now_action = Sell ;										
	end else if (patcount <= 147) begin
										if (patcount % 2 == 0 )
											now_action = Sell ;
										else 
											now_action = Deposit ;
	end else if (patcount <= 168) begin
										if (patcount % 2 == 0 )
											now_action = Sell ;
										else 
											now_action = Use_item ;
	end else if (patcount <= 189) begin
										if (patcount % 2 == 0 )
											now_action = Sell ;
										else 
											now_action = Check ;
	end else if (patcount <= 210) begin
										if (patcount % 2 == 0 )
											now_action = Sell ;
										else 
											now_action = Attack ;
	end else if (patcount <= 221) begin
										if (patcount % 2 == 0 )
											now_action = Deposit ;
										else 
											now_action = Deposit ;											
	end else if (patcount <= 242) begin
										if (patcount % 2 == 0 )
											now_action = Deposit ;
										else 
											now_action = Use_item ;
	end else if (patcount <= 263) begin
										if (patcount % 2 == 0 )
											now_action = Deposit ;
										else 
											now_action = Check ;
	end else if (patcount <= 284) begin
										if (patcount % 2 == 0 )
											now_action = Deposit ;
										else 
											now_action = Attack ;
	end else if (patcount <= 295) begin
										if (patcount % 2 == 0 )
											now_action = Use_item ;
										else 
											now_action = Use_item ;
    end else if (patcount <= 316) begin
										if (patcount % 2 == 0 )
											now_action = Use_item ;
										else 
											now_action = Check ;
	end else if (patcount <= 337) begin
										if (patcount % 2 == 0 )
											now_action = Use_item ;
										else 
											now_action = Attack ;
	
	end else if (patcount <= 348) begin
										if (patcount % 2 == 0 )
											now_action = Check ;
										else 
											now_action = Check ;										
	end else if (patcount <= 369) begin
										if (patcount % 2 == 0 )
											now_action = Check ;
										else 
											now_action = Attack ;
	end else if (patcount <= 380) begin
										if (patcount % 2 == 0 )
											now_action = Attack ;
										else 
											now_action = Attack ;
	// end else if (patcount >= 400 && patcount <= 410) begin	
		// now_action = Use_item ; 								
	end else if (patcount >= 400 && patcount <= 500) begin	
		now_action = Use_item ; 
	end else if (patcount >= 800) begin
		now_action = Use_item ; 
	end else if (patcount >= 500  && patcount %2 == 0 ) begin  
		now_action = Use_item ; 
	end else if (patcount >= 500  && patcount %2 == 1 ) begin
		now_action = Attack ; 
	// end else if (patcount == 397 || patcount == 398 ) begin
		// now_action = Sell ; 
	end else begin
		now_action =Buy ;     //   it must meet
	end
	
	

	
	// if (!change_or_not)
		// change_or_not = 'd1 ;
	// else
		// change_or_not = $urandom_range(0,1) ;  
	
	// gap = $urandom_range (1,5);
	inf.id_valid   = 'd0 ;
	inf.act_valid  = 'd0 ;
	inf.item_valid = 'd0 ;
	inf.type_valid = 'd0 ;
	inf.amnt_valid = 'd0 ;
	@(negedge clk) ; 
	// repeat(gap.gap_in_valid_num)@(negedge clk) ; 
	if (patcount === 'd0 )begin
		give_new_player ; 
		used_bracer   = 0 ; 
		
		//   if money overflow
		initial_money = { golden_DRAM [65536 + player_id_data*8 + 2 ] [5:0], golden_DRAM [65536 + player_id_data*8 + 3 ] };
		full_money = initial_money + MONEY.Money_data ;
		if ( (full_money > 16383) && now_action == Deposit)begin
			now_action = Buy ; 
		end else if ( (  (16383 - initial_money) < 'd1300) && now_action == Sell )begin
			now_action = Buy ;
		end 
		
		gap.randomize() ;
		repeat(gap.gap_in_valid_num)@(negedge clk );
		give_action ; 
		gap.randomize() ;
		repeat(gap.gap_in_valid_num)@(negedge clk );
		

		temp_value = $urandom_range (0,1) ; 
			
		case (now_action)
			Buy  : if (temp_value ==0)give_item ; else give_PKM_type ;
			Sell : if (temp_value ==0)give_item ; else give_PKM_type ;
			Deposit : give_money ; 
			Use_item : give_item ;
			Attack   : give_Def_ID ; 
		endcase
	end else begin
		if (player_id_data == 'd255)begin
			player_id_data = 'd0 ;
			used_bracer = 0 ;   // change_player
			give_new_player ;
		end else if (patcount >= 800) begin
			if (patcount == 800)
				player_id_data = 'd205 ; 
			else
				player_id_data = player_id_data +'d1 ;
				
			used_bracer = 0 ;   // change_player
			give_new_player ;
		end else if ( patcount >=500  && patcount %2 == 1 ) begin
			player_id_data = player_id_data ; 
		end else if ( (patcount >= 'd397 && patcount <= 'd400)  || (patcount >= 'd295 && patcount <= 'd317) || (patcount >= 'd337 && patcount <= 'd348)     )begin
			player_id_data = player_id_data ; 
		end else begin
			player_id_data = player_id_data +'d1 ;
			used_bracer = 0 ;   // change_player
			give_new_player ;
		end
		
		//   if money overflow
		initial_money = { golden_DRAM [65536 + player_id_data*8 + 2 ] [5:0], golden_DRAM [65536 + player_id_data*8 + 3 ] };
		full_money = initial_money + MONEY.Money_data ;
		if ( (full_money > 16383) && now_action == Deposit)begin
			now_action = Buy ; 
		end else if ( (  (16383 - initial_money) < 'd1300) && now_action == Sell )begin
			now_action = Buy ;
		end 
		
		if (player_id_data == 'd0)begin
			gap.randomize() ;
			repeat(gap.gap_in_valid_num)@(negedge clk );
			give_action ; 
		end else if (patcount >= 800) begin
			gap.randomize() ;
			repeat(gap.gap_in_valid_num)@(negedge clk );
			give_action ;
		end else if ( patcount >=500  && patcount %2 == 1 )
			give_action ; 
		else if  ( (patcount >= 'd397 && patcount <= 'd400)  || (patcount >= 'd295 && patcount <= 'd317) || (patcount >= 'd337 && patcount <= 'd348)   ) begin
			give_action ;
		end else begin
			gap.randomize() ;
			repeat(gap.gap_in_valid_num)@(negedge clk );
			give_action ; 
		end 
		
		if (now_action != Check)begin
			gap.randomize() ;
			repeat(gap.gap_in_valid_num)@(negedge clk );
		end
		
		if (patcount >400)
			temp_value = 1 ; 
		else		
			temp_value = $urandom_range (0,1) ; 
			
		case (now_action)
			Buy  : if (temp_value ==0)give_item ; else give_PKM_type ;
			Sell : if (temp_value ==0)give_item ; else give_PKM_type ;
			Deposit : give_money ; 
			Use_item : give_item ;
			Attack   : give_Def_ID ; 
		endcase
	
	end
	
end endtask

task give_new_player  ; begin
	inf.id_valid = 'd1;
	
	inf.D.d_id[1] = 'd0 ; 
	inf.D.d_id[0] = player_id_data ; 
	
	player_addr = player_id_data*8 + 65536 ;
		
	@(negedge clk) ; 
	inf.id_valid = 'd0;
	inf.D = 'dx ;
end endtask

task give_action ; begin
	inf.act_valid  = 'd1 ;
	
	inf.D.d_act[3:1] = 'd0 ;
	inf.D.d_act[0] = now_action ; 
	@(negedge clk) ; 
	inf.act_valid = 'd0;
	inf.D = 'dx ; 
end endtask

task give_item ; begin
	inf.item_valid = 'd1 ;
	inf.D.d_item[3:1] = 0 ;
	if (patcount >=500 && patcount<805  ) begin
		inf.D.d_item[0] = Bracer ; 
		ITEM.Item_data = Bracer ;  // here
	end else if (patcount >= 805)begin
		inf.D.d_item[0] = Candy ; 
		ITEM.Item_data = Candy ;  // here
	end else begin
		inf.D.d_item[0] = ITEM.Item_data ; 
	end 
	
	@(negedge clk) ; 
	inf.item_valid = 'd0;
	inf.D = 'dx ; 
end endtask

task give_money ; begin
	inf.amnt_valid = 'd1 ;
	
	inf.D.d_money = MONEY.Money_data ; 
	@(negedge clk) ; 
	inf.amnt_valid = 'd0;
	inf.D = 'dx ; 
end endtask

task give_PKM_type ;  begin
	inf.type_valid = 'd1 ;
	inf.D.d_type[3:1] = 0 ;
	
	if (now_action == Buy)
		inf.D.d_type[0] = TYPE.Type_data ; 
	else 
		inf.D.d_type[0] = No_type ; 
		
	@(negedge clk) ; 
	inf.type_valid = 'd0;
	inf.D = 'dx ; 
end endtask

task give_Def_ID ;  begin
	Def = $urandom_range (0,255) ; 
	while (Def == player_id_data ) begin
		Def = $urandom_range (0,255) ; 
	end
	defender_addr = Def * 8 + 65536 ;
	inf.id_valid = 'd1 ;
	inf.D.d_id[1] = 'd0 ; 
	inf.D.d_id[0] = Def ; 
	@(negedge clk) ; 
	inf.id_valid = 'd0;
	inf.D = 'dx ; 
end endtask

task get_my_bag_info ; begin
	My_bag[31:28]    =  golden_DRAM [65536 + player_id_data*8 ] [7:4] ; 
	My_bag[27:24]	 =  golden_DRAM [65536 + player_id_data*8 ] [3:0] ;
	My_bag[23:20]    =  golden_DRAM [65536 + player_id_data*8 + 1 ] [7:4] ;
	My_bag[19:16]    =  golden_DRAM [65536 + player_id_data*8 + 1 ] [3:0] ;
	My_bag[15:14]    =  golden_DRAM [65536 + player_id_data*8 + 2 ] [7:6] ;
	My_bag[13:0 ]    = { golden_DRAM [65536 + player_id_data*8 + 2 ] [5:0], golden_DRAM [65536 + player_id_data*8 + 3 ] } ;  
end endtask

task get_my_POK_info ; begin
	My_POK[31:28]    =  golden_DRAM [65536 + player_id_data*8 + 4 ] [7:4] ; // not sure is [7:4] or [3:0]
	My_POK[27:24]    =  golden_DRAM [65536 + player_id_data*8 + 4 ] [3:0] ;
	My_POK[23:16]    =  golden_DRAM [65536 + player_id_data*8 + 5 ]  ;
	if (used_bracer)
		My_POK[15:8] =  golden_DRAM [65536 + player_id_data*8 + 6 ] + 'd32 ; 
	else
		My_POK[15:8] =  golden_DRAM [65536 + player_id_data*8 + 6 ]  ;
		
	My_POK[7:0]      =  golden_DRAM [65536 + player_id_data*8 + 7 ]  ;
end endtask

task get_def_POK_info ; begin
	Def_POK[31:28]      =  golden_DRAM [65536 + Def*8 + 4 ] [7:4] ; // not sure is [7:4] or [3:0]
	Def_POK[27:24]      =  golden_DRAM [65536 + Def*8 + 4 ] [3:0] ;
	Def_POK[23:16]      =  golden_DRAM [65536 + Def*8 + 5 ]  ;
	Def_POK[15:8 ]      =  golden_DRAM [65536 + Def*8 + 6 ]  ;
	Def_POK[7 :0 ]      =  golden_DRAM [65536 + Def*8 + 7 ]  ;
end endtask


task compute_answer ;  begin
	get_my_bag_info  ;
	get_my_POK_info  ;
	get_def_POK_info ; 
	
	
	
	Monery_overflow = 0 ;
	exp_not_zero    = 0 ;
	if (now_action == Buy ) begin
		if (temp_value==0) begin  //   Buy item ; 
			if (ITEM.Item_data == Berry) begin
				if (My_bag.money < price_buy_item(Berry) )
					err_msg = Out_of_money ;
				else if (My_bag.berry_num == 'd15)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.berry_num = My_bag.berry_num + 'd1 ;
					My_bag.money     = My_bag.money     - price_buy_item(Berry) ;
				end
			end else if (ITEM.Item_data == Medicine) begin
				if (My_bag.money < price_buy_item(Medicine) )
					err_msg = Out_of_money ;
				else if (My_bag.medicine_num == 'd15)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.medicine_num = My_bag.medicine_num + 'd1 ;
					My_bag.money     = My_bag.money     - price_buy_item(Medicine) ;
				end
			end else if (ITEM.Item_data == Candy) begin
				if (My_bag.money < price_buy_item(Candy) )
					err_msg = Out_of_money ;
				else if (My_bag.candy_num == 'd15)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.candy_num = My_bag.candy_num + 'd1 ;
					My_bag.money     = My_bag.money     - price_buy_item(Candy) ;
				end
			end else if (ITEM.Item_data == Bracer) begin
				if (My_bag.money < price_buy_item(Bracer) )
					err_msg = Out_of_money ;
				else if (My_bag.bracer_num == 'd15)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.bracer_num = My_bag.bracer_num + 'd1 ;
					My_bag.money     = My_bag.money     - price_buy_item(Bracer) ;
				end
			end else if (ITEM.Item_data == Water_stone) begin
				if (My_bag.money < price_buy_item(Water_stone) )
					err_msg = Out_of_money ;
				else if (My_bag.stone != 'd0)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone     = W_stone ;
					My_bag.money     = My_bag.money     - price_buy_item(Water_stone) ;
				end
			end else if (ITEM.Item_data == Fire_stone) begin
				if (My_bag.money < price_buy_item(Fire_stone) )
					err_msg = Out_of_money ;
				else if (My_bag.stone != 'd0)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone     = F_stone ;
					My_bag.money     = My_bag.money     - price_buy_item(Fire_stone) ;
				end
			end else if (ITEM.Item_data == Thunder_stone) begin
				if (My_bag.money < price_buy_item(Thunder_stone) )
					err_msg = Out_of_money ;
				else if (My_bag.stone != No_stone)
					err_msg = Bag_is_full ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone     = T_stone ;
					My_bag.money     = My_bag.money     - price_buy_item(Thunder_stone) ;
				end
			end 
		end else begin	  // Buy Pokemon
			if (TYPE.Type_data == Grass) begin
				if (My_bag.money < price_buy_POK(Grass) )
					err_msg = Out_of_money ;
				else if  (My_POK != 'd0 )
					err_msg = Already_Have_PKM ;
				else begin
					err_msg = No_Err ; 
					
					My_POK.stage     = Lowest ; 
					My_POK.pkm_type  = Grass  ;
					My_POK.hp        = 'd128  ;
					My_POK.atk       = 'd63   ;
					My_POK.exp       = 'd0    ;
					
					My_bag.money     = My_bag.money     - price_buy_POK(Grass) ;
				end
			end else if (TYPE.Type_data == Fire) begin
				if (My_bag.money < price_buy_POK(Fire) )
					err_msg = Out_of_money ;
				else if  (My_POK != 'd0 )
					err_msg = Already_Have_PKM ;
				else begin
					err_msg = No_Err ; 
					
					My_POK.stage     = Lowest ; 
					My_POK.pkm_type  = Fire   ;
					My_POK.hp        = 'd119  ;
					My_POK.atk       = 'd64   ;
					My_POK.exp       = 'd0    ;
					
					My_bag.money     = My_bag.money     - price_buy_POK(Fire) ;
				end
			end else if (TYPE.Type_data == Water) begin
				if (My_bag.money < price_buy_POK(Water) )
					err_msg = Out_of_money ;
				else if  (My_POK != 'd0 )
					err_msg = Already_Have_PKM ;
				else begin
					err_msg = No_Err ; 
					
					My_POK.stage     = Lowest ; 
					My_POK.pkm_type  = Water   ;
					My_POK.hp        = 'd125  ;
					My_POK.atk       = 'd60   ;
					My_POK.exp       = 'd0    ;
					
					My_bag.money     = My_bag.money     - price_buy_POK(Water) ;
				end
			end else if (TYPE.Type_data == Electric) begin
				if (My_bag.money < price_buy_POK(Electric) )
					err_msg = Out_of_money ;
				else if  (My_POK != 'd0 )
					err_msg = Already_Have_PKM ;
				else begin
					err_msg = No_Err ; 
					
					My_POK.stage     = Lowest ; 
					My_POK.pkm_type  = Electric   ;
					My_POK.hp        = 'd122  ;
					My_POK.atk       = 'd65   ;
					My_POK.exp       = 'd0    ;
					
					My_bag.money     = My_bag.money     - price_buy_POK(Electric) ;
				end
			end else if (TYPE.Type_data == Normal) begin
				if (My_bag.money < price_buy_POK(Normal) )
					err_msg = Out_of_money ;
				else if  (My_POK != 'd0 )
					err_msg = Already_Have_PKM ;
				else begin
					err_msg = No_Err ; 
					
					My_POK.stage     = Lowest ; 
					My_POK.pkm_type  = Normal   ;
					My_POK.hp        = 'd124  ;
					My_POK.atk       = 'd62   ;
					My_POK.exp       = 'd0    ;
					
					My_bag.money     = My_bag.money     - price_buy_POK(Normal) ;
				end
			end 
		end
	end else if (now_action == Sell)begin
		if (temp_value==0) begin  //   Sell item ; 
			if (ITEM.Item_data == Berry) begin
				if (My_bag.berry_num == 'd0)
					err_msg = Not_Having_Item ; 
				else begin
					err_msg = No_Err ; 
					
					My_bag.berry_num = My_bag.berry_num - 'd1 ;
					My_bag.money     = My_bag.money     + price_sell_item (Berry) ; 
					if (My_bag.money < price_sell_item(Berry) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Medicine) begin
				if (My_bag.medicine_num == 'd0)
					err_msg = Not_Having_Item ; 
				else begin
					err_msg = No_Err ; 
					
					My_bag.medicine_num = My_bag.medicine_num - 'd1 ;
					My_bag.money     = My_bag.money     + price_sell_item (Medicine) ; 
					if (My_bag.money < price_sell_item(Medicine) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Candy) begin
				if (My_bag.candy_num == 'd0)
					err_msg = Not_Having_Item ; 
				else begin
					err_msg = No_Err ; 
					
					My_bag.candy_num = My_bag.candy_num - 'd1 ;
					My_bag.money     = My_bag.money     + price_sell_item (Candy) ; 
					if (My_bag.money < price_sell_item(Candy) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Bracer) begin
				if (My_bag.bracer_num == 'd0)
					err_msg = Not_Having_Item ; 
				else begin
					err_msg = No_Err ; 
					
					My_bag.bracer_num = My_bag.bracer_num - 'd1 ;
					My_bag.money     = My_bag.money     + price_sell_item (Bracer) ; 
					if (My_bag.money < price_sell_item(Bracer) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Water_stone) begin
				if (My_bag.stone != W_stone  )
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ;
					
					My_bag.stone = No_stone ;
					My_bag.money     = My_bag.money     + price_sell_item (Water_stone) ; 
					if (My_bag.money < price_sell_item(Water_stone) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Fire_stone) begin
				if (My_bag.stone != F_stone  )
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ;
					
					My_bag.stone = No_stone ;
					My_bag.money     = My_bag.money     + price_sell_item (Fire_stone) ; 
					if (My_bag.money < price_sell_item(Fire_stone) )
						Monery_overflow = 'd1 ;
				end
			end else if (ITEM.Item_data == Thunder_stone) begin
				if (My_bag.stone != T_stone  )
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ;
					
					My_bag.stone = No_stone ;
					My_bag.money     = My_bag.money     + price_sell_item (Thunder_stone) ; 
					if (My_bag.money < price_sell_item(Thunder_stone) )
						Monery_overflow = 'd1 ;
				end
			end 
		end else begin	  // Sell Pokemon
			if (My_POK === 'd0)
				err_msg = Not_Having_PKM ;
			else if (My_POK.stage == Lowest)
				err_msg = Has_Not_Grown ; 
			else begin
				err_msg = No_Err ;
				used_bracer = 0 ;
				
				if (My_POK.stage == Middle) begin
					if (My_POK.pkm_type == Grass)begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd510 ; 
						if (My_bag.money < 510)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Fire) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd450 ; 
						if (My_bag.money < 450)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Water) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd500 ; 
						if (My_bag.money < 500)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Electric) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd550 ; 
						if (My_bag.money < 550)
							Monery_overflow = 'd1 ;
					end 
					
				end else if (My_POK.stage == Highest) begin
					if (My_POK.pkm_type == Grass)begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd1100 ; 
						if (My_bag.money < 1100)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Fire) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd1000 ; 
						if (My_bag.money < 1000)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Water) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd1200 ; 
						if (My_bag.money < 1200)
							Monery_overflow = 'd1 ;
					end else if (My_POK.pkm_type == Electric) begin
						My_POK = 'd0 ;
						My_bag.money = My_bag.money + 'd1300 ; 
						if (My_bag.money < 1300)
							Monery_overflow = 'd1 ;
					end 
				end
			end
		end
	end else if (now_action == Deposit)begin
			err_msg = No_Err ; 
			
			My_bag.money = My_bag.money +  MONEY.Money_data  ; 
			if (My_bag.money < MONEY.Money_data)
				Monery_overflow = 'd1 ;
	end else if (now_action == Use_item)begin
			if (ITEM.Item_data == Berry) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.berry_num == 'd0) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ;
					My_bag.berry_num = My_bag.berry_num -'d1 ;
					
					if (My_POK.stage == Lowest)begin
						if (My_POK.pkm_type == Grass) begin
							if (My_POK.hp > (128-32))
								My_POK.hp = 'd128 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Fire) begin
							if (My_POK.hp > (119-32))
								My_POK.hp = 'd119 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Water) begin
							if (My_POK.hp > (125-32))
								My_POK.hp = 'd125 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Electric) begin
							if (My_POK.hp > (122-32))
								My_POK.hp = 'd122 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Normal) begin
							if (My_POK.hp > (124-32))
								My_POK.hp = 'd124 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end 
					end else if (My_POK.stage == Middle) begin
						if (My_POK.pkm_type == Grass) begin
							if (My_POK.hp > (192-32))
								My_POK.hp = 'd192 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Fire) begin
							if (My_POK.hp > (177-32))
								My_POK.hp = 'd177 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Water) begin
							if (My_POK.hp > (187-32))
								My_POK.hp = 'd187 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Electric) begin
							if (My_POK.hp > (182-32))
								My_POK.hp = 'd182 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end 
					end else begin
						if (My_POK.pkm_type == Grass) begin
							if (My_POK.hp > (254-32))
								My_POK.hp = 'd254 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Fire) begin
							if (My_POK.hp > (225-32))
								My_POK.hp = 'd225 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Water) begin
							if (My_POK.hp > (245-32))
								My_POK.hp = 'd245 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end else if  (My_POK.pkm_type == Electric) begin
							if (My_POK.hp > (235-32))
								My_POK.hp = 'd235 ;
							else 
								My_POK.hp = My_POK.hp + 'd32 ;
						end 
					end
				end
			end else if (ITEM.Item_data == Medicine) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.medicine_num == 'd0) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.medicine_num = My_bag.medicine_num -'d1 ;
					
					if (My_POK.stage == Lowest)begin
						if (My_POK.pkm_type == Grass) begin
								My_POK.hp = 'd128 ;
						end else if  (My_POK.pkm_type == Fire) begin
								My_POK.hp = 'd119 ;
						end else if  (My_POK.pkm_type == Water) begin
								My_POK.hp = 'd125 ;
						end else if  (My_POK.pkm_type == Electric) begin
								My_POK.hp = 'd122 ;
						end else if  (My_POK.pkm_type == Normal) begin
								My_POK.hp = 'd124 ;
						end 
					end else if (My_POK.stage == Middle) begin
						if (My_POK.pkm_type == Grass) begin
								My_POK.hp = 'd192 ;
						end else if  (My_POK.pkm_type == Fire) begin
								My_POK.hp = 'd177 ;
						end else if  (My_POK.pkm_type == Water) begin
								My_POK.hp = 'd187 ;
						end else if  (My_POK.pkm_type == Electric) begin
								My_POK.hp = 'd182 ;
						end 
					end else begin
						if (My_POK.pkm_type == Grass) begin
								My_POK.hp = 'd254 ;
						end else if  (My_POK.pkm_type == Fire) begin
								My_POK.hp = 'd225 ;
						end else if  (My_POK.pkm_type == Water) begin
								My_POK.hp = 'd245 ;
						end else if  (My_POK.pkm_type == Electric) begin
								My_POK.hp = 'd235 ;
						end 
					end
					
				end
			end else if (ITEM.Item_data == Candy) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.candy_num == 'd0) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.candy_num = My_bag.candy_num - 'd1 ; 
					
					
					if (My_POK.stage == Lowest) begin
						if (My_POK.pkm_type == Grass) begin
							if ( (32 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Middle ; 
								My_POK.hp    = 'd192 ; 
								My_POK.atk   = 'd94 ; 
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Fire) begin
							if ( (30 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Middle ; 
								My_POK.hp    = 'd177 ; 
								My_POK.atk   = 'd96 ; 
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Water) begin
							if ( (28 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Middle ; 
								My_POK.hp    = 'd187 ; 
								My_POK.atk   = 'd89 ; 
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Electric) begin
							if ( (26 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Middle ; 
								My_POK.hp    = 'd182 ; 
								My_POK.atk   = 'd97 ; 
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Normal) begin
							if ( (29 - My_POK.exp) <= 15 )
								My_POK.exp = 'd29 ;
							else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end 
					end else if (My_POK.stage == Middle) begin
						if (My_POK.pkm_type == Grass) begin
							if ( (63 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Highest ; 
								My_POK.hp    = 'd254 ; 
								My_POK.atk   = 'd123 ;
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Fire) begin
							if ( (59 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Highest ; 
								My_POK.hp    = 'd225 ; 
								My_POK.atk   = 'd127 ;
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Water) begin
							if ( (55 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Highest ; 
								My_POK.hp    = 'd245 ; 
								My_POK.atk   = 'd113 ;
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end else if  (My_POK.pkm_type == Electric) begin
							if ( (51 - My_POK.exp) <= 15 )begin
								My_POK.exp = 'd0 ;
								My_POK.stage = Highest ; 
								My_POK.hp    = 'd235 ; 
								My_POK.atk   = 'd124 ;
								used_bracer = 'd0 ;
							end else 
								My_POK.exp = My_POK.exp + 'd15 ;
						end
						
					end else if (My_POK.stage == Highest) begin
						if (My_POK.exp !=0 )
							exp_not_zero = 1 ;
						else
							My_POK.exp ='d0 ;
						
					end
				end
			end else if (ITEM.Item_data == Bracer) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.bracer_num == 'd0) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.bracer_num = My_bag.bracer_num - 'd1 ; 
					used_bracer = 1 ;
					if (My_POK.stage == Lowest)begin
						if (My_POK.atk > 70 ) // using bracer
							My_POK.atk = My_POK.atk ;
						else 
							My_POK.atk = My_POK.atk + 'd32 ;
					end else if (My_POK.stage == Middle)begin
						if (My_POK.atk > 100 ) // using bracer
							My_POK.atk = My_POK.atk ;
						else 
							My_POK.atk = My_POK.atk + 'd32 ;
					end else if (My_POK.stage == Highest)begin
						if (My_POK.atk > 130 ) // using bracer
							My_POK.atk = My_POK.atk ;
						else 
							My_POK.atk = My_POK.atk + 'd32 ;
					end
				end
			end else if (ITEM.Item_data == Water_stone) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.stone != 'd1) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone = No_stone ; 
					if (My_POK.pkm_type == Normal && My_POK.exp == 'd29)begin
						My_POK.pkm_type = Water  ; 
						My_POK.stage    = Highest  ;
						My_POK.hp 		= 'd245 ;
						My_POK.atk		= 'd113 ;
						My_POK.exp		= 'd0   ;
						used_bracer = 0 ;
					end
				end
			end else if (ITEM.Item_data == Fire_stone) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.stone != 'd2) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone = No_stone ; 
					
					if (My_POK.pkm_type == Normal && My_POK.exp == 'd29)begin
						My_POK.pkm_type = Fire  ; 
						My_POK.stage = Highest  ;
						My_POK.hp 		= 'd225 ;
						My_POK.atk		= 'd127 ;
						My_POK.exp		= 'd0   ;
						used_bracer = 0 ;
					end
				end
			end else if (ITEM.Item_data == Thunder_stone) begin
				if (My_POK == 'd0 )
					err_msg = Not_Having_PKM ;
				else if (My_bag.stone != T_stone ) 
					err_msg = Not_Having_Item ;
				else begin
					err_msg = No_Err ; 
					My_bag.stone = No_stone ; 
					
					if (My_POK.pkm_type == Normal && My_POK.exp == 'd29)begin
						My_POK.pkm_type = Electric  ; 
						My_POK.stage = Highest  ;
						My_POK.hp 		= 'd235 ;
						My_POK.atk		= 'd124 ;
						My_POK.exp		= 'd0   ;
						used_bracer = 0 ;
					end
				end
			end 
	end else if (now_action == Check)begin
		err_msg = No_Err ; 
		My_POK = My_POK ; 
		My_bag = My_bag ;
	end else if (now_action == Attack)begin
		if (My_POK == 'd0 || Def_POK == 'd0)begin
			err_msg = Not_Having_PKM ;
		end else if (My_POK.hp == 'd0 || Def_POK.hp == 'd0) begin
			err_msg = HP_is_Zero ;
		end else begin
			err_msg = No_Err ;
			used_bracer = 'd0 ;
			if (My_POK.stage == Lowest) begin
				if (My_POK.pkm_type == Grass) begin
				
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (32-16) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (32-8) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (32-16) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (30-8) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (32-16) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (28-8) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (32-16) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (26-8) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (32-16) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (29-8) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (32-24) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (63-8) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (32-24) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (59-8) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (32-24) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (55-8) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (32-24) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd63 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (51-8) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							
							end 
					
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								// if (My_POK.exp >= (32-32) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd63 ;
									// My_POK.stage = Lowest ; 
								// end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								// if (My_POK.exp >= (32-32) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd63 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								// if (My_POK.exp >= (32-32) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd63 ;
									// My_POK.stage = Lowest ; 
								// end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
									
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								// if (My_POK.exp >= (32-32) )begin   // evolution
									My_POK.hp    = 'd192    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd94     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd63 ;
									// My_POK.stage = Lowest ; 
								// end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Fire) begin
					
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (30-16) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (32-8) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (30-16) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (30-8) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (30-16) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (28-8) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (30-16) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (26-8) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (30-16) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (29-8) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (30-24) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (63-8) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (30-24) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (59-8) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (30-24) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (55-8) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (30-24) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd64 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (51-8) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								// if (My_POK.exp >= (30-32) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd64 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								// if (My_POK.exp >= (30-32) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd64 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								// if (My_POK.exp >= (30-32) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd64 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								// if (My_POK.exp >= (30-32) )begin   // evolution
									My_POK.hp    = 'd177    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd96     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd64 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
							
							end 
					
					
					end
					
					
				end else if  (My_POK.pkm_type == Water) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (28-16) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (32-8) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (28-16) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (30-8) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (28-16) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (28-8) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (28-16) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (26-8) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (28-16) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (29-8) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (28-24) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (63-8) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (28-24) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (59-8) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (28-24) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (55-8) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (28-24) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd60 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (51-8) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end 

					end else if (Def_POK.stage == Highest) begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								// if (My_POK.exp >= (28-32) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd60 ;
									// My_POK.stage = Lowest ; 
								// end
								
					
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								// if (My_POK.exp >= (28-32) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd60 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								// if (My_POK.exp >= (28-32) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd60 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								// if (My_POK.exp >= (28-32) )begin   // evolution
									My_POK.hp    = 'd187    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd89     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd60 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Electric) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (26-16) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (32-8) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (26-16) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (30-8) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (26-16) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (28-8) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								if (My_POK.exp >= (26-16) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (26-8) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (26-16) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (29-8) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (26-24) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (63-8) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (26-24) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (59-8) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (26-24) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (55-8) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								if (My_POK.exp >= (26-24) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd65 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (51-8) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else if (Def_POK.stage == Highest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								// if (My_POK.exp >= (26-32) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd65 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
									
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								// if (My_POK.exp >= (26-32) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd65 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								// if (My_POK.exp >= (26-32) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd65 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								// if (My_POK.exp >= (26-32) )begin   // evolution
									My_POK.hp    = 'd182    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd97     ;
									My_POK.stage = Middle   ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd65 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
									
								
							end 
					
					
					end
				end else if  (My_POK.pkm_type == Normal) begin
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (29-16) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (32-8) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (29-16) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (30-8) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (29-16) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (28-8) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (29-16) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (26-8) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (29-16) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (29-8) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (29-24) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (63-8) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (29-24) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								
								if (Def_POK.exp >= (59-8) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (29-24) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (55-8) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (29-24) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd62 ;
									My_POK.stage = Lowest ; 
								end
								
								if (Def_POK.exp >= (51-8) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd8;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							
							end 
					
					
					end else if (Def_POK.stage == Highest) begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								// if (My_POK.exp >= (29-32) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd62 ;
									// My_POK.stage = Lowest ; 
								// end
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								// if (My_POK.exp >= (29-32) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd62 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								// if (My_POK.exp >= (29-32) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd62 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								// if (My_POK.exp >= (29-32) )begin   // evolution
									My_POK.hp    = My_POK.hp   ;
									My_POK.exp   = 'd29        ;
									My_POK.atk   = 'd62        ;
									My_POK.stage = Lowest      ; 
								// end else begin
									// My_POK.hp    = My_POK.hp ;
									// My_POK.exp   = My_POK.exp + 'd32;
									// My_POK.atk   = 'd62 ;
									// My_POK.stage = Lowest ; 
								// end
								
								
									Def_POK.exp   = 'd0      ;
							
							end 
					
					
					end
				end 
				
			end else if (My_POK.stage == Middle) begin
				
				if (My_POK.pkm_type == Grass) begin
				
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-16) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (32-12) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-16) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (30-12) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (63-16) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (28-12) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (63-16) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (26-12) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (63-16) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (29-12) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-24) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (63-12) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-24) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (59-12) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (63-24) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (55-12) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (63-24) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (51-12) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							
							end 
					
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-32) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (63-32) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (63-32) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
									
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (63-32) )begin   // evolution
									My_POK.hp    = 'd254    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd94 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Fire) begin
					
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (59-16) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (32-12) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (59-16) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (30-12) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (59-16) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (28-12) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (59-16) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (26-12) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (59-16) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (29-12) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (59-24) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (63-12) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (59-24) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (59-12) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (59-24) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (55-12) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (59-24) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (51-12) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (59-32) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (59-32) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (59-32) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (59-32) )begin   // evolution
									My_POK.hp    = 'd225    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd96 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
							
							end 
					
					
					end
					
					
				end else if  (My_POK.pkm_type == Water) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (55-16) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (32-12) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (55-16) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (30-12) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (55-16) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (28-12) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (55-16) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (26-12) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (55-16) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (29-12) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (55-24) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (63-12) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (55-24) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (59-12) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (55-24) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (55-12) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (55-24) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (51-12) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end 

					end else if (Def_POK.stage == Highest) begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (55-32) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
					
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								if (My_POK.exp >= (55-32) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								if (My_POK.exp >= (55-32) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								if (My_POK.exp >= (55-32) )begin   // evolution
									My_POK.hp    = 'd245    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd89 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
								
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Electric) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (51-16) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (32-12) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (51-16) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (30-12) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (51-16) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (28-12) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								if (My_POK.exp >= (51-16) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (26-12) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								if (My_POK.exp >= (51-16) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd16;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (29-12) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (51-24) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (63-12) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (51-24) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								
								if (Def_POK.exp >= (59-12) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (51-24) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (55-12) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								if (My_POK.exp >= (51-24) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd24;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								if (Def_POK.exp >= (51-12) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd12;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else if (Def_POK.stage == Highest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								if (My_POK.exp >= (51-32) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
									
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								if (My_POK.exp >= (51-32) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								if (My_POK.exp >= (51-32) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								if (My_POK.exp >= (51-32) )begin   // evolution
									My_POK.hp    = 'd235    ;
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									My_POK.stage = Highest   ; 
								end else begin
									My_POK.hp    = My_POK.hp ;
									My_POK.exp   = My_POK.exp + 'd32;
									My_POK.atk   = 'd97 ;
									My_POK.stage = Middle ; 
								end
								
								
									Def_POK.exp   = 'd0      ;
									
								
							end 
					
					
					end
				end
				
				
			end else if (My_POK.stage == Highest) begin
				
				if (My_POK.pkm_type == Grass) begin
				
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
									
									
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (32-16) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (30-16) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
									
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									
									
								if (Def_POK.exp >= (28-16) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
									
									
								if (Def_POK.exp >= (26-16) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (29-16) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (63-16) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								
								if (Def_POK.exp >= (59-16) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
							
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (55-16) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp >= (51-16) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
									
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd123     ;
								
								if (Def_POK.exp != 'd0 )
									exp_not_zero = 'd1 ;
								else
									Def_POK.exp   = 'd0 ;
								
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Fire) begin
					
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									
								if (Def_POK.exp >= (32-16) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								
								if (Def_POK.exp >= (30-16) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								if (Def_POK.exp >= (28-16) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								if (Def_POK.exp >= (26-16) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								if (Def_POK.exp >= (29-16) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
									
								if (Def_POK.exp >= (63-16) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								
								if (Def_POK.exp >= (59-16) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								if (Def_POK.exp >= (55-16) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								if (Def_POK.exp >= (51-16) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else begin
					
							if (Def_POK.pkm_type == Grass)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd127     ;
								
									Def_POK.exp   = 'd0      ;
							
							end 
					
					
					end
					
					
				end else if  (My_POK.pkm_type == Water) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								if (Def_POK.exp >= (32-16) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								
								if (Def_POK.exp >= (30-16) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									
								if (Def_POK.exp >= (28-16) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								if (Def_POK.exp >= (26-16) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								if (Def_POK.exp >= (29-16) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								if (Def_POK.exp >= (63-16) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								
								if (Def_POK.exp >= (59-16) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
								if (Def_POK.exp >= (55-16) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									
								if (Def_POK.exp >= (51-16) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end 

					end else if (Def_POK.stage == Highest) begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
					
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Fire)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
								
									Def_POK.exp   = 'd0      ;
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd113     ;
									
									
									Def_POK.exp   = 'd0      ;
							end 
					
					
					end
					
				end else if  (My_POK.pkm_type == Electric) begin
					
					if (Def_POK.stage == Lowest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (32-16) )begin   // evolution
									Def_POK.hp    = 'd192    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd94     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (30-16) )begin   // evolution
									Def_POK.hp    = 'd177    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd96     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (28-16) )begin   // evolution
									Def_POK.hp    = 'd187    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd89     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (26-16) )begin   // evolution
									Def_POK.hp    = 'd182    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd97     ;
									Def_POK.stage = Middle   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
								
								
							end else if (Def_POK.pkm_type == Normal)begin
							
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									
								if (Def_POK.exp >= (29-16) )begin   // evolution
									Def_POK.hp    = Def_POK.hp    ;
									Def_POK.exp   = 'd29      ;
									Def_POK.atk   = Def_POK.atk     ;
									Def_POK.stage = Lowest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Lowest ; 
								end
							end 
							
					end else if (Def_POK.stage == Middle)begin
					
						if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									
								if (Def_POK.exp >= (63-16) )begin   // evolution
									Def_POK.hp    = 'd254    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd123     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								
								if (Def_POK.exp >= (59-16) )begin   // evolution
									Def_POK.hp    = 'd225    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd127     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (55-16) )begin   // evolution
									Def_POK.hp    = 'd245    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd113     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								if (Def_POK.exp >= (51-16) )begin   // evolution
									Def_POK.hp    = 'd235    ;
									Def_POK.exp   = 'd0      ;
									Def_POK.atk   = 'd124     ;
									Def_POK.stage = Highest   ; 
								end else begin
									Def_POK.exp   = Def_POK.exp + 'd16;
									Def_POK.atk   = Def_POK.atk ;
									Def_POK.stage = Middle ; 
								end
								
							end 
					
					
					end else if (Def_POK.stage == Highest)begin
					
							if (Def_POK.pkm_type == Grass)begin
								
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ;  // round down
								
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								
									Def_POK.exp   = 'd0      ;
									
								
							end else if (Def_POK.pkm_type == Fire)begin
								
								if (Def_POK.hp < ( My_POK.atk ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk     ;  // round down
								
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
								
									Def_POK.exp   = 'd0      ;
									
								
								
							end else if (Def_POK.pkm_type == Water)begin
								if (My_POK.atk > 130)
									Def_POK.hp = 'd0 ;
								else if (Def_POK.hp < ( My_POK.atk*2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk*2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
									
									Def_POK.exp   = 'd0      ;
								
								
							end else if (Def_POK.pkm_type == Electric)begin
							
								if (Def_POK.hp < ( My_POK.atk/2 ) )
									Def_POK.hp = 'd0 ;
								else 
									Def_POK.hp = Def_POK.hp - My_POK.atk/2     ; 
									
								
									My_POK.exp   = 'd0      ;
									My_POK.atk   = 'd124     ;
								
									Def_POK.exp   = 'd0      ;
									
							end 
					
					
					end
				end
				
			end
		end
	end
end endtask


task write_to_DRAM ;  begin
	golden_DRAM [65536 + player_id_data*8 ] [7:4]  = My_bag.berry_num ;
	golden_DRAM [65536 + player_id_data*8 ] [3:0]  = My_bag.medicine_num ;
	golden_DRAM [65536 + player_id_data*8 + 1 ] [7:4] = My_bag.candy_num ; 
	golden_DRAM [65536 + player_id_data*8 + 1 ] [3:0] = My_bag.bracer_num ;
	golden_DRAM [65536 + player_id_data*8 + 2 ] [7:6] = My_bag.stone ; 
	{ golden_DRAM [65536 + player_id_data*8 + 2 ] [5:0], golden_DRAM [65536 + player_id_data*8 + 3 ] }  = My_bag.money ; 


	golden_DRAM [65536 + player_id_data*8 + 4 ] [7:4] = My_POK.stage ; 
	golden_DRAM [65536 + player_id_data*8 + 4 ] [3:0] = My_POK.pkm_type ; 
	golden_DRAM [65536 + player_id_data*8 + 5 ]       = My_POK.hp ; 
	if (used_bracer)
		golden_DRAM [65536 + player_id_data*8 + 6 ]       = My_POK.atk - 'd32 ; 
	else
		golden_DRAM [65536 + player_id_data*8 + 6 ]       = My_POK.atk ; 
	golden_DRAM [65536 + player_id_data*8 + 7 ]		  = My_POK.exp ; 
	
	if (now_action == Attack) begin
		golden_DRAM [65536 + Def*8 + 4 ] [7:4] = Def_POK.stage ; 
		golden_DRAM [65536 + Def*8 + 4 ] [3:0] = Def_POK.pkm_type ; 
		golden_DRAM [65536 + Def*8 + 5 ]       = Def_POK.hp ; 
		golden_DRAM [65536 + Def*8 + 6 ]       = Def_POK.atk ; 
		golden_DRAM [65536 + Def*8 + 7 ]	   = Def_POK.exp ; 
	end
	
end endtask



task wait_out_valid_task ; begin
	cycles = 0 ; 
	while (inf.out_valid == 'd0)begin
		
		// if(cycles == 1200) begin
			// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			// $display ("                                                                        FAIL!                                                               ");
			// $display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			// $display ("                                                     The execution latency are over 1,200 cycles                                            ");
			// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			// @(negedge clk);
			// $finish;
		// end
		cycles = cycles + 'd1 ;
		@(negedge clk) ; 
	end
	total_cycles = total_cycles + cycles ; 
end endtask


PKM_Info your_player ;
PKM_Info your_def ;


task check_answer ; begin
		// if (Monery_overflow)begin
			// $display ("    Monery_overflow  ");
			// #(100);
			// $finish ;
		// end
		

		//  we need to check inf.complete , inf.err_msg , inf.out_info
		
		if (inf.out_valid)begin
			if (inf.complete === 'd1  )begin
				if (now_action === Attack ) begin
				
					if (inf.out_info !== {My_POK,Def_POK}) begin
						$display ("   Wrong Answer  " ) ;
						$finish;
					end
					
				end else begin
					if (inf.out_info !== {My_bag,My_POK}) begin
						$display ("   Wrong Answer  " ) ;
						$finish;
					end
				end
				
			end  else if (inf.complete === 'd0 ) begin
				if (err_msg !== inf.err_msg )begin
					$display ("   Wrong Answer  " ) ;
					$finish;
				end 
			end 	
		end 
		
			
		
	
end endtask

task reset_task ; begin
	#(10); inf.rst_n = 0;
	#(10);
	// if(  (inf.out_valid !== 0) ||  (inf.err_msg !== 0) ||  (inf.complete !== 0)  ||  (inf.out_info !== 0)  ) begin
		// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		// $display ("                                                                        FAIL!                                                               ");
		// $display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		// #(100);
	    // $finish ;
	// end
	#(20); inf.rst_n = 1 ;
end endtask




endprogram

