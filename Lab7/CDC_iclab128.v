`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Output Port
	ready,
    out_valid,
	out_account
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------

input 				rst_n, clk1, clk2, in_valid;
input [DSIZE-1:0] 	in_account,in_A,in_T;

output reg				out_valid,ready;
output reg [DSIZE-1:0] 	out_account;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
// reg [DSIZE-1:0] in_A_data ,  in_account_data , in_T_data ; 

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

integer i ;
//  =========account AFIFO ================= 
wire [7:0] rdata_account ;
wire rempty_account ; 

reg  winc_account ;
reg  [7:0] wdata_account ;
wire wfull_account ; 

reg [7:0] past_five_account [0:3] ; 
//  =========account AFIFO =================
//  =========IN_A AFIFO =================
// reg  rinc_IN_A ; 
wire [7:0] rdata_IN_A ;
wire rempty_IN_A ; 

reg  winc_IN_A ;
reg  [7:0] wdata_IN_A ;
wire wfull_IN_A ; 

// reg [7:0] IN_A_data_clk2 [0:4] ; 
//  =========IN_A AFIFO =================
//  =========IN_T AFIFO =================
// reg  rinc_IN_T ; 
wire [7:0] rdata_IN_T ;
wire rempty_IN_T ; 

reg  winc_IN_T ;
reg  [7:0] wdata_IN_T ;
wire wfull_IN_T ; 

// reg [7:0] IN_T_data_clk2 [0:4] ; 
//  =========IN_T AFIFO =================
// =========general purpose=========
reg [2:0] count_read ; 
reg five_flag; 
reg five_flag_delay1 ; 
reg valid_flag ; 
reg valid_flag_pipe_2 ;
wire  rinc_account_clk2 ;
wire  rinc_IN_A_clk2    ;
wire  rinc_IN_T_clk2    ;
reg  [15:0] past_five_performance [0:3] ; 
wire [15:0] current_performance ; 
reg wfull_flag ; 

reg [7:0] tmp_A , tmp_T , tmp_Account ; 

assign current_performance = rdata_IN_A * rdata_IN_T ; 

reg [2:0] one,two,three,four,five; 
reg full_before ; 
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------


// ==================================Input===============================================================
always@(posedge clk1 , negedge rst_n)begin
	if(!rst_n)begin
		wdata_IN_A    <= 'd0 ;
		wdata_IN_T    <= 'd0 ;
		wdata_account <= 'd0 ;
	end else if (in_valid ) begin
		wdata_IN_A    <= in_A ; 
		wdata_IN_T    <= in_T ;
		wdata_account <= in_account ;
	end
end


always@(*)begin
	if(!rst_n) begin
		ready = 'd0 ;
	end else if (wfull_account) begin
		ready = 'd0 ;
	end else begin
		ready = 'd1 ;
	end
end


always@(posedge clk1 , negedge rst_n)begin
	if(!rst_n) begin
		winc_IN_A <= 'd0 ;
		winc_IN_T <= 'd0 ;
		winc_account <= 'd0 ;
	end else if ( in_valid || (wfull_account&& winc_account) ) begin
		winc_IN_A <= 'd1 ;
		winc_IN_T <= 'd1 ;
		winc_account <= 'd1 ;
	end else begin
		winc_IN_A <= 'd0 ;
		winc_IN_T <= 'd0 ;
		winc_account <= 'd0 ;
	end
end




// ===================================================================================================


always@(posedge clk2 ,negedge rst_n)begin
	if(!rst_n) begin
		count_read <= 'd0 ;
	end else if (rinc_account_clk2)begin
		if (count_read == 'd4)
			count_read <= 'd0 ;
		else
			count_read <= count_read + 'd1 ;
	end
end



//  if one pattern only , need not to reset signal
always@(posedge clk2 ,negedge rst_n)begin
	if(!rst_n) begin
		five_flag <= 'd0 ;
	end else if (count_read == 'd4 && !rempty_account)begin
		five_flag <= 'd1 ;
	end
end


always@(posedge clk2 ,negedge rst_n)begin
	if(!rst_n) begin
		valid_flag <= 'd0 ;
	end else if (!rempty_account) begin
		valid_flag <= 'd1 ;
	end else begin
		valid_flag <= 'd0 ;
	end
end


assign rinc_account_clk2 = ~rempty_account ; 
assign rinc_IN_A_clk2    = ~rempty_IN_A    ;
assign rinc_IN_T_clk2    = ~rempty_IN_T    ; 


always@(posedge clk2 , negedge rst_n )begin
	if(!rst_n) begin
		for(i=0 ; i<=3 ; i=i+1)
			past_five_performance[i] <= 'd0 ;
	end else if (!rempty_account) begin
		past_five_performance[0] <= current_performance ; 
		past_five_performance[1] <= past_five_performance[0] ; 
		past_five_performance[2] <= past_five_performance[1] ; 
		past_five_performance[3] <= past_five_performance[2] ; 
	end
end



always@(posedge clk2 ,negedge rst_n) begin
	if (!rst_n) begin
		for (i=0 ; i<=3 ; i=i+1)
			past_five_account[i] <= 'd0 ;
	end else if (!rempty_account)begin
		past_five_account[0] <=  rdata_account ; 
		past_five_account[1] <=  past_five_account[0] ; 
		past_five_account[2] <=  past_five_account[1] ; 
		past_five_account[3] <=  past_five_account[2] ; 
	end
end

wire [15:0] big_1_perf    , big_2_perf    , big_3_perf ; 
wire [7:0 ] big_1_account , big_2_account , big_3_account;  

wire [7:0 ]max_perf_account ; 

comparator U1(
    .performance_A(past_five_performance[0]),
    .performance_B(past_five_performance[1]),
    .in_account_A(past_five_account     [0]),
	.in_account_B(past_five_account     [1]),
    .out_big(big_1_perf),
    .out_account(big_1_account)
    );

comparator U2(
    .performance_A(past_five_performance[2]),
    .performance_B(past_five_performance[3]),
    .in_account_A(past_five_account     [2]),
	.in_account_B(past_five_account     [3]),
    .out_big(big_2_perf),
    .out_account(big_2_account)
    );
	
comparator U3(
    .performance_A(big_1_perf),
    .performance_B(big_2_perf),
    .in_account_A(big_1_account),
	.in_account_B(big_2_account),
    .out_big(big_3_perf),
    .out_account(big_3_account)
    );


assign max_perf_account = (current_performance <=  big_3_perf )?  rdata_account : big_3_account ; 

reg [7:0] best_account ; 
always@(posedge clk2 , negedge rst_n)begin
	if(!rst_n) begin
		best_account <= 'd0 ;
	end else if (!rempty_account) begin
		best_account <= max_perf_account ; 
	end
end



always@(posedge clk2 , negedge rst_n )begin
	if(!rst_n) begin
		out_valid   <= 'd0 ;
		out_account <= 'd0 ;
	end else if (valid_flag) begin
		if (five_flag )begin
			out_valid   <=  'd1; 
			out_account <=  best_account ; 
		end else begin
			out_valid   <= 'd0 ;
			out_account <= 'd0 ;
		end
	end else begin
		out_valid   <= 'd0 ;
		out_account <= 'd0 ;
	end
end




AFIFO u_AFIFO_1(
    .rclk(clk2),
    .rinc(rinc_account_clk2),
    .rempty(rempty_account),
	.wclk(clk1),
    .winc(winc_account),
    .wfull(wfull_account),
    .rst_n(rst_n),
    .rdata(rdata_account),
    .wdata(wdata_account)
    );
	
AFIFO u_AFIFO_2(
    .rclk(clk2),
    .rinc(rinc_IN_A_clk2),
    .rempty(rempty_IN_A),
	.wclk(clk1),
    .winc(winc_IN_A),
    .wfull(wfull_IN_A),
    .rst_n(rst_n),
    .rdata(rdata_IN_A),
    .wdata(wdata_IN_A)
    );
	
AFIFO u_AFIFO_3(
    .rclk(clk2),
    .rinc(rinc_IN_T_clk2),
    .rempty(rempty_IN_T),
	.wclk(clk1),
    .winc(winc_IN_T),
    .wfull(wfull_IN_T),
    .rst_n(rst_n),
    .rdata(rdata_IN_T),
    .wdata(wdata_IN_T)
    );

	
endmodule



module comparator (performance_A , performance_B , in_account_A , in_account_B ,  out_big , out_account );

input [15:0] performance_A , performance_B ;
input [7 :0] in_account_A  , in_account_B ; 

output [15:0] out_big  ; 
output [7:0]out_account  ; 

assign  out_big     = ( performance_A <= performance_B ) ?   performance_A : performance_B ; 
assign  out_account = ( performance_A <= performance_B ) ?   in_account_A  : in_account_B  ; 



endmodule