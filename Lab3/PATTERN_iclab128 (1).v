`define CYCLE_TIME 15.0
`ifdef RTL
    `define CYCLE_TIME 15.0
`endif
`ifdef GATE
    `define CYCLE_TIME 15.0
`endif

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid1,
	in_valid2,
	in,
	in_data,
    // Input signals
    out_valid1,
	out_valid2,
    out,
	out_data
);

output reg clk, rst_n, in_valid1, in_valid2;
output reg [1:0] in;
output reg [8:0] in_data;
input out_valid1, out_valid2;
input [2:0] out;
input [8:0] out_data;
// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [1:0] maze_data [0:18][0:18];
reg signed [9:0] password_data [0:3];
reg signed [7:0] subtract_half_of_range[1:3] ;
reg signed [7:0] excess_data [0:3] ;
reg signed [7:0] max , min ; 

reg first_part ;
reg [3:0] second_part ;
reg [3:0] third_part ; 

reg signed [8:0]  golden_result [0:3];

parameter PATNUM=500 ; 
// ===============================================================
// Clock
// ===============================================================
always #(`CYCLE_TIME/2.0) clk = ~clk ; 
initial clk = 0 ;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer input_file, output_file;
integer total_cycles, cycles;
integer hostage_number , hostage_saved; 
integer  patcount;
integer gap, wait_password;
integer  b;
integer i, j , k;
integer golden_step;

reg count_trap_cycle ; 
reg [4:0] hostage_x [0:3] ;
reg [4:0] hostage_y [0:3] ; 
reg count_0_hostage , count_1_hostage , count_2_hostage , count_3_hostage ; 
integer player_x , player_y ; 

integer tmp ; 
// ===============================================================
// Initial
// ===============================================================
initial begin
	rst_n    = 1'b1;
	in_valid1 = 1'b0;
	in_valid2 = 1'b0;
	player_x = 1 ;
	player_y = 1 ;
	in =  'bx;
	in_data   =  'bx;
	hostage_number = 'b0;
	hostage_saved  = 'b0 ;
	max  = 'b0 ;
	min  = 'b0 ; 
	total_cycles = 0;
	count_trap_cycle = 0 ;
    
	force clk = 0;
	reset_task;
    
  input_file  = $fopen("../00_TESTBED/input.txt","r");
	@(negedge clk);


	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_data;
		wait_out_valid;
		check_out_data;
		
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end 

// ===============================================================
// TASK
// ===============================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid1 !== 0) || (out_valid2 !== 0) || (out_data !== 0)  || (out!==0)  ) begin
		$display ("         SPEC 3 IS FAIL!            ");
		#(100);
	    $finish ;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_data; begin
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	in_valid1 = 1'b1;
	for (i=0; i<=18 ; i=i+1) begin
	   for (j=0 ; j<=18 ; j=j+1 )
	       begin
	           if (i==0 || i==18 || j==0 || j==18)
	               begin
	                   maze_data[i][j] = 0 ;
	               end
	            else
	               begin
                        b = $fscanf (input_file, "%d", maze_data[i][j]) ;
                        if (maze_data[i][j]==3)
                            begin
                                hostage_x [hostage_number ] =  j ;
                                hostage_y [hostage_number ] =  i ;
                                hostage_number = hostage_number + 1 ;
                            end 
                   end
	       end
	    
	end
	for (i=1; i<=17; i=i+1) begin
	   for (j=1 ; j<=17 ; j=j+1)
	       begin
			  in = maze_data[i][j];
		      @(negedge clk);
		   end   
	end
	in_valid1 = 1'b0;
	in = 'bx;
end endtask



task password_given; begin
	first_part    = $urandom_range(0,1);
	second_part   = $urandom_range(3,12);
	third_part    = $urandom_range(3,12);
	
    wait_password = $urandom_range(2,4);
    repeat(wait_password)@(negedge clk); 
	in_valid2 = 1'b1 ;
	if (hostage_number%2==0)
	   begin
           in_data = {{first_part,second_part,third_part}} ; 
           password_data[hostage_saved] =  {{first_part,in_data}} ;
           @(negedge clk) ; 
        end
    else
        begin
            in_data = $urandom_range(-256,255) ; 
            password_data[hostage_saved] = {{in_data[8],in_data}} ;
            @(negedge clk) ; 
        end
	in_valid2 = 1'b0 ;
	in_data   = 'bx ; 
	
end endtask 

reg signed [8:0] excess_for_two_hos[0:1]  ;

task gen_golden_password; begin
     case (hostage_number)
       3'b000 : begin
                 golden_result[0] = 0;
              end
       3'b001 : begin
                 golden_result[0] = password_data[0] ;
                end
       3'b010 : begin
                  if (password_data[0] > password_data[1])
                     begin
                        if (password_data[0][9] ==1)
                            excess_for_two_hos [0] =   - ( (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) );
                        else
                            excess_for_two_hos [0] =   (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) ;
							
                        if (password_data[1][9] ==1)
                            excess_for_two_hos [1] =   - ( (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) ) ;
                        else
                            excess_for_two_hos [1] =   (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) ;
							
                     end
                  else
                     begin
						if (password_data[1][9] ==1)
                            excess_for_two_hos [0] =   - ( (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) ) ;
                        else
                            excess_for_two_hos [0] =   (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) ;
							
                        if (password_data[0][9] ==1)
                            excess_for_two_hos [1] =   -( (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) );
                        else
                            excess_for_two_hos [1] =   (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) ;
                     end
				  	 
					golden_result[0] = excess_for_two_hos[0] - (excess_for_two_hos[0] + excess_for_two_hos[1]) / 2 ;
					golden_result[1] = excess_for_two_hos[1] - (excess_for_two_hos[0] + excess_for_two_hos[1]) / 2 ; 
                end
		3'b011 : begin
					for (i=0 ; i<2 ; i=i+1)
						begin
							for (j=i+1 ; j<3 ; j=j+1)
								begin
									if (password_data[i] < password_data[j] )
										begin
											tmp = password_data[i] ;
											password_data[i] = password_data[j] ;
											password_data[j] = tmp ; 
										end
								end
						end
					golden_result[0] = password_data[0] - (password_data[0] + password_data[2] )/2 ;
					password_data[1] = password_data[1] - (password_data[0] + password_data[2] )/2 ;
					password_data[2] = password_data[2] - (password_data[0] + password_data[2] )/2 ;
					
					golden_result[1] = (golden_result[0]*2 + password_data[1] )/3 ;
					golden_result[2] = (golden_result[1]*2 + password_data[2] )/3 ;
				 end
		3'b100 : begin
					for (i=0 ; i<3 ; i=i+1)
						begin
							for (j=i+1 ; j<4 ; j=j+1)
								begin
									if (password_data[i] < password_data[j] )
										begin
											tmp = password_data[i] ;
											password_data[i] = password_data[j] ;
											password_data[j] = tmp ; 
										end
								end
						end
					if (password_data[0][8] ==1)
                            excess_data [0] =   - ( (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) );
                        else
                            excess_data [0] =   (password_data[0][7:4]-3)*10 + (password_data[0][3:0]-3) ;
							
                    if (password_data[1][8] ==1)
                            excess_data [1] =   - ( (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) );
                        else
                            excess_data [1] =   (password_data[1][7:4]-3)*10 + (password_data[1][3:0]-3) ;
					if (password_data[2][8] ==1)
                            excess_data [2] =   - ( (password_data[2][7:4]-3)*10 + (password_data[2][3:0]-3) );
                        else
                            excess_data [2] =   (password_data[2][7:4]-3)*10 + (password_data[2][3:0]-3) ;
							
                    if (password_data[3][8] ==1)
                            excess_data [3] =   -  ( (password_data[3][7:4]-3)*10 + (password_data[3][3:0]-3) ) ;
                        else
                            excess_data [3] =   (password_data[3][7:4]-3)*10 + (password_data[3][3:0]-3) ;		
					
					for (k=0 ; k<=3 ; k=k+1)
						begin
						    if (k==0)
						      begin
						          max = excess_data[k] ;
						          min = excess_data[k] ;    
						      end
						      
						    if (   max  <  excess_data [k])
							    max = excess_data[k] ;  
							if (   min  >  excess_data [k])
							    min = excess_data[k] ;   
						end
						
					golden_result[0] = excess_data[0] - (  max+min )/2 ;
					subtract_half_of_range[1] = excess_data[1] - (  max+min )/2 ;
					subtract_half_of_range[2] = excess_data[2] - (  max+min )/2 ;
					subtract_half_of_range[3] = excess_data[3] - (  max+min )/2 ;
					
					golden_result[1] = (golden_result[0]*2 + subtract_half_of_range[1] )/3 ;
					golden_result[2] = (golden_result[1]*2 + subtract_half_of_range[2] )/3 ;
					golden_result[3] = (golden_result[2]*2 + subtract_half_of_range[3] )/3 ;
					
				 end
     endcase
     
	 
end endtask

task check_exit_location; begin
     if (player_x !== 17 || player_y !== 17)
        begin
            $display ("             SPEC 8 IS FAIL!             ");                      
            repeat(2)@(negedge clk);
            $finish;
        end
end endtask

task reset_all_value; begin
    hostage_number = 0 ;
    hostage_saved  = 0 ; 
    player_x = 1 ;
    player_y = 1 ; 
    count_0_hostage = 0 ;
    count_1_hostage = 0 ; 
    count_2_hostage = 0 ;
    count_3_hostage = 0 ; 
end endtask

task check_out_data; begin
	golden_step = 0;
	
	while (out_valid1===1)
	   begin
	       
            if (out_data !== golden_result[golden_step])
                begin
                    $display ("                SPEC 10 IS FAIL!            ");                      
                    repeat(2)@(negedge clk);
                    $finish;
                end
            
            golden_step = golden_step +1 ;
            @(negedge clk) ;
            
       end
       if (out_data !== 0 )
                begin
                    $display ("                SPEC 11 IS FAIL!            ");                      
                    repeat(2)@(negedge clk);
                    $finish;
                end
       if (hostage_number ==0)
            begin
                if (golden_step !== hostage_number + 1)
                begin
                    $display ("                SPEC 9 IS FAIL!            ");
                    repeat(2)@(negedge clk);
                    $finish;
                end
            end
       else
            begin
                if (golden_step !== hostage_number)
                begin
                    $display ("                SPEC 9 IS FAIL!            ");
                    repeat(2)@(negedge clk);
                    $finish;
                end
            end
       
      reset_all_value ; 
end endtask 
    
    task check_out; begin
	if (out_data!== 0 )
		begin
			$display ("                      SPEC 7 IS FAIL!              ");
			repeat(2)@(negedge clk);
			$finish;
		end
				
    if (out===0)
        begin
			if (maze_data[player_y][player_x+1]==0)
				begin
					$display ("                      SPEC 7 IS FAIL!              ");
					repeat(2)@(negedge clk);
					$finish;
				end
		    if (maze_data[player_y][player_x]==2)
		        begin
		           if (count_trap_cycle == 0)
		              begin
                        $display ("                  SPEC 7 IS FAIL!               ");
                        repeat(2)@(negedge clk);
                        $finish;
                      end
                   else
                       count_trap_cycle = 0 ; 
		        end
            player_x <= player_x + 1 ;
            player_y <= player_y ;
        end
    else if (out===1)
        begin
			if (maze_data[player_y+1][player_x]==0)
				begin
					$display ("                           SPEC 7 IS FAIL!                     ");
					repeat(2)@(negedge clk);
					$finish;
				end
		    if (maze_data[player_y][player_x]==2)
		        begin
		           if (count_trap_cycle == 0)
		              begin
                        $display ("                       SPEC 7 IS FAIL!               ");
                        repeat(2)@(negedge clk);
                        $finish;
                      end
                   else
                       count_trap_cycle = 0 ; 
		        end
            player_x = player_x ;
            player_y = player_y + 1 ;
        end
    else if (out===2)
        begin
            if (maze_data[player_y][player_x-1]==0)
				begin
					$display ("                       SPEC 7 IS FAIL!                       ");
					repeat(2)@(negedge clk);
					$finish;
				end
		    if (maze_data[player_y][player_x]==2)
		        begin
		           if (count_trap_cycle == 0)
		              begin
                        $display ("                    SPEC 7 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                      end
                   else
                       count_trap_cycle = 0 ; 
		        end
		    player_x = player_x - 1 ;
            player_y = player_y ;
        end
    else if (out===3)
        begin
            if (maze_data[player_y-1][player_x]==0)
				begin
					$display ("                  SPEC 7 IS FAIL!                  ");
					repeat(2)@(negedge clk);
					$finish;
				end
		    if (maze_data[player_y][player_x]==2)
		        begin
		           if (count_trap_cycle == 0)
		              begin
                        $display ("                    SPEC 7 IS FAIL!                  ");
                        repeat(2)@(negedge clk);
                        $finish;
                      end
                   else
                       count_trap_cycle = 0 ; 
		        end
		    player_x = player_x ;
            player_y = player_y - 1  ;
        end
    else if (out===4)
        begin
            player_x = player_x ;
            player_y = player_y ;
            if (count_trap_cycle === 1 )
                begin
                    $display ("                         SPEC 7 IS FAIL!                     ");
					repeat(2)@(negedge clk);
					$finish;
                end
                
			if (maze_data[player_y][player_x]!=2)
				begin
					$display ("                         SPEC 7 IS FAIL!                     ");
					repeat(2)@(negedge clk);
					$finish;
				end
		    count_trap_cycle = count_trap_cycle + 'd1; 
        end
    else
        begin
            $display ("                         SPEC 7 IS FAIL!                     ");
            repeat(2)@(negedge clk);
            $finish;
        end
end endtask

task check_hostage_location; begin
        if (hostage_number == 1 )
            begin
                    
                if (  player_x !== hostage_x [0]    ||  player_y !== hostage_y [0]   )
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                    
                if (count_0_hostage==1  && player_x === hostage_x [0]  && player_y === hostage_y[0])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                    
                
                if (  player_x === hostage_x [0] &&  player_y === hostage_y[0]  )
                    begin
                        count_0_hostage = count_0_hostage + 1 ;
                    end
            end
        else if (hostage_number == 2 )
            begin
                  if (count_0_hostage==1  && player_x === hostage_x [0]  && player_y === hostage_y[0])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                  if (count_1_hostage==1  && player_x === hostage_x [1]  && player_y === hostage_y[1])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                  if (  (player_x !== hostage_x [0]    ||  player_y !== hostage_y [0])    &&    (player_x !== hostage_x [1]    ||  player_y !== hostage_y [1])      )
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                  
                  if (  player_x === hostage_x [0] &&  player_y === hostage_y[0]  )
                    begin
                        count_0_hostage = count_0_hostage + 1 ;
                    end
                   if (  player_x === hostage_x [1] &&  player_y === hostage_y[1]  )
                    begin
                        count_1_hostage = count_1_hostage + 1 ;
                    end
            end
        else if (hostage_number == 3 )
            begin
                  if (count_0_hostage==1  && player_x === hostage_x [0]  && player_y === hostage_y[0])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                  if (count_1_hostage==1  && player_x === hostage_x [1]  && player_y === hostage_y[1])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                  if (count_2_hostage==1  && player_x === hostage_x [2]  && player_y === hostage_y[2])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                    
                if (  (player_x !== hostage_x [0]    ||  player_y !== hostage_y [0])    &&    (player_x !== hostage_x [1]    ||  player_y !== hostage_y [1])    &&    (player_x !== hostage_x [2]    ||  player_y !== hostage_y [2])    )
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                if (  player_x === hostage_x [0] &&  player_y === hostage_y[0]  )
                    begin
                        count_0_hostage = count_0_hostage + 1 ;
                    end
                if (  player_x === hostage_x [1] &&  player_y === hostage_y[1]  )
                    begin
                        count_1_hostage = count_1_hostage + 1 ;
                    end
                if (  player_x === hostage_x [2] &&  player_y === hostage_y[2]  )
                    begin
                        count_2_hostage = count_2_hostage + 1 ;
                    end
            end
       else if (hostage_number == 4 )
            begin
                if (count_0_hostage==1  && player_x === hostage_x [0]  && player_y === hostage_y[0])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                  if (count_1_hostage==1  && player_x === hostage_x [1]  && player_y === hostage_y[1])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                  if (count_2_hostage==1  && player_x === hostage_x [2]  && player_y === hostage_y[2])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                  if (count_3_hostage==1  && player_x === hostage_x [3]  && player_y === hostage_y[3])
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end    
                if (  (player_x !== hostage_x [0]    ||  player_y !== hostage_y [0])    &&    (player_x !== hostage_x [1]    ||  player_y !== hostage_y [1])    &&    (player_x !== hostage_x [2]    ||  player_y !== hostage_y [2])   &&    (player_x !== hostage_x [3]    ||  player_y !== hostage_y [3])  )
                    begin
                        $display ("                         SPEC 8 IS FAIL!                     ");
                        repeat(2)@(negedge clk);
                        $finish;
                    end
                  if (  player_x === hostage_x [0] &&  player_y === hostage_y[0]  )
                    begin
                        count_0_hostage = count_0_hostage + 1 ;
                    end
                 if (  player_x === hostage_x [1] &&  player_y === hostage_y[1]  )
                    begin
                        count_1_hostage = count_1_hostage + 1 ;
                    end
                 if (  player_x === hostage_x [2] &&  player_y === hostage_y[2]  )
                    begin
                        count_2_hostage = count_2_hostage + 1 ;
                    end
                 if (  player_x === hostage_x [3] &&  player_y === hostage_y[3]  )
                    begin
                        count_3_hostage = count_3_hostage + 1 ;
                    end
            end         

end endtask

always@(*)
begin
    if (out!==0  && out_valid2=== 0)
        begin
            $display ("                      SPEC 4 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
end 

always@(*)
begin
	if (out_valid1===1  && in_valid2=== 1)
        begin
            $display ("                      SPEC 5 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
	if (out_valid2===1  && in_valid2=== 1)
        begin
            $display ("                      SPEC 5 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
	if (out_valid1===1  && in_valid1=== 1)
        begin
            $display ("                      SPEC 5 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
	if (out_valid2===1  && in_valid1=== 1)
        begin
            $display ("                      SPEC 5 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
	if (out_valid1===1  && out_valid2=== 1)
        begin
            $display ("                      SPEC 5 IS FAIL!                       ");
            repeat(2)@(negedge clk);
            $finish;
        end
end

task wait_out_valid; begin
	cycles = 0;
	while(out_valid1 !==1 )begin
		 while (out_valid2 === 0 )
		     begin
		          
		          if (out_valid1===1)
		              begin
                            $display ("                      SPEC 9 IS FAIL!                       ");
                            repeat(2)@(negedge clk);
                            $finish;
		              end
				  if(cycles == 3000) begin
						$display ("                       SPEC 6 IS FAIL!                  ");
						repeat(2)@(negedge clk);
						$finish;
					  end
				cycles = cycles +1 ;
		         @(negedge clk) ; 
		     end
		 while (out_valid2===1)
		      begin
		          check_out; 
				  if(cycles == 3000) begin
						$display ("                                  SPEC 6 IS FAIL!                        ");
						repeat(2)@(negedge clk);
						$finish;
					 end
					 
		          cycles = cycles + 1 ;
		          @(negedge clk) ; 
		           
		      end
		      
		if ( hostage_saved < hostage_number  )
              begin
                  check_hostage_location ; 
                  password_given;
                  hostage_saved = hostage_saved+1 ; 
				  cycles = cycles +1 ;
              end
		else
		  begin
            check_exit_location ; 
			gen_golden_password ; 
            cycles = cycles +1  ;
          end
		if(cycles == 3000) begin
			$display ("                                  SPEC 6 IS FAIL!                        ");
			repeat(2)@(negedge clk);
			$finish;
		 end
	@(negedge clk);
	
	while(out_valid1 !== 1  && hostage_saved === hostage_number  && out_valid2 ===0 )
		begin 
			cycles = cycles +1 ;
			@(negedge clk) ;
                if(cycles == 3000) begin
                    $display ("                       SPEC 6 IS FAIL!                  ");
                    repeat(2)@(negedge clk);
                    $finish;
                  end
		end
	end
	total_cycles = total_cycles + cycles;
end endtask

//task check_ans; begin
//	for (i=0; i<5; i=i+1) f = $fscanf(output_file, "%d", golden_result[i]);
//	g = $fscanf(output_file, "%d", golden_value);
//	golden_step = 0;
//	while (out_valid === 1) begin
//		if ( result !== golden_result[ golden_step ] ) begin
//			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//			$display ("                                                                        FAIL!                                                               ");
//			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
//			$display ("                                                              Your output -> result: %d                                                     ", result);
//			$display ("                                                            Golden output -> result: %d, step: %d                                           ", golden_result[golden_step], golden_step+1);
//			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//			@(negedge clk);
//			$finish;
//		end
//		if (golden_step == 4 && out_value !== golden_value) begin
//			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//			$display ("                                                                        FAIL!                                                               ");
//			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
//			$display ("                                                              Your output -> out_value: %d                                                  ", out_value);
//			$display ("                                                            Golden output -> out_value: %d                                                  ", golden_value);
//			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//			@(negedge clk);
//			$finish;
//		end
//		@(negedge clk);
//		golden_step=golden_step+1;
//	end
//	if(golden_step !== 5) begin
//		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//		$display ("                                                                        FAIL!                                                               ");
//		$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
//		$display ("	                                                          Output cycle should be 5 cycles                                                  ");
//		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
//		@(negedge clk);
//		$finish;
//	end
//end endtask

task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						                 ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask


endmodule