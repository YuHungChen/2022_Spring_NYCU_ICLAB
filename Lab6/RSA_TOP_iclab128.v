//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_TOP.v
//   Module Name : RSA_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "RSA_IP.v"
//synopsys translate_on

module RSA_TOP (
    // Input signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Output signals
    out_valid, out_m
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_p, in_q;
input [7:0] in_e, in_c;
output reg out_valid;
output reg [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter WIDTH = 4 ;

parameter ST_IN = 0 ;
parameter ST_OUT = 1 ;  

reg current_state  ;
reg next_state  ;
//================================================================
// Wire & Reg Declaration
//================================================================


//================================================================
// DESIGN
//================================================================
reg  [WIDTH*2-1:0] c_text , c_wait_1 ;
reg  [WIDTH-1  :0] get_p, get_q ;
reg  [WIDTH*2-1:0] get_e ;
reg  [WIDTH*2-1:0] decrypted_text  ;
reg  [WIDTH*2-1:0] decrypted_text_wait_1  ;


wire [WIDTH*2-1:0] OUT_D, OUT_N ;
reg  [WIDTH*2-1:0] private_D , private_N ;
reg  [2:0] count_number ;
reg  [2:0] count_out ; 

integer i  ;
reg count_1 ;
always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)
		begin
			count_1 <= 'd0 ;
		end
	else if (current_state == ST_IN)
		begin
			if (in_valid) begin
				if(count_1 !=1) 
					count_1 <= count_1 + 'd1 ;
			end
		end
	else
		count_1 <= 'd0 ;
end	

reg [2:0] count_8 ;
always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)
		begin
			count_8 <= 'd0 ;
		end
	else if (current_state == ST_IN)
		begin
			if (in_valid) begin
				count_8 <= count_8 + 'd1 ;
			end
		end
	else if (current_state == ST_OUT)
		begin
			count_8 <= count_8 + 'd1 ;
		end
	else
		count_8 <= 'd0 ;
end

always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)
		begin
			get_e <='d0;
			get_p <='d0;
			get_q <='d0;
		end
	else 
		begin
			if (count_1 == 0)
				begin
					get_e <= in_e ;
					get_p <= in_p ;
					get_q <= in_q ;
				end
		end	
end


always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)
		begin
			// for (i=0 ; i<=7; i=i+1)
				c_text <= 'd0;
		end
	else if (current_state == ST_IN)
		begin
			if(in_valid ) 
				c_text <= in_c;
		end

end


always@ (posedge clk , negedge rst_n )begin
	if (!rst_n )begin
		c_wait_1 <= 'd0 ;
	end else begin
		c_wait_1 <= c_text ;
	end
end

always@(posedge clk, negedge rst_n)
begin
	if(!rst_n)begin
			private_D <= 'd0;
			private_N <= 'd0;
	end
	else if (current_state == ST_IN)begin
			if (count_1 == 1)begin
				private_D <= OUT_D;
				private_N <= OUT_N;
			end
	end
end

RSA_IP #(.WIDTH(WIDTH)) U0 ( .IN_P(get_p) , .IN_Q(get_q) , .IN_E(get_e) , .OUT_N (OUT_N) , .OUT_D (OUT_D) )  ; 


//  ===========   Compute m =============
// c^d  % N  = m % N  , m < N
wire [WIDTH*2-1:0] a0 , a1  ;
wire [WIDTH*4-1:0] a0_square ;
assign a0 = c_wait_1 % private_N ;	//  c% N 
assign a0_square = a0*a0 ;  
assign a1 = (a0_square)  % private_N ;	//  (c% N) ^2   


//  pipeline_zero (store  a0, tmp0)
reg [WIDTH*2-1:0] pipe_a0 , pipe_a1 ;
always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_a0    <= 'd0 ;
		pipe_a1    <= 'd0 ;
	 //	in_valid_1 <= 'd0 ; 
	end else begin
		pipe_a0 <= a0 ;
		pipe_a1 <= a1 ;
	end
end

wire [WIDTH*2-1:0] a0_a1_value ; 
reg [WIDTH*2-1:0] tmp_1_to_2 ;
wire [WIDTH*2-1:0] a2, a3 ;

wire [WIDTH*4-1:0] pipe_a1_square  ;
wire [WIDTH*4-1:0] a2_square   ;
wire [WIDTH*4-1:0] pipe_a0_mult_a1 ;


assign pipe_a1_square  = (pipe_a1 * pipe_a1) ;
assign pipe_a0_mult_a1 = (pipe_a0 * pipe_a1) ; 
assign a2_square   = (a2      * a2 ) ; 

assign a0_a1_value = (pipe_a0_mult_a1  ) % private_N ; 
assign a2          = (pipe_a1_square   ) % private_N ;
assign a3      = (a2_square    ) % private_N ; 


always@(*)begin
	if (private_D[0] == 1  && private_D[1] == 1)begin
		tmp_1_to_2 = a0_a1_value ;
	end else if (private_D[0] == 1  && private_D[1] == 0)begin
		tmp_1_to_2 = pipe_a0 ;
	end else if (private_D[0] == 0  && private_D[1] == 1)begin
		tmp_1_to_2 = pipe_a1 ;
	end else begin  // 0 0 
		tmp_1_to_2 = 0 ;
	end
end

//  pipeline_one (store  a1, tmp1)
reg [WIDTH*2-1:0] pipe_a3 , pipe_tmp1 , pipe_a2;

always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_a3    <= 'd0 ;
		pipe_tmp1  <= 'd0 ;
		pipe_a2    <= 'd0 ;
	end else begin
		pipe_tmp1  <= tmp_1_to_2 ;
		pipe_a3    <= a3 ;
		pipe_a2    <= a2 ; 
	end
end

reg [WIDTH*2-1:0] tmp_2_to_3 ;
wire [WIDTH*2-1:0] a4, a5 ;

wire [WIDTH*4-1:0] pipe_a3_square  ;
wire [WIDTH*4-1:0] tmp_a4_square   ;

assign pipe_a3_square  = (pipe_a3 * pipe_a3 ) ;
assign tmp_a4_square   = (a4  * a4  ) ;

assign a4 = (pipe_a3_square )%private_N ; 
assign a5 = (tmp_a4_square  )%private_N ;

wire [WIDTH*4-1:0] pipe_a2_a3 ;
assign pipe_a2_a3 = pipe_a2 * pipe_a3 ; 
wire [WIDTH*2-1:0] a2_a3_value ;
assign a2_a3_value = pipe_a2_a3% private_N ; 

always@(*)begin
	if (private_D[2] == 1  && private_D[3] == 1)begin
		tmp_2_to_3 = a2_a3_value ;
	end else if (private_D[2] == 1  && private_D[3] == 0)begin
		tmp_2_to_3 = pipe_a2 ;
	end else if (private_D[2] == 0  && private_D[3] == 1)begin
		tmp_2_to_3 = pipe_a3 ;
	end else begin  // 0 0 
		tmp_2_to_3 = 0 ;
	end
end


//  pipeline_two (store  a2, tmp2)
reg [WIDTH*2-1:0] pipe_a5 , pipe_tmp2_0 , pipe_a4 , pipe_tmp2_1 ;
reg in_valid_3 ; 
always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_a5        <= 'd0 ;
		pipe_a4        <= 'd0 ;
		pipe_tmp2_0    <= 'd0 ;
		pipe_tmp2_1    <= 'd0 ;
	end else begin
		pipe_a5      <= a5 ;
		pipe_a4      <= a4 ;
		pipe_tmp2_0  <= pipe_tmp1 ; 
		pipe_tmp2_1  <= tmp_2_to_3 ; 
	end
end

reg [WIDTH*2-1:0] tmp_3_to_4_0 , tmp_3_to_4_1 ;
wire [WIDTH*2-1:0] a6 ;

wire [WIDTH*4-1:0] pipe_a5_square ;

assign pipe_a5_square = (pipe_a5 * pipe_a5 ) ;

assign a6     = (pipe_a5_square)%private_N ; 

wire [WIDTH*4-1:0] pipe_a4_a5 ;
assign pipe_a4_a5  = pipe_a4 * pipe_a5 ; 
wire [WIDTH*2-1:0] a4_a5_value ;
assign a4_a5_value = pipe_a4_a5 % private_N ; 
wire [WIDTH*4-1:0] pipe_tmp0_tmp1 ;
assign pipe_tmp0_tmp1 = pipe_tmp2_0 * pipe_tmp2_1 ; 
wire [WIDTH*2-1:0] tmp0_tmp1_value ;
assign tmp0_tmp1_value = pipe_tmp0_tmp1 % private_N ; 

always@(*)begin   //  4 5 
	if (private_D[4] == 1  && private_D[5] == 1)begin
		tmp_3_to_4_0 = a4_a5_value ;
	end else if (private_D[4] == 1  && private_D[5] == 0)begin
		tmp_3_to_4_0 = pipe_a4 ;
	end else if (private_D[4] == 0  && private_D[5] == 1)begin
		tmp_3_to_4_0 = pipe_a5 ;
	end else begin  // 0 0 
		tmp_3_to_4_0 = 0 ;
	end
end

always@(*)begin
	if (pipe_tmp2_0 == 0  && pipe_tmp2_1 == 0)begin
		tmp_3_to_4_1 = 0 ;
	end else if (pipe_tmp2_0 == 0 ) begin
		tmp_3_to_4_1 = pipe_tmp2_1 ;
	end else if (pipe_tmp2_1 == 0)begin
		tmp_3_to_4_1 = pipe_tmp2_0 ;
	end else begin  
		tmp_3_to_4_1 = tmp0_tmp1_value ;
	end
end

//  pipeline_three

reg [WIDTH*2-1:0] pipe_a6 , pipe_tmp3_0 , pipe_tmp3_1 ;
// reg in_valid_4 ; 
always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_a6	     <= 'd0 ;
		pipe_tmp3_0  <= 'd0 ;
	 	pipe_tmp3_1  <= 'd0 ; 
	end else begin
		pipe_a6	      <= a6 ;
		pipe_tmp3_0   <= tmp_3_to_4_0 ; 
		pipe_tmp3_1   <= tmp_3_to_4_1 ; 
	end
end

reg [WIDTH*2-1:0] tmp_4_to_5 ; 
wire [WIDTH*4-1:0] pipe_tmp3_0_tmp3_1 ;
assign pipe_tmp3_0_tmp3_1 = pipe_tmp3_0 * pipe_tmp3_1 ;
wire [WIDTH*2-1:0] tmp3_0_tmp3_1_value ;
assign  tmp3_0_tmp3_1_value = pipe_tmp3_0_tmp3_1 % private_N ; 


always@(*)begin
	if (pipe_tmp3_0 == 0  && pipe_tmp3_1 == 0)begin
		tmp_4_to_5 = 0 ;
	end else if (pipe_tmp3_0 == 0 ) begin
		tmp_4_to_5 = pipe_tmp3_1 ;
	end else if (pipe_tmp3_1 == 0)begin
		tmp_4_to_5 = pipe_tmp3_0 ;
	end else begin  
		tmp_4_to_5 = tmp3_0_tmp3_1_value ;
	end
end

//  pipeline_five 
reg [WIDTH*2-1:0] pipe_tmp5_0, pipe_tmp5_1 ;

always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_tmp5_0 <= 'd0 ;
		pipe_tmp5_1 <= 'd0 ;
	end else begin
		pipe_tmp5_0 <= pipe_a6 ;
		pipe_tmp5_1 <= tmp_4_to_5 ; 
	end
end

reg [WIDTH*2-1:0] tmp_5_to_6 ; 
wire [WIDTH*4-1:0] pipe_tmp5_0_tmp5_1 ;
assign pipe_tmp5_0_tmp5_1 = pipe_tmp5_0 * pipe_tmp5_1 ;
wire [WIDTH*2-1:0] tmp5_0_tmp5_1_value ;
assign tmp5_0_tmp5_1_value = pipe_tmp5_0_tmp5_1 % private_N ; 

always@(*)begin
	if (private_D[6] == 0  && pipe_tmp5_1 == 0)begin
		tmp_5_to_6 = 0 ;
	end else if (private_D[6] == 0 ) begin
		tmp_5_to_6 = pipe_tmp5_1 ;
	end else if (pipe_tmp5_1 == 0)begin
		tmp_5_to_6 = pipe_tmp5_0 ;
	end else begin  
		tmp_5_to_6 = tmp5_0_tmp5_1_value ;
	end
end





//  ==============   pipeline_pre_out =================
always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		decrypted_text <= 'd0 ;
	end else begin
		decrypted_text <= tmp_5_to_6 ; 
	end
end

//  pipeline_five (store  decrypted_text_1 )
// always@(posedge clk , negedge rst_n)begin
	// if (!rst_n)begin
			// decrypted_text_wait_1 <= 'd0 ;
	// end else begin
			// decrypted_text_wait_1 <= decrypted_text ; 
	// end
// end

//  ============   pipe_line output ========================
always@(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		begin
			out_valid <= 'd0; 
			out_m     <= 'd0; 
		end
	else if (current_state == ST_OUT)
		begin
			out_valid <= 'd1 ;
			out_m	  <= decrypted_text ;
		end
	else 
		begin
			out_valid <= 'd0 ;
			out_m	  <= 'd0 ;
		end
end

// ============ finite state machine ======
always@ (posedge clk , negedge rst_n)
begin
	if (!rst_n ) begin
		current_state <= ST_IN ;
	end else begin
		current_state <= next_state ;
	end
end

always@(*)begin
	case(current_state)
		ST_IN : begin
				if (count_8 == 7 )
					next_state = ST_OUT ; 
				else 
					next_state = ST_IN ; 
		end
		
		ST_OUT : begin
				if (count_8 == 7)
					next_state = ST_IN ;
				else 
					next_state = ST_OUT ; 
		end
		
		default : next_state = ST_IN ; 
	endcase
end



endmodule