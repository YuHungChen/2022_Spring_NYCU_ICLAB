//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//covergroup Spec1 @();
	
       //finish your covergroup here
	
	
//endgroup

//declare other cover group
covergroup Spec1 @(negedge clk iff inf.out_valid  );
	coverpoint inf.out_info[31:28] {
		option.at_least = 20 ;
		bins b1 = {No_stage} ;
		bins b2 = {Lowest}   ;
		bins b3 = {Middle}   ;
		bins b4 = {Highest}  ;
	}
	
	coverpoint inf.out_info[27:24] {
		option.at_least = 20 ;
		bins b1 = {No_type}  ;
		bins b2 = {Grass}    ;
		bins b3 = {Fire}     ;
		bins b4 = {Water}    ;
		bins b5 = {Electric} ;
		bins b6 = {Normal}   ;
	}
	option.per_instance = 1 ;
	option.name = "spec1" ; 
endgroup : Spec1

covergroup Spec2 @(posedge clk iff inf.id_valid  );
	coverpoint inf.D.d_id[0] {
		option.at_least     = 1 ; 
		option.auto_bin_max = 256 ;
	}
	option.per_instance = 1 ;
	option.name = "spec2" ; 
endgroup : Spec2

covergroup Spec3 @(posedge clk iff inf.act_valid  );
	coverpoint inf.D.d_act[0] {
		option.at_least     = 10 ; 
		bins b1[] = ( Buy, Sell, Deposit, Use_item, Check, Attack => Buy, Sell, Deposit, Use_item, Check, Attack ) ;
		
	}
	option.per_instance = 1 ;
	option.name = "spec3" ; 
endgroup : Spec3

covergroup Spec4 @(negedge clk iff inf.out_valid  );
	coverpoint inf.complete {
		bins b1[] = {[0:1]} ;
	}
	option.at_least     = 200 ;   
	option.per_instance = 1 ;
	option.name = "spec4" ; 
endgroup : Spec4

covergroup Spec5 @(negedge clk iff inf.out_valid  );
	coverpoint inf.err_msg {
		bins b1 = {Already_Have_PKM}  ;	 // Buy  
		bins b2 = {Out_of_money}      ;  // Buy
		bins b3 = {Bag_is_full}       ;  // Buy
		bins b4 = {Not_Having_PKM}    ;  // Sell, Use_item, Attack
		bins b5 = {Has_Not_Grown}     ;  // Sell
		bins b6 = {Not_Having_Item}   ;  // Use_item, Sell
		bins b7 = {HP_is_Zero}        ;  // Attack
	}
	option.at_least     = 20 ; 
	option.per_instance = 1 ;
	option.name = "spec5" ; 
endgroup : Spec5

//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();


//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write the required assertions below
//  assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0 [*2])
//  else
//  begin
//  	$display("Assertion X is violated");
//  	$fatal; 
//  end

//write other assertions

always @(negedge inf.rst_n)begin
	#1 ; 
		// assert_1 : assert (inf.out_valid === 0 )
	assert_1 : assert( inf.C_out_valid===0 && inf.C_data_r===0 && inf.AR_VALID===0  && inf.AR_ADDR===0  && inf.R_READY===0   && inf.AW_VALID===0   && inf.AW_ADDR===0   && inf.W_VALID===0   && inf.W_DATA===0   && inf.B_READY===0   && inf.out_valid===0   && inf.err_msg===0   && inf.complete===0   && inf.out_info===0   && inf.C_addr===0   && inf.C_data_w===0   && inf.C_in_valid===0   && inf.C_r_wb===0   )
	 else
	 begin
		$display("Assertion 1 is violated");
		$fatal; 
	 end
end

assert_2 : assert property ( @(posedge clk)  (inf.complete===1 && inf.out_valid===1)  |-> inf.err_msg === No_Err )
 else
 begin
 	$display("Assertion 2 is violated");
 	$fatal; 
 end
 
 assert_3 : assert property ( @(posedge clk)  (inf.complete===0 && inf.out_valid===1)  |-> inf.out_info === 64'b0 )
 else
 begin
 	$display("Assertion 3 is violated");
 	$fatal; 
 end

// assert_4 : assert property ( @(posedge clk)  (inf.complete===1 && inf.out_valid===1)  |-> inf.err_msg === No_Err )
 // else
 // begin
 	// $display("Assertion 4 is violated");
 	// $fatal; 
 // end
	Action now_act ;
	always_ff@(posedge clk , negedge inf.rst_n)begin
		if (!inf.rst_n)
			now_act <= No_action;
		else if (inf.id_valid)
			now_act <= No_action ;
		else if (inf.act_valid && inf.D.d_act[0] == Attack)
			now_act <= Attack ; 
	end
	
	
	property act_attack ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Attack  ) |=> (##[1:5] (inf.id_valid)  )  ;   
	endproperty 
	
	property act_buy ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Buy     ) |=> (##[1:5] (inf.item_valid || inf.type_valid)  )  ;   
	endproperty 
	
	property act_sell ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Sell    ) |=> (##[1:5] (inf.item_valid || inf.type_valid)  )  ;    
	endproperty 
	
	property act_deposit ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Deposit ) |=> (##[1:5] (inf.amnt_valid)  )  ;    
	endproperty 
	
	property act_use_item ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Use_item) |=> (##[1:5] (inf.item_valid)  )  ;    
	endproperty 
	
	property in_act ;
		 @(posedge clk ) (inf.id_valid  && now_act === No_action) |=> (##[1:5] (inf.act_valid)  )  ;    
	endproperty 
	
	assert_4_1 : assert property (act_attack)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_2 : assert property (act_buy)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_3 : assert property (act_sell)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_4 : assert property (act_deposit)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_5 : assert property (act_use_item)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_6 : assert property (in_act)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	property act_attack_0 ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Attack  ) |=> (##0 (!inf.id_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	property act_buy_0 ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Buy     ) |=> (##0 !(inf.item_valid || inf.type_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	property act_sell_0 ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Sell    ) |=> (##0 !(inf.item_valid || inf.type_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	property act_deposit_0 ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Deposit ) |=> (##0 !(inf.amnt_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	property act_use_item_0 ;
		 @(posedge clk ) (inf.act_valid && inf.D.d_act[0]=== Use_item) |=> (##0 !(inf.item_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	property in_act_0 ;
		 @(posedge clk ) (inf.id_valid  && now_act === No_action) |=> (##0 !(inf.act_valid)  )  ;    // not sure about |->  , |->
	endproperty 
	
	assert_4_1_0 : assert property (act_attack_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_2_0 : assert property (act_buy_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_3_0 : assert property (act_sell_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_4_0 : assert property (act_deposit_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_5_0 : assert property (act_use_item_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	assert_4_6_0 : assert property (in_act_0)
	else 
	begin
		$display("Assertion 4 is violated");
		$fatal;
	end
	
	
	logic one_of_in_valid_is_1 ; 
	assign no_in_valid_is_one = ( !inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.type_valid && !inf.amnt_valid) ;
	
	assert_5 : assert property (  @(posedge clk ) $onehot( {inf.id_valid , inf.act_valid, inf.item_valid, inf.type_valid, inf.amnt_valid , no_in_valid_is_one}  ) )  //  not sure
	else 
	begin
		$display("Assertion 5 is violated");
		$fatal;
	end
	
	
	property consecutive_out ;
		  @(posedge clk ) (inf.out_valid) |-> (##1 (!inf.out_valid)  )  ;    
	endproperty  
	
	assert_6 : assert property (  consecutive_out  )  //  not sure
	else 
	begin
		$display("Assertion 6 is violated");
		$fatal;
	end

	assert_7 : assert property (  @(posedge clk ) (inf.out_valid) |-> (##[2:10] (inf.id_valid || inf.act_valid)  ) ) 
	else 
	begin
		$display("Assertion 7 is violated");
		$fatal;
	end
	
	assert_7_1 : assert property (  @(posedge clk ) (inf.out_valid) |-> (##1 !(inf.id_valid || inf.act_valid)  ) ) 
	else 
	begin
		$display("Assertion 7 is violated");
		$fatal;
	end

	assert_8 : assert property (  @(posedge clk ) (inf.item_valid || (inf.id_valid && now_act==Attack) || (inf.type_valid) || (inf.amnt_valid) || (inf.act_valid && inf.D.d_act[0]==Check)  ) |-> (##[1:1200] (inf.out_valid)  ) ) 
	else 
	begin
		$display("Assertion 8 is violated");
		$fatal;
	end
	
	
endmodule