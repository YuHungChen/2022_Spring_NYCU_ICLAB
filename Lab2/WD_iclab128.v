//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : WD.v
//   Module Name : WD
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module WD(
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
input clk, rst_n, in_valid;
input [4:0] keyboard, answer;
input [3:0] weight;
input [2:0] match_target;
output reg out_valid;
output reg [4:0]  result;
output reg [10:0] out_value;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
parameter store_value  = 3'd0; 
parameter separate = 3'd1 ; 
parameter get_number   = 3'd2; 
parameter compute   = 3'd3; 
parameter compare  = 3'd4 ;
parameter out    = 3'd5 ;  


// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [4:0]in[0:7] ; 
reg [4:0]sel_in[0:4] ;
reg [3:0]weight_in [0:4] ;
reg [2:0] nA_nB [0:1] ;
integer i ;
reg [2:0] count_8 ;
reg [2:0] count_5 ; 
reg [1:0] count_2 ;  
reg [2:0] next_state ;
reg [2:0] current_state;

wire [2:0] number_ab ;
assign number_ab  = nA_nB[0] + nA_nB[1] ; 

//      separate 
reg [4:0] gray_value [2:0] ;
//reg [4:0] yellow_value[4:0] ;

reg [1:0] count_gray_value ;
reg [2:0] count_yellow_value ;  
reg [3:0] count_number ; 

//   get_number
reg [4:0] number_array [0:4] ;
reg [2:0] count_array ;
reg [2:0] sel_1 , sel_2 , sel_3 , sel_4 ; 
reg [1:0] gray_count ; 
reg [2:0] current_count ; 
reg [2:0] weight_compare [0:2] ;
reg all_done ; 
reg [2:0] ab_position [0:3] ; 
///   sort 
reg final_sort; 
reg [10:0] new_value ; 
reg [5:0] count_sort ; 
reg [4:0] get_array [0:4] ;
//      compare 
reg first_count ; 
reg [10:0] old_value ; 
reg [4:0] max [0:4] ; 
reg [2:0] count_result ; 

///    out
reg [2:0]count_out ;
// ===============================================================
// DESIGN
// ===============================================================

//   ------------------------store   value -----------------
//      ----------------------------------------------------------
//    ------------------separate ------------------
//     -------------get   number -------------------
//      **************  sort    and  compare  ****************  

always@(posedge clk , negedge rst_n)
begin
    if(!rst_n)
        begin
            //  ---------------store  value  parameter---------------
            count_8 <= 0 ;
            count_5  <= 0;
            count_2 <= 0 ;
            for ( i=0 ; i<5 ; i = i +1)
                begin
                    sel_in[i] <= 0 ;
                    weight_in [i] <= 0 ;
                end
            for ( i=0 ; i<8 ; i = i +1)
                    in[i] <= 0 ;
            for ( i=0 ; i<2 ; i = i +1)
                   nA_nB [i]<= 0 ; 
            //  --------------- separate parameter ------------------
            count_gray_value <= 0 ;
            count_yellow_value <= 0 ; 
            for (i=0 ; i<=2 ; i =i+1)
                gray_value [i] <= 0 ;
            count_number <= 0 ;
            // --------------get_number   parameter---------------
            count_array <= 0 ;
            sel_1 <= 0 ;
            sel_2 <= 1 ;
            sel_3 <= 2 ;
            sel_4 <= 3 ;
            gray_count <= 0 ;
            current_count <= 0 ;            
            for (i=0 ; i<=2 ; i=i+1)
                weight_compare[i] <= 0 ; 
        
            for (i = 0 ; i<=4 ; i = i+1)
                begin
                number_array[i] <= 0 ;
                end
			for (i = 0 ; i<=3 ; i = i+1)
                begin
                ab_position [i]<= 0 ; 
                end
            all_done <= 0 ;
            //  -----------------sort parameter --------------------
            new_value <= 0 ;
            final_sort <= 0 ; 
            count_sort <= 0 ;
            for (i = 0 ; i<=4 ; i = i+1)
                get_array[i] <= 0 ;
            // -----------------compare   parameter ------------
            old_value <= 0 ;
            count_result <= 0 ;
			first_count<= 0 ;
            for (i=0 ; i<=4 ; i=i+1)
                max [i] <= 0 ; 
            //  --------------- out  parameter --------------------
            out_valid <= 0 ;
            result <= 5'b0 ;
            out_value <= 11'b0 ;
            count_out <= 0 ;
        end
    else if (current_state == store_value)
        begin
          if(in_valid == 1 )
                begin
                    if (count_8 < 8)
                        begin
                             in  [count_8]  <=  keyboard ; 
                             count_8 <= count_8 +1 ;
                        end
                    if (count_5 < 5)
                        begin
                             sel_in[count_5] <= answer ;
                             weight_in [count_5]  <= weight ;
                             count_5 <= count_5 +1  ;
                        end
                    if (count_2 < 2)
                        begin
                              nA_nB [count_2] <=  match_target ;  
                              count_2 <= count_2 +1 ;
                        end
                end
            else
                begin
                    count_2 <= 0 ;
                    count_5 <= 0 ;
                    count_8 <= 0 ;
                end
        end
    else if(current_state == separate)
            begin
                if (count_gray_value == 3 )
                    begin
                         count_number <= 0 ;
                         count_gray_value <= 0 ;
                         count_yellow_value <= 0 ; 
                    end
                else
                    begin    
                        count_number <= count_number + 1 ;                    
                        for (i=0 ; i <=4 ; i = i +1 )
                            begin
                                if (in[count_number] == sel_in[i])
                                    begin
                                        count_yellow_value <= count_yellow_value + 1 ;
                                    end
                               
                            end
                        if (  (count_yellow_value  + count_gray_value) == (count_number - 1 )    )
                            begin
                                count_gray_value <= count_gray_value +1 ;
                                gray_value [count_gray_value] <= in[count_number-1] ; 
                            end
                   end
             end    
    else if (current_state == get_number)
        begin
            if (all_done)
                all_done <= 0 ;
            else
                begin
                    case (number_ab)
                        3'd2 : begin
                                    number_array [sel_1] <= sel_in [sel_1] ;
                                    number_array [sel_2] <= sel_in [sel_2] ;
                                    ab_position [0] <= sel_1 ;
                                    ab_position [1] <= sel_2 ; 
                                   if (sel_1 == 0 && sel_2 ==1)
                                        begin
                                            number_array [2] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 2 ;
                                            weight_compare [1]  <= 3 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 2 ; 
                                        end
                                    if (sel_1 == 0 && sel_2 ==2)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 3 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 3 ; 
                                        end   
                                    if (sel_1 == 0 && sel_2 ==3)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 2 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 4 ; 
                                        end    
                                    if (sel_1 == 0 && sel_2 ==4)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            number_array [3] <= gray_value [0] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 2 ;
                                            weight_compare [2]  <= 3 ;
                                            sel_2 <= 2 ;
                                            sel_1 <= 1 ; 
                                        end    
                                     if (sel_1 == 1 && sel_2 ==2)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 3 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 3 ; 
                                        end    
                                    if (sel_1 == 1 && sel_2 ==3)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 2 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 4 ; 
                                        end    
                                    if (sel_1 == 1 && sel_2 ==4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            number_array [3] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 2 ;
                                            weight_compare [2]  <= 3 ;
                                            sel_1 <= 2 ;
                                            sel_2 <= 3 ; 
                                        end    
                                    if (sel_1 == 2 && sel_2 ==3)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [1] <= gray_value [1] ;
                                            number_array [4] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 1 ;
                                            weight_compare [2]  <= 4 ;
                                            sel_2 <= 4 ; 
                                        end    
                                    if (sel_1 == 2 && sel_2 ==4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [1] <= gray_value [1] ;
                                            number_array [3] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 1 ;
                                            weight_compare [2]  <= 3 ;
                                            sel_1 <= 3 ;
                                            sel_2 <= 4 ; 
                                        end    
                                    if (sel_1 == 3 && sel_2 ==4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [1] <= gray_value [1] ;
                                            number_array [2] <= gray_value [0] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 1 ;
                                            weight_compare [2]  <= 2 ;
                                            all_done <= 1 ; 
                                            sel_1 <= 0 ;
                                            sel_2 <= 1 ; 
                                        end         
                               end
                      3'd3 : begin
                                    number_array [sel_1] <= sel_in [sel_1] ;
                                    number_array [sel_2] <= sel_in [sel_2] ;
                                    number_array [sel_3] <= sel_in [sel_3] ;
                                    ab_position [0] <= sel_1 ;
                                    ab_position [1] <= sel_2 ; 
                                    ab_position [2] <= sel_3 ;
                                   if (sel_1 == 0 && sel_2 ==1 && sel_3 ==2 )
                                        begin
                                            number_array [3] <= gray_value [2] ;
                                            number_array [4] <= gray_value [1] ;
                                            weight_compare [0]  <= 3 ;
                                            weight_compare [1]  <= 4 ;
                                            sel_3 <= 3 ; 
                                        end
                                    if (sel_1 == 0 && sel_2 ==1  && sel_3 == 3)
                                        begin
                                            number_array [2] <= gray_value [2] ;
                                            number_array [4] <= gray_value [1] ;
                                            weight_compare [0]  <= 2 ;
                                            weight_compare [1]  <= 4 ;
                                            sel_3 <= 4 ; 
                                        end   
                                    if (sel_1 == 0 && sel_2 ==1  && sel_3 == 4)
                                        begin
                                            number_array [2] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            weight_compare [0]  <= 2 ;
                                            weight_compare [1]  <= 3 ;
                                            sel_2 <= 2 ;
                                            sel_3 <= 3 ; 
                                        end    
                                   if (sel_1 == 0 && sel_2 ==2  && sel_3 == 3)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [4] <= gray_value [1] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 4 ;
                                            sel_3 <= 4 ; 
                                        end
                                   if (sel_1 == 0 && sel_2 ==2  && sel_3 == 4)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 3 ;
                                            sel_2 <= 3 ;
                                            sel_3 <= 4 ; 
                                        end        
                                   if (sel_1 == 0 && sel_2 ==3  && sel_3 == 4)
                                        begin
                                            number_array [1] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            weight_compare [0]  <= 1 ;
                                            weight_compare [1]  <= 2 ;
                                            sel_1 <= 1 ;
                                            sel_2 <= 2 ;
                                            sel_3 <= 3 ; 
                                        end
                                   if (sel_1 == 1 && sel_2 ==2  && sel_3 == 3)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [4] <= gray_value [1] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 4 ;
                                            sel_3 <= 4 ; 
                                        end
                                   if (sel_1 == 1 && sel_2 ==2  && sel_3 == 4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [3] <= gray_value [1] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 3 ;
                                            sel_2 <= 3 ;
                                            sel_3 <= 4 ; 
                                        end
                                   if (sel_1 == 1 && sel_2 ==3  && sel_3 == 4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [2] <= gray_value [1] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 2 ;
                                            sel_1 <= 2 ;
                                            sel_2 <= 3 ;
                                            sel_3 <= 4 ; 
                                        end
                                   if (sel_1 == 2 && sel_2 ==3  && sel_3 == 4)
                                        begin
                                            number_array [0] <= gray_value [2] ;
                                            number_array [1] <= gray_value [1] ;
                                            weight_compare [0]  <= 0 ;
                                            weight_compare [1]  <= 1 ;
                                            sel_1 <= 0 ;
                                            sel_2 <= 1 ;
                                            sel_3 <= 2 ; 
                                            all_done <= 1 ;
                                        end
                             end  
                      3'd4 : begin
                                number_array [sel_1] <= sel_in [sel_1] ;
                                number_array [sel_2] <= sel_in [sel_2] ;
                                number_array [sel_3] <= sel_in [sel_3] ;
                                number_array [sel_4] <= sel_in [sel_4] ;
                                ab_position [0] <= sel_1 ;
                                ab_position [1] <= sel_2 ; 
                                ab_position [2] <= sel_3 ;
                                ab_position [3] <= sel_4 ;
                                   if (sel_1 == 0 && sel_2 ==1 && sel_3 ==2 && sel_4 ==3)
                                        begin
                                            number_array[4] <= gray_value[2] ; 
                                            weight_compare [0]  <= 4 ;
                                            sel_4 <= 4 ; 
                                        end
                                    if (sel_1 == 0 && sel_2 ==1 && sel_3 ==2 && sel_4 ==4)
                                        begin
                                            number_array[3] <= gray_value[2] ; 
                                            weight_compare [0]  <= 3 ;
                                            sel_3 <= 3 ;
                                            sel_4 <= 4 ; 
                                        end 
                                    if (sel_1 == 0 && sel_2 ==1 && sel_3 ==3 && sel_4 ==4)
                                        begin
                                            number_array[2] <= gray_value[2] ; 
                                            weight_compare [0]  <= 2 ;
                                            sel_2 <= 2 ;
                                            sel_3 <= 3 ;
                                            sel_4 <= 4 ; 
                                        end   
                                    if (sel_1 == 0 && sel_2 ==2 && sel_3 ==3 && sel_4 ==4)
                                        begin
                                            number_array[1] <= gray_value[2] ; 
                                            weight_compare [0]  <= 1 ;
                                            sel_1 <= 1 ;
                                            sel_2 <= 2 ;
                                            sel_3 <= 3 ;
                                            sel_4 <= 4 ; 
                                        end  
                                    if (sel_1 == 1 && sel_2 ==2 && sel_3 ==3 && sel_4 ==4)
                                        begin
                                            number_array[0] <= gray_value[2] ; 
                                            weight_compare [0]  <= 0 ;
                                            sel_1 <= 0 ;
                                            sel_2 <= 1 ;
                                            sel_3 <= 2 ;
                                            sel_4 <= 3 ; 
                                            all_done <= 1 ; 
                                        end       
                            end
                      3'd5 : begin
                                if(!all_done)
                                    begin
                                         number_array [0] <= sel_in [0] ;
                                         number_array [1] <= sel_in [1] ;
                                         number_array [2] <= sel_in [2] ;
                                         number_array [3] <= sel_in [3] ;
                                         number_array [4] <= sel_in [4] ;
                                         all_done <= 1 ;
                                    end
                                else
                                    begin
                                        all_done <= 0 ;
                                    end    
                            end    
                       
                    endcase
               end
        end
    else if (current_state == compute)
        begin
            new_value <= (get_array[0]*weight_in[0] + get_array[1]*weight_in[1]) +  (get_array[2]*weight_in[2] + get_array[3]*weight_in[3]) +(get_array[4]*weight_in[4])   ;
        end 
     else if (current_state == compare)
        begin
					// sort 
					count_sort <= count_sort + 1 ; 
					case (number_ab)
						3'd2 : begin
                           if (nA_nB[0]==2)
                                begin
                                    if (count_sort ==0)
                                         begin
                                              final_sort <= 1 ;
                                              if(weight_in [  weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [ weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                           end                       
                                      if  (count_sort == 1)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                           else if (nA_nB[0] == 1)
                                begin
                                     if (count_sort ==0)
                                         begin
                                              if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [ weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     if (count_sort == 1  )
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                      if (count_sort == 2  )
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end    
                                     if (count_sort == 3  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [ weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end  
                                     if (count_sort == 4  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     if (count_sort == 5  )
                                        begin
                                                final_sort <= 1 ;
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     if (count_sort == 6)   
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end       
                                end
                                
                           else  if (nA_nB[0] == 0)
                                begin
                                    if (count_sort ==0)
                                         begin
                                              if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [ weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [ weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [ weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                    else if (count_sort == 1  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     else if (count_sort == 2  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end    
                                    else if (count_sort == 3  )
                                        begin
                                                if(weight_in [  weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [ weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [ ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end  
                                    else if (count_sort == 4  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [  ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   ab_position [0]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[   ab_position [0]  ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                    else if (count_sort == 5  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [1] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[  ab_position [1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [1] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                    else if (count_sort == 6  )
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                    begin
                                                        if(weight_in [weight_compare[1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [ ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     else if (count_sort == 7  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0]]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[0] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1]]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end    
                                    else if (count_sort == 8  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [  ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   ab_position [1]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[   ab_position [1]  ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end  
                                    else if (count_sort == 9  )
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[2] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[2] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[2] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[2] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ weight_compare[1] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                    else if (count_sort == 10  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0]]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[0] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[0] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1]]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                        
                                    else if (count_sort == 11  )
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in  [ ab_position [1] ])
                                                    begin
                                                        if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ ab_position [1] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[  ab_position [0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [0] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2]  ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [   weight_compare[2] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end    
                                                        end
                                                end
                                        end
                                     else if (count_sort == 12  )
                                        begin
                                                final_sort <= 1 ;
                                                if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[0] ])
                                                    begin
                                                        if(weight_in [ weight_compare[0] ]  >   weight_in  [ weight_compare[1] ])
                                                            begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[2] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                            end
                                                        else
                                                            begin
                                                                 if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[   weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end
                                                                else
                                                                    begin
                                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                        get_array [ weight_compare[0] ]  <= number_array[  weight_compare[2] ]   ;
                                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                        get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                    end   
                                                            end
                                                    end
                                            else 
                                                begin
                                                     if(weight_in [ weight_compare[0] ]  <   weight_in  [ weight_compare[1] ])
                                                        begin
                                                                get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[  weight_compare[1] ]   ;
                                                                get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                                get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                        end
                                                    else
                                                        begin
                                                             if(weight_in [ ab_position [1] ]  >   weight_in  [ weight_compare[1] ])
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[  weight_compare[2] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end
                                                             else
                                                                begin
                                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[2] ]  ;
                                                                    get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0] ]   ;
                                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                                    get_array [ weight_compare[2] ]  <= number_array[ ab_position [0] ]   ;
                                                                end    
                                                        end
                                                end
                                        end    
                                        
                                    else if (count_sort == 13)   
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end   
                                end    
                        end
                3'd3 : begin
                            if (nA_nB[0] == 3 )
                                begin
                                    if (count_sort ==0)
                                         begin
                                            final_sort <= 1 ;
                                            if ( weight_in [  weight_compare[0] ]  >   weight_in [  weight_compare[1] ]  )
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [2] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [2] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end
                                        end
                                     else if (count_sort == 1)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            else if (nA_nB[0] == 2)
                                begin
                                    if (count_sort ==0)
                                         begin    
                                            if ( weight_in [  ab_position [2] ]  >   weight_in [  weight_compare[1] ]  )
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end    
                                        end
                                    else if (count_sort == 1)
                                        begin
                                            if ( weight_in [  ab_position [2] ]  >   weight_in [  weight_compare[0] ]  )
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [2] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [2] ]   ;
                                                end
                                            
                                        end  
                                      // -----------------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==2)
                                         begin
                                            if ( weight_in [  ab_position [1] ]  >   weight_in [  weight_compare[1] ]  )
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end
                                        end
                                    else if (count_sort == 3)
                                        begin
                                            if ( weight_in [  ab_position [1] ]  >   weight_in [  weight_compare[0] ]  )
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                end
                                        end
                                        // -----------------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==4)
                                         begin
                                            if ( weight_in [  ab_position [0] ]  >   weight_in [  weight_compare[1] ]  )
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end    
                                        end
                                    else if (count_sort == 5)
                                        begin
                                            final_sort <= 1 ;
                                            if ( weight_in [  ab_position [0] ]  >   weight_in [  weight_compare[0] ]  )
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array[  weight_compare[0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array[  weight_compare[1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                end
                                        end
                                        // -----------------------------------------------------------------------------------------------------------------
                                     else if (count_sort == 6)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            else if (nA_nB[0] == 1)
                                begin
                                     if (count_sort ==0)
                                         begin
                                            if (weight_in [  ab_position [1] ]  >   weight_in [  weight_compare[1] ])
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end    
                                        end
                                    else if (count_sort == 1)
                                        begin
                                             if (weight_in [  weight_compare[0] ]  >   weight_in [  weight_compare[1] ])
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                    get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end
                                        end
                                    else if (count_sort ==2)
                                         begin
                                                if (weight_in [ ab_position [1] ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                         end
                                    else if (count_sort == 3)
                                        begin
                                                if (weight_in [ ab_position [2] ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                         end
                                    else if (count_sort == 4)
                                        begin
                                                if (weight_in [ ab_position [1] ]  >   weight_in [   ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                        end
                                    else if (count_sort ==5)
                                         begin
                                                if (weight_in [ ab_position [2] ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 6)
                                        begin
                                                if (weight_in [ ab_position [1] ]  >   weight_in [  ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                        end
                                    ///   -----------------------------------------------------------------------------------------------------------
                                     else if (count_sort ==7)
                                         begin
                                            if (weight_in [  ab_position [0] ]  >   weight_in [  weight_compare[1] ])
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end    
                                        end
                                    else if (count_sort == 8)
                                        begin
                                             if (weight_in [  weight_compare[0] ]  >   weight_in [  weight_compare[1] ])
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                end
                                            else
                                                begin
                                                    get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                    get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                    get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                    get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                    get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                end
                                        end
                                    else if (count_sort ==9)
                                         begin
                                                if (weight_in [ ab_position [0] ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                         end
                                    else if (count_sort == 10)
                                        begin
                                                if (weight_in [ ab_position [2] ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                         end
                                    else if (count_sort == 11)
                                        begin
                                                if (weight_in [ ab_position [0] ]  >   weight_in [   ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2] ]   ;
                                                    end
                                        end
                                    else if (count_sort ==12)
                                         begin
                                                if (weight_in [ ab_position [2] ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 13)
                                        begin
                                                if (weight_in [ ab_position [0] ]  >   weight_in [  ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                        end
                                    //    --------------------------------------------------------------------------------------------------------------------      
                                    else if (count_sort ==14)
                                         begin
                                                if(weight_in [  ab_position [1] ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 15)
                                        begin
                                                if(weight_in [  weight_compare[0] ]  >   weight_in [   weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort ==16)
                                         begin
                                                if(weight_in [  ab_position [1] ]  >   weight_in [   weight_compare[0]  ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;        
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;        
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 17)
                                        begin
                                                if(weight_in [   ab_position [0] ]  >   weight_in [   weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;           
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;           
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 18)
                                        begin
                                                if(weight_in [   ab_position [1] ]  >   weight_in [  ab_position [0] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;          
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[   weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;          
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[   weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0] ]   ;
                                                    end
                                        end   
                                    else if (count_sort ==19)
                                         begin
                                                if(weight_in [  ab_position [0]  ]  >   weight_in [   weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;  
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ;  
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 20)
                                        begin
                                                final_sort <= 1 ;
                                                if(weight_in [   ab_position [1]  ]  >   weight_in [  ab_position [0] ])
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ; 
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [2] ]  <= number_array [  ab_position [2] ]  ; 
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                        end
                                     else if (count_sort == 21)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end    
                                end
                            else     ///     0A 3B 
                                begin
                                     if (count_sort ==0)
                                         begin
                                                if(weight_in [   ab_position [0]  ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 1)
                                        begin
                                                if(weight_in [   ab_position [0]  ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]  ]   ;
                                                    end
                                        end   
                                    else if (count_sort ==2)
                                         begin
                                                if(weight_in [   weight_compare[0]  ]  >   weight_in [  weight_compare[1]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                    end
                                        end
                                    else if (count_sort == 3)
                                        begin
                                                if(weight_in [   ab_position [0]  ]  >   weight_in [ ab_position [2]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 4)
                                        begin
                                                if(weight_in [   ab_position [2]  ]  >   weight_in [ weight_compare[1]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0]   ]   ;
                                                    end
                                        end        
                                    else if (count_sort ==5)
                                         begin
                                                if(weight_in [    ab_position [0]  ]  >   weight_in [ ab_position [2]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 6)
                                        begin
                                                if(weight_in [    ab_position [2]  ]  >   weight_in [ weight_compare[0]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1]   ]   ;
                                                    end
                                        end
                                    else if (count_sort ==7)
                                         begin
                                                if(weight_in [    ab_position [2]  ]  >   weight_in [ weight_compare[1]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1]   ]   ;
                                                    end
                                                else
                                                    begin   
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 8)
                                        begin
                                                if(weight_in [     ab_position [2]  ]  >   weight_in [ weight_compare[0]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]   ]   ;
                                                    end
                                        end
                                   //////  -----------------------------------------------------------------------------------------------------------------   
                                    else if (count_sort ==9)
                                         begin
                                                if(weight_in [    ab_position [0]  ]  >   weight_in [  ab_position [1]  ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 10)
                                        begin
                                                 if(weight_in [    ab_position [0]  ]  >   weight_in [ weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                    end
                                                 else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0] ]   ;
                                                    end
                                        end       
                                    else if (count_sort ==11)
                                         begin
                                                if(weight_in [    ab_position [1]   ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 12)
                                        begin
                                                if(weight_in [     ab_position [0]   ]  >   weight_in [ ab_position [1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 13)
                                        begin
                                                if(weight_in [   ab_position [0]  ]  >   weight_in [ weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                        end     
                                    else if (count_sort ==14)
                                         begin
                                                if(weight_in [    ab_position [1]  ]  >   weight_in [ weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [1]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 15)
                                        begin
                                                if(weight_in [    weight_compare[0]  ]  >   weight_in [ weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  ab_position [0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                    end
                                        end
                                    else if (count_sort ==16)
                                         begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in [ weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ weight_compare[0]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 17)
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in [ weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]   ]   ;
                                                    end
                                        end
                                   //////  -----------------------------------------------------------------------------------------------------------------   
                                    else if (count_sort ==18)
                                         begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in [ ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 19)
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in [ ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [1] ]   ;
                                                    end
                                        end       
                                    else if (count_sort ==20)
                                         begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in [  weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 21)
                                        begin
                                                if(weight_in [ ab_position [1] ]  >   weight_in [   weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[1]  ]   ;
                                                    end
                                                else
                                                    begin   
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  weight_compare[0]  ]   ;
                                                    end
                                        end
                                    else if (count_sort == 22)
                                        begin
                                                if(weight_in [ ab_position [0] ]  >   weight_in [   ab_position [1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]   ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]   ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [2]   ]   ;
                                                    end
                                        end
                                    else if (count_sort ==23)
                                         begin
                                                if(weight_in [ ab_position [2]  ]  >   weight_in [   weight_compare[1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[   weight_compare[1]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[   weight_compare[0]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 24)
                                        begin
                                                if(weight_in [ ab_position [1]  ]  >   weight_in [  ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [2]  ]   ;
                                                    end
                                        end
                                     //     --------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==25)
                                         begin
                                                if(weight_in [ ab_position [2]  ]  >   weight_in [ weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 26)
                                        begin
                                                if(weight_in [ ab_position [1]  ]  >   weight_in [ ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ ab_position [1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0] ]   ;
                                                    end
                                        end
                                    else if (count_sort ==27)
                                         begin
                                                if(weight_in [ ab_position [1]  ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[   ab_position [0] ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [   ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[   ab_position [1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[   ab_position [0] ]   ;
                                                    end
                                        end
                                    else if (count_sort == 28)
                                        begin
                                                if(weight_in [ab_position [0]  ]  >   weight_in [  weight_compare[0] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [   weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]  ]   ;
                                                    end
                                        end
                                    else if (count_sort == 29)
                                        begin
                                                if(weight_in [ ab_position [0]  ]  >   weight_in [ ab_position [1] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[1]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]   ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [  weight_compare[0]  ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [2]   ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[  ab_position [0]   ]   ;
                                                    end
                                        end
                                    else if (count_sort ==30)
                                         begin
                                                if(weight_in [ ab_position [1]  ]  >   weight_in [  ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[    ab_position [0]   ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [  ab_position [2] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[  weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[  ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[    ab_position [0]   ]   ;
                                                    end
                                        end
                                    else if (count_sort == 31)
                                        begin
                                                final_sort <= 1 ;
                                                if(weight_in [ ab_position [0]  ]  >   weight_in [  ab_position [2] ])
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[0] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ ab_position [2]]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[1] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0]  ]   ;
                                                    end
                                                else
                                                    begin
                                                        get_array [  ab_position [0] ]  <= number_array [ weight_compare[1] ]  ;
                                                        get_array [  ab_position [1] ]  <= number_array [ ab_position [2]]  ;
                                                        get_array [  ab_position [2] ]  <= number_array[ weight_compare[0] ]   ;
                                                        get_array [ weight_compare[0] ]  <= number_array[ ab_position [1]  ]   ;
                                                        get_array [ weight_compare[1] ]  <= number_array[ ab_position [0]  ]   ;
                                                    end
                                        end
                                    else if (count_sort == 32)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end    
                                end
                       end
                3'd4 : begin
                            if (nA_nB[0] == 4 )
                                begin
                                    if (count_sort ==0)
                                         begin
                                            get_array [ 0 ]  <= number_array[ 0 ]  ;
                                            get_array [ 1 ]  <= number_array[ 1 ]  ;
                                            get_array [ 2 ]  <= number_array[ 2 ]   ;
                                            get_array [ 3 ]  <= number_array[ 3 ]   ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
											final_sort <= 1 ;
                                        end
                                     else if (count_sort == 1)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            else if (nA_nB[0] == 3)
                                begin
                                    if (count_sort ==0)
                                         begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end
                                        
                                    else if (count_sort == 1)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ]   ;
                                        end
                                    else if (count_sort == 2)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end    
                                    else if (count_sort == 3)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                            final_sort <= 1 ;
                                        end     
                                    else if (count_sort == 4)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            else if (nA_nB[0] == 2 )
                                begin
                                    if (count_sort ==0)
                                         begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[weight_compare[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end
                                    else if (count_sort == 1)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ab_position[3]  ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                        end    
                                    else if (count_sort == 2)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ]   ;
                                        end
                                    // ----------------------------------------------------------------------------------------------------------------
                                    else if (count_sort == 3)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end  
                                     else if (count_sort == 4)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ab_position[3]  ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                        end
                                        
                                     else if (count_sort == 5)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end
                                     // ----------------------------------------------------------------------------------------------------------------
                                     else if (count_sort == 6)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[weight_compare[0] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ]   ;
                                        end  
                                     else if (count_sort == 7)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end
                                    else if (count_sort == 8)
                                        begin
                                             get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                        end   
                                     // ----------------------------------------------------------------------------------------------------------------
                                    else if (count_sort == 9)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end  
                                     else if (count_sort == 10)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ab_position[3]  ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                        end    
                                        
                                     else if (count_sort == 11)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                        end
                                     // ----------------------------------------------------------------------------------------------------------------
                                   else if (count_sort == 12)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ]   ;
                                        end  
                                     else if (count_sort == 13)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                        end
                                    else if (count_sort == 14)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                        end       
                                     // ----------------------------------------------------------------------------------------------------------------      
                                    else if (count_sort == 15)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]   ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end  
                                     else if (count_sort == 16)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                        end
                                    else if (count_sort == 17)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                            final_sort <= 1 ;
                                        end           
                                    // ----------------------------------------------------------------------------------------------------------------                                       
                                    else if (count_sort == 18)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            else if (nA_nB[0] == 1 )
                                begin
                                    if (count_sort ==0)
                                         begin 
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end
                                        
                                    else if (count_sort == 1)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[  ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                        end
                                    else if (count_sort == 2)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 3)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                    //  --------------------------------------------------------------------------------------------------    
                                        
                                    else if (count_sort == 4)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 5)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 6)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                        end
                                    else if (count_sort == 7)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                   //  ------------------------------------------------------------------------------------------------     
                                        
                                    else if (count_sort == 8)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end
                                    else if (count_sort == 9)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end   
                                    else if (count_sort == 10)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end
                                    //   -----------------------------------------------------------------------------------------------------------   
                                    else if (count_sort ==11)
                                         begin 
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end
                                        
                                    else if (count_sort == 12)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[  ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                        end
                                    else if (count_sort == 13)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 14)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                    //  --------------------------------------------------------------------------------------------------    
                                        
                                    else if (count_sort == 15)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 16)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 17)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                        end
                                    else if (count_sort == 18)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                   //  ------------------------------------------------------------------------------------------------     
                                        
                                    else if (count_sort == 19)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 20)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end   
                                    else if (count_sort == 21)
                                        begin
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    // -------------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==22)
                                         begin 
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                        end
                                        
                                    else if (count_sort == 23)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[  ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                        end
                                    else if (count_sort == 24)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 25)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                    //  --------------------------------------------------------------------------------------------------    
                                        
                                    else if (count_sort == 26)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 27)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 28)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                        end
                                    else if (count_sort == 29)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[3] ]   ;
                                        end
                                   //  ------------------------------------------------------------------------------------------------     
                                        
                                    else if (count_sort == 30)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end
                                    else if (count_sort == 31)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end   
                                    else if (count_sort == 32)
                                        begin
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end
                                    //  -----------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==33)
                                         begin 
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                        end
                                        
                                    else if (count_sort == 34)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  weight_compare[0]  ]   ;
                                        end
                                    else if (count_sort == 35)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 36)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                    //  --------------------------------------------------------------------------------------------------    
                                        
                                    else if (count_sort == 37)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 38)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 39)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0] ]   ;
                                        end
                                    else if (count_sort == 40)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ]   ;
                                        end
                                   //  ------------------------------------------------------------------------------------------------     
                                        
                                    else if (count_sort == 41)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end
                                    else if (count_sort == 42)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                        end   
                                    else if (count_sort == 43)
                                        begin
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[ weight_compare[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ]   ;
                                            final_sort <= 1 ;
                                        end          
                                    else if (count_sort == 44)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end                  
                                end
                            else     ///    0A4B
                                begin   
                                    if (count_sort ==0)
                                         begin 
                                                if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  > weight_in [weight_compare[0]] )
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [weight_compare[0]])
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 1)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[weight_compare[0]]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2] ] ; 
                                        end
                                    else if (count_sort == 2)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[weight_compare[0]]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3] ] ; 
                                        end
                                    else if (count_sort == 3)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  > weight_in [ ab_position[2] ] )
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  < weight_in [ab_position[2] ])
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2] ] ; 
                                        end
                                    else if (count_sort == 4)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[2] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [ ab_position[2] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[2] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[2]  ]  < weight_in [weight_compare[0]  ])
                                                            begin
                                                                get_array [  ab_position[2] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[2] ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                        end
                                     else if (count_sort == 5)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [ ab_position[2] ] )
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[0]   ]  < weight_in [ ab_position[2]  ])
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2]  ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1] ] ; 
                                        end
                                    else if (count_sort == 6)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[   ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1] ] ; 
                                        end
                                    else if (count_sort == 7)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[2] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [ ab_position[2]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[2]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[2]   ]  < weight_in [ weight_compare[0]  ])
                                                            begin
                                                                get_array [ ab_position[2]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[2]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                        end
                                    else if (count_sort == 8)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[0] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[  ab_position[3]  ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[  weight_compare[0]  ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ] ; 
                                        end    
                                    //   ---------------------------------------------------------------------------------------------------    
                                    else if (count_sort ==9)
                                         begin 
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [ ab_position[1] ] )
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[1]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[0]  ]  < weight_in [ ab_position[1]  ])
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[1] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[1]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ]   ;
                                        end
                                    else if (count_sort == 10)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [  ab_position[0]  ]  < weight_in [ weight_compare[0]  ])
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                        end
                                    else if (count_sort == 11)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[1] ]  > weight_in [  weight_compare[0] ] )
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [ weight_compare[0]  ])
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end    
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[  ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                        end
                                    else if (count_sort == 12)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[0]]  > weight_in [  ab_position[1] ] )
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ ab_position[1]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [ab_position[1]  ])
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[1] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[1]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end 
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[1] ] ; 
                                        end
                                     else if (count_sort == 13)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1] ] ; 
                                        end
                                    else if (count_sort == 14)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0]  ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1] ] ; 
                                        end
                                    else if (count_sort == 15)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[   ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[3] ] ; 
                                        end
                                    else if (count_sort == 16)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[  weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2]  ] ; 
                                        end
                                    else if (count_sort == 17)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [weight_compare[0]  ])
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                        end
                                    //   ---------------------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==18)
                                         begin 
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  > weight_in [ ab_position[2] ] )
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [ab_position[2]  ])
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end
                                    else if (count_sort == 19)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  > weight_in [ ab_position[2] ] )
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [ab_position[2]  ])
                                                            begin
                                                                get_array [ab_position[1]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2]  ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[1]  ]   ;
                                        end
                                    else if (count_sort == 20)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [   ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [weight_compare[0]  ])
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[  ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 21)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[1] ]  > weight_in [ weight_compare[0] ] )
                                                            begin
                                                                get_array [   ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [ weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [weight_compare[0]  ])
                                                            begin
                                                                get_array [ ab_position[1] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                        end
                                     else if (count_sort == 22)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [  ab_position[1] ] )
                                                            begin
                                                                get_array [   ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[1]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [ ab_position[1]  ])
                                                            begin
                                                                get_array [ ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ ab_position[1] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[2] ] ; 
                                        end
                                    else if (count_sort == 23)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[2] ]  > weight_in [  weight_compare[0] ] )
                                                            begin
                                                                get_array [   ab_position[2]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  weight_compare[0]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[2]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[2] ]  < weight_in [ weight_compare[0]  ])
                                                            begin
                                                                get_array [ab_position[2] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [weight_compare[0] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[2]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  weight_compare[0] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                        end
                                    else if (count_sort == 24)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[1] ]  > weight_in [  ab_position[2] ] )
                                                            begin
                                                                get_array [   ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [ ab_position[2]  ])
                                                            begin
                                                                get_array [ab_position[1] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[   ab_position[2] ] ; 
                                        end
                                    //  ---------------------------------------------------------------------------------------------------------------
                                    else if (count_sort ==25)
                                         begin 
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [  ab_position[2] ] )
                                                            begin
                                                                get_array [   ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[0] ]  < weight_in [ ab_position[2]  ])
                                                            begin
                                                                get_array [ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0]  ]   ;
                                        end
                                    else if (count_sort == 26)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[1] ]  > weight_in [  ab_position[2] ] )
                                                            begin
                                                                get_array [   ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [  ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ ab_position[1] ]  < weight_in [ ab_position[2]  ])
                                                            begin
                                                                get_array [ab_position[1] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[2] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ] ; 
                                        end
                                    else if (count_sort == 27)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[0] ]  > weight_in [  ab_position[1] ] )
                                                            begin
                                                                get_array [   ab_position[0]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[1]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ab_position[0] ]  < weight_in [ab_position[1]  ])
                                                            begin
                                                                get_array [ab_position[0] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[1] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[0]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[1] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[2] ]  <= number_array[  ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0] ] ; 
                                        end
                                    else if (count_sort == 28)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[3] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[   ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ] ; 
                                        end
                                    else if (count_sort == 29)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[   ab_position[3] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[1] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[  ab_position[0] ] ; 
                                        end
                                     else if (count_sort == 30)
                                        begin
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[1] ]  <= number_array[  ab_position[2] ]  ;
                                            get_array [ ab_position[2] ]  <= number_array[ ab_position[3] ]   ;
                                            get_array [ ab_position[3] ]  <= number_array[ weight_compare[0] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0] ] ; 
                                        end
                                    else if (count_sort == 31)
                                        begin
                                            if( number_array[weight_compare[0]]   >  number_array[ ab_position[3] ]  )
                                                    begin
                                                        if (weight_in [  ab_position[1] ]  > weight_in [ ab_position[2] ] )
                                                            begin
                                                                get_array [   ab_position[1]  ]  <= number_array [weight_compare[0] ]  ;
                                                                get_array [  ab_position[2]  ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [  ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                                else
                                                    begin
                                                        if (weight_in [ab_position[1] ]  < weight_in [ab_position[2]  ])
                                                            begin
                                                                get_array [ab_position[1] ]  <= number_array[weight_compare[0] ]  ;
                                                                get_array [ab_position[2] ]  <= number_array[ ab_position[3]  ]   ;
                                                            end
                                                        else
                                                            begin
                                                                get_array [ ab_position[1]  ]  <= number_array[ab_position[3]  ]  ;
                                                                get_array [ ab_position[2] ]  <= number_array[ weight_compare[0]  ]   ;
                                                            end
                                                    end
                                            get_array [ ab_position[0] ]  <= number_array[ ab_position[1] ]  ;
                                            get_array [ ab_position[3] ]  <= number_array[ ab_position[2] ]   ;
                                            get_array [ weight_compare[0] ]  <= number_array[ ab_position[0] ] ; 
                                            final_sort <= 1 ;
                                        end
                                    //   ----------------------------------------------------------------------------------------------------------
                                    else if (count_sort == 32)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                            end
                3'd5 : begin
                             if (nA_nB[0] == 5)
                                begin
                                    if(count_sort ==0)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array[ 2 ]   ;
                                            get_array [ 3 ]  <= number_array[ 3 ]   ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
											final_sort <= 1 ;
                                        end
                                    else if (count_sort == 1)
                                        begin
                                            final_sort <= 0 ;
                                            count_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end
                                end
                             else if (nA_nB[0] == 3)
                                begin
                                     if(count_sort ==0)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array[ 2 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==1)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 3 ]  <= number_array[ 3 ]   ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==2)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                        end 
                                      else if(count_sort ==3)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 3 ]  <= number_array[ 3 ]   ;
                                            get_array [ 1 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==4)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 1 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==5)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 1 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==6)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 3 ]  <= number_array[ 3 ]   ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==7)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==8)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                        end   
                                     else if(count_sort ==9)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 4 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 1 ]  <= number_array[ 0 ]   ;
                                            final_sort <= 1 ;
                                        end                                  
                                    else if (count_sort == 10)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                             else if (nA_nB[0] == 2)
                                begin
                                    if(count_sort ==0)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==1)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==2)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==3)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==4)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array[ 4 ]   ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==5)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==6)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array[ 3 ]   ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==7)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==8)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end   
                                     else if(count_sort ==9)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end      
                                    else if(count_sort ==10)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                      else if(count_sort ==11)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==12)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==13)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==14)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 1 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==15)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 1 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==16)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 1 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                        end   
                                     else if(count_sort ==17)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 1 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                        end 
                                    else if(count_sort ==18)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 1 ]  <= number_array[ 0 ]   ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                        end 
                                      else if(count_sort ==19)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 1 ]  <= number_array[ 2 ]   ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            final_sort <= 1 ;
                                        end        
                                    else if (count_sort == 20)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                             else if (nA_nB[0] == 1)
                                begin
                                     if(count_sort ==0)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==1)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==2)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==3)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==4)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==5)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==6)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==7)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==8)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 0 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end   
                                     //  ------------------------------------------------------------------------   
                                     else if(count_sort ==9)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==10)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==11)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==12)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==13)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==14)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==15)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==16)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==17)
                                        begin
                                            get_array [ 1 ]  <= number_array [ 1 ]  ;
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                    //  ------------------------------------------------------------------------   
                                    else if(count_sort ==18)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==19)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==20)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==21)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==22)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==23)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==24)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==25)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==26)
                                        begin
                                            get_array [ 2 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                    //  ------------------------------------------------------------------------   
                                     else if(count_sort ==27)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end
                                    else if(count_sort ==28)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==29)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                      else if(count_sort ==30)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==31)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==32)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==33)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==34)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==35)
                                        begin
                                            get_array [ 3 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     //  ------------------------------------------------------------------------   
                                     else if(count_sort ==36)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==37)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==38)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==39)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==40)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==41)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 0 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==42)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==43)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==44)
                                        begin
                                            get_array [ 4 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 0 ]  <= number_array[ 1 ]   ;
                                            final_sort <= 1 ;
                                        end 
                                     //  -----------------------------------------------------------------                 
                                    else if (count_sort == 45)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                             else if (nA_nB[0] == 0)
                                begin
                                    if(count_sort ==0)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==1)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==2)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                      else if(count_sort ==3)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==4)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==5)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==6)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==7)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==8)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end   
                                     else if(count_sort ==9)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end      
                                    else if(count_sort ==10)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 0 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                        //----------------------------------------------------------------
                                      else if(count_sort ==11)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==12)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                      else if(count_sort ==13)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==14)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end 
                                     else if(count_sort ==15)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==16)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==17)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end  
                                     else if(count_sort ==18)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end   
                                     else if(count_sort ==19)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end      
                                    else if(count_sort ==20)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                     else if(count_sort ==21)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 0 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                      //  ------------------------------------------------------------------------
                                      
                                     else if(count_sort ==22)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                      else if(count_sort ==23)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==24)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==25)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 1 ]   ;
                                        end 
                                     else if(count_sort ==26)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     else if(count_sort ==27)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==28)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end   
                                     else if(count_sort ==29)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end      
                                    else if(count_sort ==30)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 3 ]   ;
                                        end
                                    else if(count_sort ==31)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end  
                                     else if(count_sort ==32)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 0 ]   ;
                                            get_array [ 4 ]  <= number_array[ 2 ]   ;
                                        end 
                                     //  -------------------------------------------------------------------   
                                        
                                      else if(count_sort ==33)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==34)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==35)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 1 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==36)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                     else if(count_sort ==37)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==38)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 4 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end   
                                     else if(count_sort ==39)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 3 ]   ;
                                            get_array [ 3 ]  <= number_array[ 1 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end      
                                    else if(count_sort ==40)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 4 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end
                                    else if(count_sort ==41)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 4 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 2 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end  
                                     else if(count_sort ==42)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 3 ]  ;
                                            get_array [ 1 ]  <= number_array [ 2 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                        end 
                                      else if(count_sort ==43)
                                        begin
                                            get_array [ 0 ]  <= number_array [ 2 ]  ;
                                            get_array [ 1 ]  <= number_array [ 3 ]  ;
                                            get_array [ 2 ]  <= number_array[ 1 ]   ;
                                            get_array [ 3 ]  <= number_array[ 4 ]   ;
                                            get_array [ 4 ]  <= number_array[ 0 ]   ;
                                            final_sort <= 1 ;
                                        end    
                                    else if (count_sort == 44)
                                        begin
                                            count_sort <= 0 ;
                                            final_sort <= 0 ;
											if(all_done)
												first_count <= 1 ;
                                        end 
                                end
                       end
					endcase	
            if (first_count)
                begin
                old_value <= 0 ;
                first_count <= 0 ;
                end
            else
                begin
					// compare
					if (new_value > old_value)
						begin
							  old_value <= new_value ; 
							  max[0] <= get_array[0] ;  
							  max[1] <= get_array[1] ;  
							  max[2] <= get_array[2] ;  
							  max[3] <= get_array[3] ;  
							  max[4] <= get_array[4] ;  
						end
					else if (new_value == old_value)
						begin
							if (  ( get_array[0]*16 +  (get_array[1]*8   + get_array[2]*4 ) + ( get_array[3]*2  + get_array[4] ) )      >   (   max[0]*16 +   ( max[1]*8 + max[2]*4 )  +   (max[3]*2 + max[4] )  )       )
								begin
										  old_value <= new_value ; 
										  max[0] <= get_array[0] ;  
										  max[1] <= get_array[1] ;  
										  max[2] <= get_array[2] ;  
										  max[3] <= get_array[3] ;  
										  max[4] <= get_array[4] ; 
								end
							else if (  (  ( (get_array[0]-max[0])*16 + (get_array[1]-max[1])*8 )   +   ( (get_array[2]-max[2])*4 + (get_array[3]-max[3])*2 ) +  (get_array[4]-max[4]) ) == 0 )
								begin
									 if  (max[0] == get_array[0])
										begin
											 if (max[1] == get_array[1])
												begin
													 if (max[2] == get_array[2])
														begin
															if (max[3] > get_array[3])
																begin
																	  max[0] <= get_array[0] ;  
																	  max[1] <= get_array[1] ;  
																	  max[2] <= get_array[2] ;  
																	  max[3] <= get_array[3] ;  
																	  max[4] <= get_array[4] ; 
																end
														end
													 else if (max[2] > get_array[2])
														begin
															  max[0] <= get_array[0] ;  
															  max[1] <= get_array[1] ;  
															  max[2] <= get_array[2] ;  
															  max[3] <= get_array[3] ;  
															  max[4] <= get_array[4] ;
														end
												end
											else if (max[1] > get_array[1])
												begin
													  max[0] <= get_array[0] ;  
													  max[1] <= get_array[1] ;  
													  max[2] <= get_array[2] ;  
													  max[3] <= get_array[3] ;  
													  max[4] <= get_array[4] ;
												end
										end
									else if (max[0] > get_array[0])
										begin
											  max[0] <= get_array[0] ;  
											  max[1] <= get_array[1] ;  
											  max[2] <= get_array[2] ;  
											  max[3] <= get_array[3] ;  
											  max[4] <= get_array[4] ;
										end
								end
						end 
				end	
        end  
     else if (current_state == out)
        begin
            if (count_out < 5 )
                begin
                    count_out <= count_out +1 ;
                    out_value <= old_value ; 
                    result <= max[count_out] ; 
                    out_valid <= 1 ;
                end
            else
                begin
//                    old_value <= 0 ;
                    count_out <= 0 ; 
                    out_value <= 0 ;
                    result <= 0 ;
                    out_valid <= 0 ;
                end
        end    
end



// ===============================================================
// Finite State Machine
// ===============================================================
// Current State
always@(posedge clk, negedge rst_n)
begin
    if (!rst_n) current_state <= store_value ;
    else current_state <= next_state;
end
//     next_state
always@(*)
begin
    case (current_state)
      store_value : begin
                         if (  count_2 ==2 && count_8 ==0 )
                            begin
                                 if (number_ab == 5)
                                    next_state = get_number ; 
                                 else
                                    next_state = separate;   
                            end
                         else
                                next_state = store_value ; 
                   end   
       separate :   begin
                         if(count_gray_value == 3 )
                            next_state = get_number;   
                         else 
                            next_state = separate ;  
                   end
       get_number : begin
                         if (all_done)
                            next_state = out ; 
                         else
                                next_state = compare ; 
                   end
       compute  :      begin  
                            next_state = compare ; 
                    end
        compare  :  begin
						if (final_sort)
							next_state = get_number ; 
						else
                           next_state = compute ;
                   end
            out :   begin
                          if (count_out ==5)
                            next_state = store_value;
                          else 
                            next_state = out ;     
                    end
           default : next_state = store_value ; 
    endcase
end


endmodule