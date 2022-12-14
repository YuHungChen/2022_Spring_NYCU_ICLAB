//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Final Proejct              : TOF  
//   Author                     : Wen-Yue, Lin
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-5)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TOF(
    // CHIP IO
    clk,
    rst_n,
    in_valid,
    start,
    stop,
    inputtype,
    frame_id,
    busy,

    // AXI4 IO
    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,
    arready_m_inf,
    
    rid_m_inf,
    rdata_m_inf,
    rresp_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf,

    awid_m_inf,
    awaddr_m_inf,
    awsize_m_inf,
    awburst_m_inf,
    awlen_m_inf,
    awvalid_m_inf,
    awready_m_inf,

    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,
    
    bid_m_inf,
    bresp_m_inf,
    bvalid_m_inf,
    bready_m_inf 
);
// ===============================================================
//                      Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter


// ===============================================================
//                      Input / Output 
// ===============================================================

// << CHIP io port with system >>
input           clk, rst_n;
input           in_valid;
input           start;
input [15:0]    stop;     
input [1:0]     inputtype; 
input [4:0]     frame_id;
output reg      busy;       

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
    Your AXI-4 interface could be designed as a bridge in submodule,
    therefore I declared output of AXI as wire.  
    Ex: AXI4_interface AXI4_INF(...);
*/

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)    axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)    axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1)     axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)    axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)    axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------

parameter ST_IN = 'd0 ;
parameter ST_BUSY = 'd1 ;
parameter ST_WRITE = 'd2 ;
parameter ST_READ  = 'd3 ; 
parameter ST_IDLE = 'd4 ; // not sure about that // maybe delay input 
parameter ST_SORTING = 'd5 ; 

integer i,j ; 
genvar k ; 
// DRAM_WRITE_addr ; 
reg [7:0] Write_length ; 
reg Write_addr_valid ; 
reg [ADDR_WIDTH-1:0] Write_address ; 

assign awid_m_inf = 4'd0 ; 
assign awburst_m_inf = 2'b01 ;  // Burst type   //  2'b01 = INCR  in this project
							    // details how the address of each transfer within the burst
assign awsize_m_inf = 3'b100 ;	// Burst size ;
			// 16 byted matched with  (Data-bus width)   in each transfer.			
assign awlen_m_inf   = Write_length ;
assign awvalid_m_inf = Write_addr_valid ;
assign awaddr_m_inf  = Write_address ; 

// DRAM_WRITE_data ; 
reg Write_data_valid ; 
reg Write_last ; 
reg [DATA_WIDTH-1:0] Write_data    ;

assign wvalid_m_inf = Write_data_valid ; 
assign wdata_m_inf = Write_data ; 
assign wlast_m_inf = Write_last ; 	

// Write_response ; 
assign bready_m_inf = 1'd1 ;  // can assign 1  ?  


// Read_ADDR
reg  [ADDR_WIDTH-1:0] Read_address ; 
reg  Read_addr_valid ; 

assign    arid_m_inf    = 4'd0 ; 
assign    arburst_m_inf = 2'b01  ; // Burst type   //  2'b01 = INCR  in this project
assign    arsize_m_inf  = 3'b100 ;  // Read  Burst size ;   // 4 byted matched with  (Data-bus width)   in each transfer.   ? 16 byted ? 
assign 	  arlen_m_inf   = 8'd255 ;
assign    araddr_m_inf  = Read_address ; 
assign    arvalid_m_inf = Read_addr_valid ; 

// Read_DATA
reg Read_data_ready ; 
assign rready_m_inf = Read_data_ready ; 




// design register
reg [1:0] now_type; 
reg [4:0] frame_id_data ; 
// reg [3:0] count_write_number ;

reg [3:0] histograms [0:15][0:15] ;   // 4 bits for max_value in type 1 = 15 ; 
			// to store the 16 numbers of value for each histograms ; 
			// first ==> to change the sorting 
reg [2:0] current_state , next_state ; 

reg [3:0] count_16 ; 
reg [3:0] count_hist ; 
reg count_hist_16_flag ;

//SRAM
wire  wen [0:1]; 
wire [47:0] SRAM_Read[0:1] ; 
wire [47:0] SRAM_Data[0:1] ; 
reg  [7:0 ] count_addr[0:1] ;
reg one_cycle_delay ; 
reg SRAM_READ_DELAY ; 
reg write_now ; 				
reg read_now ; 

//  start_number for each type 
wire [2:0] start_number ; 

wire [3:0] lower_bit ; 
assign lower_bit = frame_id_data - 'd16 ; 

wire write_finish ; 
assign write_finish = (count_hist == 'd15 && bvalid_m_inf) ?  1 : 0 ; 

// always block   for DRAM 
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		Write_length <= 'd0 ; 
	end else if (now_type == 'd0 ) begin
		Write_length <= 'd0 ; 
	end else begin
		Write_length <= 'd255 ;   //  Write every bins at once  
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		Write_addr_valid <= 'd0 ;
	end else if (Write_addr_valid & awready_m_inf) begin
		Write_addr_valid <= 'd0 ;
	end else if (current_state == ST_BUSY ) begin
		Write_addr_valid <= 'd1 ;	
	end else if (now_type == 'd0 )begin
		if (bvalid_m_inf)begin
			if (count_hist == 'd15)begin
				Write_addr_valid <= 'd0 ;
			end else begin
				Write_addr_valid <= 'd1 ; 
			end
		end
	end
end

// always@(posedge clk, negedge rst_n)begin
	// if(!rst_n)begin
		// count_write_number <= 'd0 ;
	// end else if (bvalid_m_inf) begin
		// count_write_number <= count_write_number + 'd1 ; 
	// end
// end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Write_address <= 128'd0 ;
	end else if (now_type == 'd0 ) begin
		if (frame_id_data > 'd15) begin
				Write_address <= {108'b0 , 4'd2 , lower_bit , count_hist , 4'hf , 4'b0} ;
				
		end else begin
				Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , count_hist , 4'hf , 4'b0} ;

		end
	end else begin 
		if (frame_id_data > 'd15) begin
			Write_address <= {108'b0 , 4'd2 , lower_bit , 12'b0} ;
		end else begin
			Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 12'b0} ;
		end
	end
end


reg [3:0] current_hist , current_16_bins_set ;
reg start_sorting_flag ; 
reg change_row ; 
wire [7:0] max_distance_two_type ; 
reg start_count_flag ; 
reg start_window_flag ; 

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		Write_data_valid <= 'd0 ;
	end else if (current_state == ST_READ)begin
		if (count_16 == 'd6  && start_window_flag )begin
			Write_data_valid <= 'd1 ; 
		end else if (count_16 == 'd9)begin
			Write_data_valid <= 'd0 ;
		end
	// end else if ( (count_hist =='d2 || count_hist=='d3) && (count_16 == 'd0 ) )begin
		// Write_data_valid <= 'd1 ; 
	// end else if (count_hist == 'd15 && current_state == ST_WRITE ) begin
		// Write_data_valid <= 'd1 ; 
	end else if (current_state == ST_WRITE )begin
		Write_data_valid <= 'd1 ; 
	end else begin
		Write_data_valid <= 'd0 ;  
	end
end

reg [7:0] last_value; 
reg [7:0] max_dist_four[0:3] ; 

wire [3:0] remainder ;
assign remainder = count_addr[write_now] % 'd16 ; 
always@(*)begin
	
	if (remainder == 'd14)begin
		case (count_16)
		 4'd0  : last_value = max_dist_four[0] ;
		 4'd1  : last_value = max_dist_four[0] ;
		 4'd2  : last_value = max_dist_four[1] ;
		 4'd3  : last_value = max_dist_four[1] ;
		 4'd4  : last_value = max_dist_four[0] ;
		 4'd5  : last_value = max_dist_four[0] ;
		 4'd6  : last_value = max_dist_four[1] ;
		 4'd7  : last_value = max_dist_four[1] ;
		 4'd8  : last_value = max_dist_four[2] ;
		 4'd9  : last_value = max_dist_four[2] ;
		 4'd10 : last_value = max_dist_four[3] ;
		 4'd11 : last_value = max_dist_four[3] ;
		 4'd12 : last_value = max_dist_four[2] ;
		 4'd13 : last_value = max_dist_four[2] ;
		 4'd14 : last_value = max_dist_four[3] ;
		 4'd15 : last_value = max_dist_four[3] ;
		
		endcase
	// end else if (change_row) begin
		// last_value = histograms[15][0] ;
	end else begin
		last_value = histograms[0][15] ;
	end
end

wire [7:0] histogram_8bit[0:14] ;
assign histogram_8bit[0 ] =  {4'b0 , histograms[0][ 0]}  ; 
assign histogram_8bit[1 ] =  {4'b0 , histograms[0][ 1]}  ; 
assign histogram_8bit[2 ] =  {4'b0 , histograms[0][ 2]}  ; 
assign histogram_8bit[3 ] =  {4'b0 , histograms[0][ 3]}  ; 
assign histogram_8bit[4 ] =  {4'b0 , histograms[0][ 4]}  ; 
assign histogram_8bit[5 ] =  {4'b0 , histograms[0][ 5]}  ; 
assign histogram_8bit[6 ] =  {4'b0 , histograms[0][ 6]}  ; 
assign histogram_8bit[7 ] =  {4'b0 , histograms[0][ 7]}  ; 
assign histogram_8bit[8 ] =  {4'b0 , histograms[0][ 8]}  ; 
assign histogram_8bit[9 ] =  {4'b0 , histograms[0][ 9]}  ; 
assign histogram_8bit[10] =  {4'b0 , histograms[0][10]}  ; 
assign histogram_8bit[11] =  {4'b0 , histograms[0][11]}  ; 
assign histogram_8bit[12] =  {4'b0 , histograms[0][12]}  ; 
assign histogram_8bit[13] =  {4'b0 , histograms[0][13]}  ; 
assign histogram_8bit[14] =  {4'b0 , histograms[0][14]}  ; 

wire [3:0] input_DRAM_value[0:15] ;
reg [3:0] store_DRAM_value[0:14] ; 

wire [7:0] store_value_8bit [0:14] ;
assign store_value_8bit[0 ] =  {4'b0 , store_DRAM_value[ 0]}  ; 
assign store_value_8bit[1 ] =  {4'b0 , store_DRAM_value[ 1]}  ; 
assign store_value_8bit[2 ] =  {4'b0 , store_DRAM_value[ 2]}  ; 
assign store_value_8bit[3 ] =  {4'b0 , store_DRAM_value[ 3]}  ; 
assign store_value_8bit[4 ] =  {4'b0 , store_DRAM_value[ 4]}  ; 
assign store_value_8bit[5 ] =  {4'b0 , store_DRAM_value[ 5]}  ; 
assign store_value_8bit[6 ] =  {4'b0 , store_DRAM_value[ 6]}  ; 
assign store_value_8bit[7 ] =  {4'b0 , store_DRAM_value[ 7]}  ; 
assign store_value_8bit[8 ] =  {4'b0 , store_DRAM_value[ 8]}  ; 
assign store_value_8bit[9 ] =  {4'b0 , store_DRAM_value[ 9]}  ; 
assign store_value_8bit[10] =  {4'b0 , store_DRAM_value[10]}  ; 
assign store_value_8bit[11] =  {4'b0 , store_DRAM_value[11]}  ; 
assign store_value_8bit[12] =  {4'b0 , store_DRAM_value[12]}  ; 
assign store_value_8bit[13] =  {4'b0 , store_DRAM_value[13]}  ; 
assign store_value_8bit[14] =  {4'b0 , store_DRAM_value[14]}  ; 

// assign histogram_8bit[14] = (change_row)? {4'b0 , histograms[14][count_hist]} : {4'b0 , histograms[count_hist][14]}  ; 
always@(posedge clk, negedge rst_n)begin

	if(!rst_n)begin
		Write_data <= 'd0 ;
	end else if (current_state == ST_WRITE) begin
		Write_data <= {last_value, histogram_8bit[14], histogram_8bit[13], histogram_8bit[12], histogram_8bit[11], histogram_8bit[10], histogram_8bit[9], histogram_8bit[8], histogram_8bit[7], histogram_8bit[6], histogram_8bit[5], histogram_8bit[4], histogram_8bit[3], histogram_8bit[2], histogram_8bit[1], histogram_8bit[0] } ;

	end else if (current_state == ST_READ)begin
		Write_data <= {max_distance_two_type, store_value_8bit[14], store_value_8bit[13], store_value_8bit[12], store_value_8bit[11], store_value_8bit[10], store_value_8bit[9], store_value_8bit[8], store_value_8bit[7], store_value_8bit[6], store_value_8bit[5], store_value_8bit[4], store_value_8bit[3], store_value_8bit[2], store_value_8bit[1], store_value_8bit[0] } ;

	end
	
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		Write_last <= 'd0 ;
	end else if (current_state == ST_READ)begin
		// if (count_16 == 'd15)begin
			Write_last <= 'd1 ; 
		// end
	end else if ((current_state == ST_WRITE && count_addr[write_now]=='d254 )) begin
		Write_last <= 'd1 ; 
	end else begin
		Write_last <= 'd0 ;  
	end
end


// read_addr
reg [7:0] count_pipe ; 
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		Read_addr_valid <= 'd0 ;
	end else if (Read_addr_valid && arready_m_inf)begin
		Read_addr_valid <= 'd0 ; 
	end else if (current_state == ST_BUSY && now_type == 'd0) begin
		Read_addr_valid <= 'd1 ;  
	end
end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Read_address <= 128'd0;
	end else if (frame_id_data > 'd15) begin
		Read_address <= {108'b0 , 4'd2 , lower_bit , 12'b0} ;
	end else begin
		Read_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 12'b0} ;
	end
end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Read_data_ready <= 'd0;
	// end else if (count_16 == 'd15 )begin
		// Read_data_ready <= 'd0 ;
		
	end else if (rvalid_m_inf)begin  // maybe need to wait the last value
		Read_data_ready <= 'd1 ;
	end
end

// current_hist  // current_set ; 

// always@(posedge clk, negedge rst_n)begin
	// if(!rst_n)begin
		// current_16_bins_set  <= 'd0 ;
	// end else if (current_state == ST_READ)begin
		// if (Read_data_ready)begin
			// current_16_bins_set <= current_16_bins_set + 'd1 ;
		// end 
	// end
// end 

// always@(posedge clk, negedge rst_n)begin
	// if(!rst_n)begin
		// current_hist  <= 'd0 ;
	// end else if (current_state == ST_READ) begin
		// if (current_16_bins_set == 'd15 )begin
			// current_hist <= current_hist + 'd1 ;
		// end 
	// end
// end 

// always@(posedge clk, negedge rst_n)begin
	// if(!rst_n)begin
		// count_pipe  <= 'd0 ;
	// end else begin
		// if (current_16_bins_set == 'd15 && current_hist == 'd15)begin
			// count_pipe <= count_pipe + 'd1 ;
		// end 
	// end
// end 

// SRAM 	
// 48bit  (16 histograms * 3 bit) *256 word    // SRAM
RAM256 U_SRAM0 (.Q(SRAM_Read[0]),
				.CLK(clk),
				.CEN(1'b0),
				.WEN(wen[0]),
				.A(count_addr[0]),
				.D(SRAM_Data[0]),
				.OEN(1'b0)        );// 256 words  / 64 bit / 16 histograms

RAM256 U_SRAM1 (.Q(SRAM_Read[1]),
				.CLK(clk),
				.CEN(1'b0),
				.WEN(wen[1]),
				.A(count_addr[1]),
				.D(SRAM_Data[1]),
				.OEN(1'b0)        );// 256 words  / 64 bit / 16 histograms
				
reg [2:0] now_start_number ;  // the maximum_num is 7 ; 
reg [2:0] stored_value[0:15] ; 
// reg [2:0] read_value  [0:15] ; 


assign wen [0] = (write_now)? 1 : 0 ;
assign wen [1] = (read_now )? 1 : 0 ;

assign SRAM_Data[0] = {stored_value[15], stored_value[14], stored_value[13], stored_value[12], stored_value[11], stored_value[10], stored_value[9], stored_value[8], stored_value[7], stored_value[6], stored_value[5], stored_value[4], stored_value[3], stored_value[2], stored_value[1], stored_value[0] } ; 
assign SRAM_Data[1] = {stored_value[15], stored_value[14], stored_value[13], stored_value[12], stored_value[11], stored_value[10], stored_value[9], stored_value[8], stored_value[7], stored_value[6], stored_value[5], stored_value[4], stored_value[3], stored_value[2], stored_value[1], stored_value[0] } ; 

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		now_start_number <= 'd0 ;
	end else if (count_addr[write_now] == 'd254 && current_state == ST_IN ) begin
		if (now_start_number == start_number )
			now_start_number <= 'd0 ; 
		else
			now_start_number <= now_start_number +'d1 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		change_row <= 'd0 ;
	end else if (count_hist == 'd15 && current_state == ST_SORTING) begin
		change_row <= !change_row ; 
	end else if (current_state == ST_WRITE)begin
		change_row <= 'd0 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		count_addr[0] <= 'd0 ;    // write SRAM1   
		count_addr[1] <= 'd0 ;    // READ  SRAM2
	end else if (one_cycle_delay && current_state == ST_IN) begin   // for in_valid
		if (count_addr[write_now] == 'd254 )begin
			count_addr[write_now] <= 'd0 ; 
			count_addr[read_now] <= 'd0 ; 
		end else begin
			count_addr[write_now] <= count_addr[write_now] + 'd1 ; 
			count_addr[read_now]  <= count_addr[read_now]  + 'd1 ; 
		end 
	end else if (one_cycle_delay && current_state == ST_SORTING )begin
		count_addr[read_now] <=  count_addr[read_now] + 'd1 ;
		if (count_hist == 'd0)begin
		count_addr[write_now] <= count_addr[write_now] + 'd17 ; 
		end else begin
		count_addr[write_now] <= count_addr[write_now] + 'd16 ; 
		end
		
	end else if (current_state == ST_BUSY)begin
		count_addr[write_now] <= 'd0 ;
	end else if (current_state == ST_WRITE)begin
		if (wready_m_inf)
			count_addr[write_now] <= count_addr[write_now] + 'd1 ;
		count_addr[read_now] <=  count_addr[read_now] + 'd1 ; 
	end else if (current_state == ST_IDLE)begin
		count_addr[read_now] <= 'd0 ;
	end else begin
		count_addr[read_now] <=  count_addr[read_now] + 'd1 ; 
	end
end
				

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		write_now <= 'd0 ;    // write SRAM1   
		read_now  <= 'd1 ;    // READ  SRAM2
	end else if ( (count_addr[write_now] == 'd254 && current_state == ST_IN) || (current_state == ST_BUSY && one_cycle_delay )   ) begin
		write_now <= read_now ; 
		read_now  <= write_now ;
	end
end

wire [2:0] histogram_for_sorting [0:15] ;
generate 
	for (k=0 ; k<=15 ; k=k+1)begin
		assign histogram_for_sorting[k] = (change_row)? histograms[k][count_hist] : histograms[count_hist][k] ; 
	end
endgenerate

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		for (i=0 ; i<= 15 ; i=i+1)begin
			stored_value[i] <= 'd0 ; 
		end
	end else if (now_start_number == 'd0 && in_valid && start) begin
		for (i=0 ; i<= 15 ; i=i+1)begin
			stored_value[i] <= stop[i]; 
		end
	end else if (in_valid && start)begin
		for (i=0 ; i<= 15 ; i=i+1)begin
			stored_value[i] <= histograms[count_16][i] + stop[i] ;   // not sure about this  
		end
	end else if (current_state == ST_SORTING)begin
		for (i=0 ; i<= 15 ; i=i+1)begin
			stored_value[i] <= histogram_for_sorting[i] ;
		end
	end
end




always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		for (i=0 ; i<= 15 ; i=i+1)begin
			store_DRAM_value[i] <= 'd0 ; 
		end
	end else if (count_16 == 'd15 ) begin
		store_DRAM_value[ 0] <= rdata_m_inf[  7:0   ] ;
		store_DRAM_value[ 1] <= rdata_m_inf[ 15:8   ] ;
		store_DRAM_value[ 2] <= rdata_m_inf[ 23:16  ] ;
		store_DRAM_value[ 3] <= rdata_m_inf[ 31:24  ] ;
		store_DRAM_value[ 4] <= rdata_m_inf[ 39:32  ] ;
		store_DRAM_value[ 5] <= rdata_m_inf[ 47:40  ] ;
		store_DRAM_value[ 6] <= rdata_m_inf[ 55:48  ] ;
		store_DRAM_value[ 7] <= rdata_m_inf[ 63:56  ] ;
		store_DRAM_value[ 8] <= rdata_m_inf[ 71:64  ] ;
		store_DRAM_value[ 9] <= rdata_m_inf[ 79:72  ] ;
		store_DRAM_value[10] <= rdata_m_inf[ 87:80  ] ;
		store_DRAM_value[11] <= rdata_m_inf[ 95:88  ] ;
		store_DRAM_value[12] <= rdata_m_inf[103:96  ] ;
		store_DRAM_value[13] <= rdata_m_inf[111:104 ] ;
		store_DRAM_value[14] <= rdata_m_inf[119:112 ] ;
		
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		for (i=0 ; i<=15 ; i=i+1)begin
			for (j=0 ; j<=7 ; j=j+1)begin
				histograms[i][j] <= 'd0 ; 
			end
		end
	end else if (change_row)begin
		histograms[15][count_hist] <= SRAM_Read[read_now][47:45] ; 
		histograms[14][count_hist] <= SRAM_Read[read_now][44:42] ; 
		histograms[13][count_hist] <= SRAM_Read[read_now][41:39] ; 
		histograms[12][count_hist] <= SRAM_Read[read_now][38:36] ; 
		histograms[11][count_hist] <= SRAM_Read[read_now][35:33] ; 
		histograms[10][count_hist] <= SRAM_Read[read_now][32:30] ; 
		histograms[9 ][count_hist] <= SRAM_Read[read_now][29:27] ; 
		histograms[8 ][count_hist] <= SRAM_Read[read_now][26:24] ; 
		histograms[7 ][count_hist] <= SRAM_Read[read_now][23:21] ; 
		histograms[6 ][count_hist] <= SRAM_Read[read_now][20:18] ; 
		histograms[5 ][count_hist] <= SRAM_Read[read_now][17:15] ; 
		histograms[4 ][count_hist] <= SRAM_Read[read_now][14:12] ; 
		histograms[3 ][count_hist] <= SRAM_Read[read_now][11:9 ] ; 
		histograms[2 ][count_hist] <= SRAM_Read[read_now][8 :6 ] ; 
		histograms[1 ][count_hist] <= SRAM_Read[read_now][5 :3 ] ; 
		histograms[0 ][count_hist] <= SRAM_Read[read_now][2 :0 ] ; 
	end else begin
		histograms[count_hist][15] <= SRAM_Read[read_now][47:45] ; 
		histograms[count_hist][14] <= SRAM_Read[read_now][44:42] ; 
		histograms[count_hist][13] <= SRAM_Read[read_now][41:39] ; 
		histograms[count_hist][12] <= SRAM_Read[read_now][38:36] ; 
		histograms[count_hist][11] <= SRAM_Read[read_now][35:33] ; 
		histograms[count_hist][10] <= SRAM_Read[read_now][32:30] ; 
		histograms[count_hist][9 ] <= SRAM_Read[read_now][29:27] ; 
		histograms[count_hist][8 ] <= SRAM_Read[read_now][26:24] ; 
		histograms[count_hist][7 ] <= SRAM_Read[read_now][23:21] ; 
		histograms[count_hist][6 ] <= SRAM_Read[read_now][20:18] ; 
		histograms[count_hist][5 ] <= SRAM_Read[read_now][17:15] ; 
		histograms[count_hist][4 ] <= SRAM_Read[read_now][14:12] ; 
		histograms[count_hist][3 ] <= SRAM_Read[read_now][11:9 ] ; 
		histograms[count_hist][2 ] <= SRAM_Read[read_now][8 :6 ] ; 
		histograms[count_hist][1 ] <= SRAM_Read[read_now][5 :3 ] ; 
		histograms[count_hist][0 ] <= SRAM_Read[read_now][2 :0 ] ; 
	end
end

reg  [4:0] spatial_value [0:5][0:3] ;   // 4 histograms  8 bins ; 

// assign spatial_value[0][0] = ( histograms[0][ 0] + histograms[0][ 1] ) + ( histograms[0][ 4] + histograms[0][ 5] ) ;
// assign spatial_value[0][1] = ( histograms[0][ 2] + histograms[0][ 3] ) + ( histograms[0][ 6] + histograms[0][ 7] ) ;
// generate
	// for (k=0 ; k<=5 ; k=k+1)begin
		// always@ (posedge clk, negedge rst_n)begin 
			// if (!rst_n)begin
				// spatial_value[k] <= 'd0 ; 
			// end else begin
				// spatial_value [k][0] <= ( histograms[k][ 0] + histograms[k][ 1] ) + ( histograms[k][ 4] + histograms[k][ 5] ) ;
				// spatial_value [k][1] <= ( histograms[k][ 2] + histograms[k][ 3] ) + ( histograms[k][ 6] + histograms[k][ 7] ) ;
				// spatial_value [k][2] <= ( histograms[k][ 8] + histograms[k][ 9] ) + ( histograms[k][12] + histograms[k][13] ) ;
				// spatial_value [k][3] <= ( histograms[k][10] + histograms[k][11] ) + ( histograms[k][14] + histograms[k][15] ) ;
			// end
		// end
	// end
// endgenerate

reg [2:0] count_spatial ; 
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		count_spatial <= 'd0 ; 
	end else if (now_start_number == start_number && one_cycle_delay) begin
		if (count_spatial == 'd5)
			count_spatial <= 'd0 ; 
		else
			count_spatial <= count_spatial + 'd1 ; 
	end else begin
		count_spatial <= 'd0 ; 
	end
end

always@ (posedge clk, negedge rst_n)begin 
	if (!rst_n)begin
		for (i=0 ; i<= 5 ; i=i+1)begin
			for (j=0 ; j<=3 ; j=j+1)begin
				spatial_value[i][j] <= 'd0 ; 
			end
		end
	end else begin
		spatial_value [count_spatial][0] <= ( stored_value[ 0] + stored_value[ 1] ) + ( stored_value[ 4] + stored_value[ 5] ) ;
		spatial_value [count_spatial][1] <= ( stored_value[ 2] + stored_value[ 3] ) + ( stored_value[ 6] + stored_value[ 7] ) ;
		spatial_value [count_spatial][2] <= ( stored_value[ 8] + stored_value[ 9] ) + ( stored_value[12] + stored_value[13] ) ;
		spatial_value [count_spatial][3] <= ( stored_value[10] + stored_value[11] ) + ( stored_value[14] + stored_value[15] ) ;
	end
end

reg [5:0] current_135[0:3] ; 
reg [5:0] current_024[0:3] ; 

reg [7:0] max_value[0:3] ; 
// reg [5:0] max_024[0:3] ; 

// reg [7:0] max_dist[0:1][0:3] ; 


reg flag_135 ; 
reg count_1 ;   // to check if the first line of input or not ; 
// for type 2 and 3 
wire [7:0] window5_value [0:3] ; 
generate
	for (k=0 ; k<=3 ; k=k+1)begin
		assign window5_value[k] = current_024[k] + current_135[k] ; 
	end
endgenerate

wire signed [8:0] subtract_value [0:2] ;
assign subtract_value[0] = {1'b0, max_dist_four[0]} - {1'b0, max_dist_four[1]} ; 
assign subtract_value[1] = {1'b0, max_dist_four[0]} - {1'b0, max_dist_four[2]} ; 
assign subtract_value[2] = {1'b0, max_dist_four[0]} - {1'b0, max_dist_four[3]} ;


wire gap [0:2] ;
assign gap[0] =  (  ( (subtract_value[0]) > 20  ) || (subtract_value[0] <  -20 )  ) ? 1 :  0 ;
assign gap[1] =  (  ( (subtract_value[1]) > 20  ) || (subtract_value[1] <  -20 )  ) ? 1 :  0 ;
assign gap[2] =  (  ( (subtract_value[2]) > 20  ) || (subtract_value[2] <  -20 )  ) ? 1 :  0 ; 
 
wire [2:0] three_gap ; 
assign three_gap = {gap[0], gap[1], gap[2] } ; 

generate
	for (k=0 ; k<=3 ; k=k+1)begin
		always@(posedge clk, negedge rst_n)begin
			if(!rst_n)begin
				current_135[k] <= 'd0 ;
			end else if (start_window_flag) begin
				if (flag_135)begin
					if (count_spatial == 'd0)begin
						current_135[k] <= spatial_value[5][k] + current_135[k] ; 
					end else begin
						current_135[k] <= spatial_value[count_spatial - 'd1 ][k] + current_135[k] ; 
					end
				end else begin
					current_135[k] <= current_135[k] - spatial_value[count_spatial][k] ; 
				end
			end else if (count_spatial == 'd2  || count_spatial == 'd4 ) begin
				current_135[k] <= current_135[k] + spatial_value[count_spatial - 'd1 ][k] ;  
			end else if (count_spatial == 'd0 ) begin
				current_135[k] <= 'd0 ; 
			end
		end
	end
endgenerate

generate
	for (k=0 ; k<=3 ; k=k+1)begin
		always@(posedge clk, negedge rst_n)begin
			if(!rst_n)begin
				current_024[k] <= 'd0 ;
			end else if (start_window_flag) begin
				if (flag_135)begin
					current_024[k] <= current_024[k] - spatial_value[count_spatial][k] ; 
				end else begin
						current_024[k] <= spatial_value[count_spatial - 'd1 ][k] + current_024[k] ; 
				end
			end else if (count_spatial == 'd1  || count_spatial == 'd3 || count_spatial == 'd5 ) begin
				current_024[k] <= current_024[k] + spatial_value[count_spatial - 'd1 ][k] ;  
			end else if (count_spatial == 'd0 )begin
				current_024[k] <= 'd0 ; 
			end
		end
	end
endgenerate

generate
	for (k=0 ; k<=3 ; k=k+1)begin
		always@(posedge clk, negedge rst_n)begin
			if(!rst_n)begin
				max_value[k] <= 'd0 ;
			end else if (start_window_flag) begin
				if (now_type == 'd1)begin
					if (max_value[k] < current_024[k])begin
						max_value[k] <= current_024[k] ; 
					end else if (max_value[k] < current_135[k])begin
						max_value[k] <= current_135[k] ;
					end
				end else begin
					if (max_value[k] < window5_value[k])begin
						max_value[k] <= window5_value[k] ; 
					end
				end
			end else begin
				max_value[k] <= 'd0 ;
			end
		end
	end
endgenerate

generate
	for (k=0 ; k<=3 ; k=k+1)begin
		always@(posedge clk, negedge rst_n)begin
			if(!rst_n)begin
				max_dist_four [k] <= 'd0 ;  
			end else if (start_window_flag) begin
				if (count_addr[write_now] == 'd6)begin
					max_dist_four[k] <= 'd1 ; 
				end else if (now_type == 'd1)begin
					if (  (max_value[k] < current_024[k])  || (max_value[k] < current_135[k])     )begin
						if (count_1 && current_state == ST_SORTING)begin
							max_dist_four[k] <= 'd250 ; 
						end else 
							max_dist_four[k] <= count_addr[write_now] - 'd5  ; 
					end 
				end else begin
				    if (  max_value[k] < window5_value[k]    )begin
						max_dist_four[k] <= count_addr[write_now] - 'd5  ; 
					end 
				end
				
			end else if (current_state == ST_SORTING&& (now_type == 'd2 || now_type == 'd3 ))begin
				
				if (k=='d0 && three_gap == 3'b111)begin
					max_dist_four[k] <=  max_dist_four[1] ; 
				end else if (k=='d1 && three_gap == 3'b100 )begin
					max_dist_four[k] <=  max_dist_four[0] ; 
				end else if (k=='d2 && three_gap == 3'b010)begin
					max_dist_four[k] <=  max_dist_four[1] ; 
				end else if (k=='d3 && three_gap == 3'b001)begin
					max_dist_four[k] <=  max_dist_four[1] ; 
				end 
				
				// case (three_gap)
					// 3'b100 : max_dist_four[1] <= max_dist_four[2] ;
					// 3'b010 : max_dist_four[2] <= max_dist_four[3] ;
					// 3'b001 : max_dist_four[3] <= max_dist_four[0] ;
					// 3'b111 : max_dist_four[0] <= max_dist_four[1] ;  
					
					// default :  max_dist_four[k] <=  max_dist_four[k] ; 
				// endcase
			end
		end
	end
endgenerate

// generate
	// for (k=0 ; k<=3 ; k=k+1)begin
		// always@(posedge clk, negedge rst_n)begin
			// if(!rst_n)begin
				// current_max_135[k] <= 'd0 ; 
				// current_max_246[k] <= 'd0 ; 
				// max_135[k] <= 'd0 ;
				// max_246[k] <= 'd0 ; 
				// for (i=0 ; i<= 1 ; i=i+1)begin
					// max_dist [i][k] <= 'd0 ; 
				// end
			// end else if (one_cycle_delay && now_start_number == start_number) begin
				// if (flag_135) begin
					// if (start_window_flag)begin
						// if (max_246[k] < current_max_246[k])begin
							// max_246[k] <= current_max_246[k] ; 
							// max_dist[1][k] <= count_addr[write_now] ;   //  the value near actual value 
						// end
						
						// if (count_spatial == 'd0 )
							// current_max_135[k] <= current_max_135[k] + spatial_value[5][k] ; 
						// else
							// current_max_135[k] <= current_max_135[k] + spatial_value[count_spatial-1][k] ; 
						
						// current_max_246[k] <=  current_max_246[k] - spatial_value[count_spatial][k] ; 
						
					// end else begin
						// current_max_246[k] <=  current_max_246[k] + spatial_value[count_spatial][k] ; 
					// end
				// end else begin 
					// if (start_window_flag)begin   // substracte the value first, and add the new value at next cycle
						// if (max_135[k] < current_max_135[k])begin
							// max_135[k] <= current_max_135[k] ; 
							// max_dist[0][k] <= count_addr[write_now] ;   //  the value near actual value 
						// end
						
						// if (count_spatial == 'd0 )
							// current_max_246[k] <= current_max_246[k] + spatial_value[5][k] ; 
						// else
							// current_max_246[k] <= current_max_246[k] + spatial_value[count_spatial-1][k] ; 
							
						// current_max_135[k] <=  current_max_135[k] - spatial_value[count_spatial][k] ; 
					// end else if (count_spatial == 'd2 && count_spatial == 'd4 ) begin
						// current_max_135[k] <=  current_max_135[k] + spatial_value[count_spatial][k] ; 
					// end 	
				// end
				
			// end
		// end 	
	// end
// endgenerate	



always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		start_window_flag <= 'd0 ; 
	end else if (current_state == ST_READ && count_16 == 'd15)begin
		start_window_flag <= 'd1 ; 
	end else if ( (current_state == ST_SORTING && count_1 == 'd0 )|| current_state == ST_IDLE ) begin
		start_window_flag <= 'd0 ; 
	end else if (count_16 == 'd6 && now_start_number == start_number  ) begin
		start_window_flag <= 'd1 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		flag_135 <= 'd0 ; 
	end else if (flag_135 ) begin
		flag_135 <= 'd0 ; 
	end else if (in_valid && start)begin
		flag_135 <= 'd1 ; 
	end
end
// assign spatial_value[1] = ( read_value[ 2] + read_value[ 3] ) + ( read_value[ 6] + read_value[ 7] ) ;
// assign spatial_value[2] = ( read_value[ 8] + read_value[ 9] ) + ( read_value[12] + read_value[13] ) ;
// assign spatial_value[3] = ( read_value[10] + read_value[11] ) + ( read_value[14] + read_value[15] ) ;

// Design

assign start_number = (now_type == 'd1)? 'd3 : 'd6 ;
					  // (now_type == 'd2)? 'd7 ;
					  // (now_type == 'd3)? 'd7 ; 

					  
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		now_type <= 'd0 ;
	end else if (current_state == ST_IDLE && in_valid)begin
		now_type <= inputtype ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		frame_id_data <= 'd0 ;
	end else if (current_state == ST_IDLE && in_valid)begin
		frame_id_data <= frame_id ; 
	end
end

// always@(posedge clk, negedge rst_n)begin
	// if(!rst_n)begin
		// count_hist_16_flag <= 'd0 ;
	// end else if (count_hist == 'd7) begin
		// count_hist_16_flag <= 'd1 ; 
	// end else begin
		// count_hist_16_flag <= 'd0 ; 
	// end
// end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		count_16 <= 'd0 ;
	end else if (in_valid && start) begin
		count_16 <= count_16 +'d1 ; 
	end else if (current_state == ST_SORTING)begin
		if (start_count_flag && count_hist == 'd15 )begin
			count_16 <= count_16 +'d1 ;
		end 
	end else if (current_state == ST_READ)begin
		if (rvalid_m_inf && Read_data_ready)begin
			count_16 <= count_16 +'d1 ; 
		end else if (count_hist == 'd15)begin
			count_16 <= count_16 +'d1 ; 
		end
	end else if (current_state == ST_WRITE)begin
		if (remainder == 'd14)begin
			count_16 <= count_16 +'d1 ; 
		end
	end else begin
		count_16 <= 'd0 ;
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		count_hist <= 'd0 ;
	end else if ( (count_addr[write_now] == 'd254 && current_state==ST_IN)  || current_state == ST_BUSY || current_state == ST_WRITE ) begin
		count_hist <= 'd0 ;
	end else if (current_state == ST_READ ) begin   // between the start and start 
		if ( bvalid_m_inf )begin
			count_hist <= count_hist +'d1 ; 
		end
	// end else if (current_state == ST)
	end else if (in_valid & SRAM_READ_DELAY )begin
		// if (count_hist == 'd15 && !start)
			// count_hist <= 'd15 ; 
		// else
			count_hist <= count_hist +'d1 ; 
	end else if (SRAM_READ_DELAY )begin
		count_hist <= count_hist +'d1 ; 
	end else begin
		count_hist <= 'd0 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		one_cycle_delay <= 'd0 ;
	end else if (in_valid && start) begin
		one_cycle_delay <= 'd1 ; 
	end else if (current_state == ST_SORTING && start_count_flag)begin
		one_cycle_delay <= 'd1 ; 
	end else begin
		one_cycle_delay <= 'd0 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		SRAM_READ_DELAY <= 'd0 ;
	// end else if (current_state == ST_IDLE)
	end else if ( (count_addr[write_now] == 'd254 && current_state == ST_IN)   || current_state == ST_IDLE) begin
		SRAM_READ_DELAY <= 'd0 ;	
	end else if (count_addr[read_now] == 'd0 ) begin
		SRAM_READ_DELAY <= 'd1 ; 
	// end else if (curre)
	end
end

always@(posedge clk , negedge rst_n)begin   //  current_state
	if (!rst_n)begin
		 busy <= 0 ;   //  ST_BUSY  == test_signal 
	end else if (current_state == ST_BUSY  || current_state == ST_WRITE  || current_state == ST_READ || current_state == ST_SORTING ) begin
		 busy <= 1 ; 
	end else begin
		 busy <= 0 ; 
	end
end

// FSM

always@(posedge clk , negedge rst_n)begin
	if(!rst_n)begin
		current_state <= ST_IDLE ; 
	end else begin
		current_state <= next_state ; 
	end
end

always@(*)begin
	case (current_state)
	
		ST_IN : begin	
					if (in_valid)
						next_state = ST_IN ; 
					else if (now_type == 'd0)
						next_state = ST_BUSY ; 
					else begin
						next_state = ST_SORTING ; 
					end
				end
		
		ST_BUSY : begin	
					if (Read_addr_valid & arready_m_inf)
						next_state = ST_READ ;
					else if (Write_addr_valid & awready_m_inf)
						next_state = ST_WRITE ; 
					else  
						next_state = ST_BUSY ; 
				end
		
		ST_READ : begin	
					if (write_finish)
						next_state = ST_IDLE ; 
					else 
						next_state = ST_READ ; 
				end
				
		ST_WRITE : begin	
					if (bvalid_m_inf)
						next_state = ST_IDLE ; 
					else 
						next_state = ST_WRITE ;  
				end
				
		ST_SORTING : begin	
					if (count_16 == 'd15 && count_hist == 'd15)
						next_state = ST_BUSY ; 
					else 
						next_state = ST_SORTING ;  
				end
		
		ST_IDLE : begin	
					if (in_valid)
						next_state = ST_IN ; 
					else 
						next_state = ST_IDLE ; 
				end
		default : next_state = ST_IDLE ; 
	endcase	
end


		

assign	input_DRAM_value[ 0] = rdata_m_inf[  7:0   ] ;
assign	input_DRAM_value[ 1] = rdata_m_inf[ 15:8   ] ;
assign	input_DRAM_value[ 2] = rdata_m_inf[ 23:16  ] ;
assign	input_DRAM_value[ 3] = rdata_m_inf[ 31:24  ] ;
assign	input_DRAM_value[ 4] = rdata_m_inf[ 39:32  ] ;
assign	input_DRAM_value[ 5] = rdata_m_inf[ 47:40  ] ;
assign	input_DRAM_value[ 6] = rdata_m_inf[ 55:48  ] ;
assign	input_DRAM_value[ 7] = rdata_m_inf[ 63:56  ] ;
assign	input_DRAM_value[ 8] = rdata_m_inf[ 71:64  ] ;
assign	input_DRAM_value[ 9] = rdata_m_inf[ 79:72  ] ;
assign	input_DRAM_value[10] = rdata_m_inf[ 87:80  ] ;
assign	input_DRAM_value[11] = rdata_m_inf[ 95:88  ] ;
assign	input_DRAM_value[12] = rdata_m_inf[103:96  ] ;
assign	input_DRAM_value[13] = rdata_m_inf[111:104 ] ;
assign	input_DRAM_value[14] = rdata_m_inf[119:112 ] ;
assign  input_DRAM_value[15] = (count_16 == 'd15) ? 'd0 : rdata_m_inf[127:120 ] ;  


reg signed [4:0] pipe_1_reg [0:1][0:7] ;

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		count_1 <= 'd0 ; 
	end else if ( (count_16 == 'd15 && (current_state == ST_READ || current_state == ST_IN) )|| (rvalid_m_inf && !rready_m_inf) ) begin
		count_1 <= 'd1 ; 
	end else begin
		count_1 <= 'd0 ; 
	end
end

reg [3:0] temp_value [0:5] ; 
always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			for (j=0 ; j<=7 ; j=j+1)begin
				pipe_1_reg[i][j] <= 'd0 ; 
			end
		end
		
		for (i=0 ; i<=5 ; i=i+1)begin
			temp_value[i] <= 'd0 ;
		end
	end else if (rready_m_inf) begin
		if (count_1)begin
			pipe_1_reg[0][ 0] <=  {1'b0 ,input_DRAM_value[0 ]} ;
			pipe_1_reg[0][ 1] <=  {1'b0 ,input_DRAM_value[2 ]} ;
			pipe_1_reg[0][ 2] <=  {1'b0 ,input_DRAM_value[4 ]} ;
		
			pipe_1_reg[1][ 0] <=  {1'b0 ,input_DRAM_value[1 ]} ;
			pipe_1_reg[1][ 1] <=  {1'b0 ,input_DRAM_value[3 ]} ; 
			pipe_1_reg[1][ 2] <=  {1'b0 ,input_DRAM_value[5 ]} ;
		end else begin
			pipe_1_reg[0][ 0] <=  {1'b0 ,input_DRAM_value[0 ]} -  {1'b0 ,temp_value[ 3]} ;
			pipe_1_reg[0][ 1] <=  {1'b0 ,input_DRAM_value[2 ]} -  {1'b0 ,temp_value[ 4]} ;
			pipe_1_reg[0][ 2] <=  {1'b0 ,input_DRAM_value[4 ]} -  {1'b0 ,temp_value[ 5]} ;
		
			pipe_1_reg[1][ 0] <=  {1'b0 ,input_DRAM_value[1 ]} -  {1'b0 ,temp_value[ 0]} ;
			pipe_1_reg[1][ 1] <=  {1'b0 ,input_DRAM_value[3 ]} -  {1'b0 ,temp_value[ 1]} ; 
			pipe_1_reg[1][ 2] <=  {1'b0 ,input_DRAM_value[5 ]} -  {1'b0 ,temp_value[ 2]} ;
		end 
		
			pipe_1_reg[0][ 3] <=  {1'b0 ,input_DRAM_value[6 ]} -  {1'b0 ,input_DRAM_value[0]} ;
			pipe_1_reg[0][ 4] <=  {1'b0 ,input_DRAM_value[8 ]} -  {1'b0 ,input_DRAM_value[2]} ;
			pipe_1_reg[0][ 5] <=  {1'b0 ,input_DRAM_value[10]} -  {1'b0 ,input_DRAM_value[4]} ;
			pipe_1_reg[0][ 6] <=  {1'b0 ,input_DRAM_value[12]} -  {1'b0 ,input_DRAM_value[6]} ;
			pipe_1_reg[0][ 7] <=  {1'b0 ,input_DRAM_value[14]} -  {1'b0 ,input_DRAM_value[8]} ;
			
			pipe_1_reg[1][ 3] <=  {1'b0 ,input_DRAM_value[7 ]} -  {1'b0 ,input_DRAM_value[1]} ;
			pipe_1_reg[1][ 4] <=  {1'b0 ,input_DRAM_value[9 ]} -  {1'b0 ,input_DRAM_value[3]} ;
			pipe_1_reg[1][ 5] <=  {1'b0 ,input_DRAM_value[11]} -  {1'b0 ,input_DRAM_value[5]} ;
			pipe_1_reg[1][ 6] <=  {1'b0 ,input_DRAM_value[13]} -  {1'b0 ,input_DRAM_value[7]} ;
			pipe_1_reg[1][ 7] <=  {1'b0 ,input_DRAM_value[15]} -  {1'b0 ,input_DRAM_value[9]} ;
		
		temp_value[0] <= input_DRAM_value[11] ; 
		temp_value[1] <= input_DRAM_value[13] ; 
		temp_value[2] <= input_DRAM_value[15] ; 
		
		temp_value[3] <= input_DRAM_value[10] ; 
		temp_value[4] <= input_DRAM_value[12] ; 
		temp_value[5] <= input_DRAM_value[14] ;
		
	end
end

reg signed [4:0] pipe_2_one [0:1][0:3] ;
reg signed [5:0] pipe_2_two [0:1][0:3] ;

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			for (j=0 ; j<=3 ; j=j+1)begin
				pipe_2_one[i][j] <= 'd0 ; 
				pipe_2_two[i][j] <= 'd0 ; 
			end
		end
	end else begin
		pipe_2_one[0][0] <= pipe_1_reg[0][ 0];
		pipe_2_one[0][1] <= pipe_1_reg[0][ 2];
		pipe_2_one[0][2] <= pipe_1_reg[0][ 4];
		pipe_2_one[0][3] <= pipe_1_reg[0][ 6];
		pipe_2_one[1][0] <= pipe_1_reg[1][ 0];
		pipe_2_one[1][1] <= pipe_1_reg[1][ 2];
		pipe_2_one[1][2] <= pipe_1_reg[1][ 4];
		pipe_2_one[1][3] <= pipe_1_reg[1][ 6];
		
		pipe_2_two[0][0] <= pipe_1_reg[0][ 0] + pipe_1_reg[0][ 1];
		pipe_2_two[0][1] <= pipe_1_reg[0][ 2] + pipe_1_reg[0][ 3];
		pipe_2_two[0][2] <= pipe_1_reg[0][ 4] + pipe_1_reg[0][ 5];
		pipe_2_two[0][3] <= pipe_1_reg[0][ 6] + pipe_1_reg[0][ 7];
		pipe_2_two[1][0] <= pipe_1_reg[1][ 0] + pipe_1_reg[1][ 1];
		pipe_2_two[1][1] <= pipe_1_reg[1][ 2] + pipe_1_reg[1][ 3];
		pipe_2_two[1][2] <= pipe_1_reg[1][ 4] + pipe_1_reg[1][ 5];
		pipe_2_two[1][3] <= pipe_1_reg[1][ 6] + pipe_1_reg[1][ 7];
	end
end

reg signed [4:0] pipe_3_one[0:1][0:1] ;
reg signed [5:0] pipe_3_two[0:1][0:1] ;
reg signed [6:0] pipe_3_three[0:1][0:1];
reg signed [6:0] pipe_3_four[0:1][0:1];

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			for (j=0 ; j<=1 ; j=j+1)begin
				pipe_3_one  [i][j] <= 'd0 ; 
				pipe_3_two  [i][j] <= 'd0 ; 
				pipe_3_three[i][j] <= 'd0 ; 
				pipe_3_four [i][j] <= 'd0 ; 
			end
		end
	end else begin
		pipe_3_one[0][0] <= pipe_2_one[0][0] ; 
		pipe_3_one[0][1] <= pipe_2_one[0][2] ; 
		pipe_3_one[1][0] <= pipe_2_one[1][0] ; 
		pipe_3_one[1][1] <= pipe_2_one[1][2] ; 
		
		pipe_3_two[0][0] <= pipe_2_two[0][0] ;
		pipe_3_two[0][1] <= pipe_2_two[0][2] ;
		pipe_3_two[1][0] <= pipe_2_two[1][0] ;
		pipe_3_two[1][1] <= pipe_2_two[1][2] ;
		
		pipe_3_three[0][0] <= {pipe_2_two[0][0][5],pipe_2_two[0][0]}  + { {2{pipe_2_one[0][1][4]}} ,pipe_2_one[0][1]} ; 
		pipe_3_three[0][1] <= {pipe_2_two[0][2][5],pipe_2_two[0][2]}  + { {2{pipe_2_one[0][3][4]}} ,pipe_2_one[0][3]} ;
		pipe_3_three[1][0] <= {pipe_2_two[1][0][5],pipe_2_two[1][0]}  + { {2{pipe_2_one[1][1][4]}} ,pipe_2_one[1][1]} ; 
		pipe_3_three[1][1] <= {pipe_2_two[1][2][5],pipe_2_two[1][2]}  + { {2{pipe_2_one[1][3][4]}} ,pipe_2_one[1][3]} ;
		
		pipe_3_four [0][0] <= {pipe_2_two[0][0][5],pipe_2_two[0][0]}  + { pipe_2_two[0][1][5],pipe_2_two[0][1]} ; 
		pipe_3_four [0][1] <= {pipe_2_two[0][2][5],pipe_2_two[0][2]}  + { pipe_2_two[0][3][5],pipe_2_two[0][3]} ; 
		pipe_3_four [1][0] <= {pipe_2_two[1][0][5],pipe_2_two[1][0]}  + { pipe_2_two[1][1][5],pipe_2_two[1][1]} ; 
		pipe_3_four [1][1] <= {pipe_2_two[1][2][5],pipe_2_two[1][2]}  + { pipe_2_two[1][3][5],pipe_2_two[1][3]} ; 
	end
end

reg signed [4:0] pipe_4_one[0:1] ;
reg signed [5:0] pipe_4_two[0:1] ;
reg signed [6:0] pipe_4_three[0:1][0:1];
reg signed [6:0] pipe_4_four[0:1][0:3];


always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			pipe_4_one[i] <= 'd0 ; 
			pipe_4_two[i] <= 'd0 ; 
			for (j=0 ; j<=1 ; j=j+1)begin
				pipe_4_three [i][j] <= 'd0 ; 
			end
			for (j=0 ; j<=3 ; j=j+1)begin
				pipe_4_four [i][j] <= 'd0 ; 
			end
		end
	end else begin
		pipe_4_one[0] <= pipe_3_one[0][0] ;
		pipe_4_one[1] <= pipe_3_one[1][0] ;
		
		pipe_4_two[0] <= pipe_3_two[0][0] ;
		pipe_4_two[1] <= pipe_3_two[1][0] ;
		
		pipe_4_three[0][0] <= pipe_3_three[0][0] ;
		pipe_4_three[0][1] <= pipe_3_four [0][0] ;
		pipe_4_three[1][0] <= pipe_3_three[1][0] ;
		pipe_4_three[1][1] <= pipe_3_four [1][0] ;
		
		pipe_4_four [0][0] <= pipe_3_four [0][0] + pipe_3_one[0][1] ; 
		pipe_4_four [0][1] <= pipe_3_four [0][0] + pipe_3_two[0][1] ; 
		pipe_4_four [0][2] <= pipe_3_four [0][0] + pipe_3_three[0][1] ; 
		pipe_4_four [0][3] <= pipe_3_four [0][0] + pipe_3_four[0][1] ;
		pipe_4_four [1][0] <= pipe_3_four [1][0] + pipe_3_one[1][1] ; 
		pipe_4_four [1][1] <= pipe_3_four [1][0] + pipe_3_two[1][1] ; 
		pipe_4_four [1][2] <= pipe_3_four [1][0] + pipe_3_three[1][1] ; 
		pipe_4_four [1][3] <= pipe_3_four [1][0] + pipe_3_four[1][1] ;
		
	end
end

reg [3:0] pipe_5_addr[0:1][0:3] ; 
reg signed [5:0] pipe_5_one[0:1] ; 
reg signed [6:0] pipe_5_two[0:1][0:2] ; 
reg signed [6:0] pipe_5_base[0:1] ; 

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			pipe_5_one[i] <= 'd0 ; 
			pipe_5_base[i] <= 'd0 ; 
			for (j=0 ; j<=3 ; j=j+1)begin
				pipe_5_addr [i][j] <= 'd0 ; 
				pipe_5_two [i][j] <= 7'd0 ; 
			end
		end
	end else begin
		if (pipe_4_one[0] < pipe_4_two[0])begin
			pipe_5_one[0] <=  pipe_4_two[0] ; 
			pipe_5_addr[0][0] <= 'd2 ;
		end else begin
			
			pipe_5_one[0] <= { pipe_4_one[0][4] ,pipe_4_one[0]} ; 
			pipe_5_addr[0][0] <= 'd0 ;
		end
		
		if (pipe_4_three[0][0] < pipe_4_three[0][1])begin
			pipe_5_two[0][0] <= pipe_4_three[0][1] ;
			pipe_5_addr[0][1] <= 'd6 ;
		end else begin
			
			pipe_5_two[0][0] <= pipe_4_three[0][0] ;
			pipe_5_addr[0][1] <= 'd4 ;
		end
		
		if (pipe_4_four[0][0] < pipe_4_four[0][1])begin
			pipe_5_two[0][1] <= pipe_4_four[0][1] ;
			pipe_5_addr[0][2] <= 'd10 ;
		end else begin
			
			pipe_5_two[0][1] <= pipe_4_four[0][0] ;
			pipe_5_addr[0][2] <= 'd8 ;
		end
		
		if (pipe_4_four[0][2] < pipe_4_four[0][3])begin
			pipe_5_two[0][2] <= pipe_4_four[0][3] ;
			pipe_5_addr[0][3] <= 'd14 ;
		end else begin
			
			pipe_5_two[0][2] <= pipe_4_four[0][2] ;
			pipe_5_addr[0][3] <= 'd12 ;
		end
		
		pipe_5_base[0] <= pipe_4_four[0][3] ; 
		
		///   ==============================
		if (pipe_4_one[1] < pipe_4_two[1])begin
			pipe_5_one[1] <= pipe_4_two[1] ; 
			pipe_5_addr[1][0] <= 'd3 ;
		end else begin
			
			pipe_5_one[1] <= pipe_4_one[1] ; 
			pipe_5_addr[1][0] <= 'd1 ;
		end
		
		if (pipe_4_three[1][0] < pipe_4_three[1][1])begin
			pipe_5_two[1][0] <= pipe_4_three[1][1] ;
			pipe_5_addr[1][1] <= 'd7 ;
		end else begin
			
			pipe_5_two[1][0] <= pipe_4_three[1][0] ;
			pipe_5_addr[1][1] <= 'd5 ;
		end
		
		if (pipe_4_four[1][0] < pipe_4_four[1][1])begin
			pipe_5_two[1][1] <= pipe_4_four[1][1] ;
			pipe_5_addr[1][2] <= 'd11 ;
		end else begin
			
			pipe_5_two[1][1] <= pipe_4_four[1][0] ;
			pipe_5_addr[1][2] <= 'd9 ;
		end
		
		if (pipe_4_four[1][2] < pipe_4_four[1][3])begin
			pipe_5_two[1][2] <= pipe_4_four[1][3] ;
			pipe_5_addr[1][3] <= 'd15 ;
		end else begin
			
			pipe_5_two[1][2] <= pipe_4_four[1][2] ;
			pipe_5_addr[1][3] <= 'd13 ;
		end
		
		pipe_5_base[1] <= pipe_4_four[1][3] ; 
	end
end

reg [3:0]pipe_6_addr [0:1][0:1] ; 
reg signed [6:0] pipe_6_one [0:1][0:1] ; 
reg signed [6:0] pipe_6_base[0:1] ;

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			for (j=0 ; j<=1 ; j=j+1)begin
				pipe_6_addr [i][j] <= 'd0 ; 
				pipe_6_one [i][j] <= 'd0 ; 
			end
			pipe_6_base[i] <= 'd0 ;
		end
	end else begin
		
		if (pipe_5_one[0] <  pipe_5_two[0][0] )begin
			pipe_6_one [0][0] <= pipe_5_two[0][0] ; 
			pipe_6_addr[0][0] <= pipe_5_addr[0][1] ;
		end else begin 
			pipe_6_one [0][0] <= pipe_5_one[0] ; 
			pipe_6_addr[0][0] <= pipe_5_addr[0][0] ; 
		end
		
		if (pipe_5_two[0][1] < pipe_5_two[0][2])begin
			pipe_6_one [0][1] <= pipe_5_two[0][2]  ;
			pipe_6_addr[0][1] <= pipe_5_addr[0][3] ; 
		end else begin
			pipe_6_one [0][1] <= pipe_5_two[0][1]  ;
			pipe_6_addr[0][1] <= pipe_5_addr[0][2] ; 
		end
		
		pipe_6_base[0] <= pipe_5_base[0] ; 
		///   ==============================
		
		if (pipe_5_one[1] <  pipe_5_two[1][0] )begin
			pipe_6_one [1][0] <= pipe_5_two[1][0] ; 
			pipe_6_addr[1][0] <= pipe_5_addr[1][1] ; 
		end else begin
			pipe_6_one [1][0] <= pipe_5_one[1] ; 
			pipe_6_addr[1][0] <= pipe_5_addr[1][0] ; 
		end
		
		if (pipe_5_two[1][1] < pipe_5_two[1][2])begin
			pipe_6_one [1][1] <= pipe_5_two[1][2]  ;
			pipe_6_addr[1][1] <= pipe_5_addr[1][3] ; 
		end else begin
			pipe_6_one [1][1] <= pipe_5_two[1][1]  ;
			pipe_6_addr[1][1] <= pipe_5_addr[1][2] ; 
		end
		
		pipe_6_base[1] <= pipe_5_base[1] ;
	end
end

reg [3:0] pipe_7_addr [0:1] ; 
reg signed [6:0] pipe_7_one [0:1] ; 
reg signed [6:0] pipe_7_base[0:1] ;

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			pipe_7_addr[i] <= 'd0 ;
			pipe_7_one [i] <= 'd0 ;
			pipe_7_base[i] <= 'd0 ; 
		end
	end else begin
		
		if (pipe_6_one[0][0] < pipe_6_one[0][1])begin
			pipe_7_one[0] <= pipe_6_one[0][1] ; 
			pipe_7_addr[0] <= pipe_6_addr[0][1] ;
		end else begin
			pipe_7_one [0] <= pipe_6_one [0][0] ; 
			pipe_7_addr[0] <= pipe_6_addr[0][0] ;
		end
		
		pipe_7_base[0] <= pipe_6_base[0] ; 
		///   ==============================
		if (pipe_6_one[1][0] < pipe_6_one[1][1])begin
			pipe_7_one[1] <= pipe_6_one[1][1] ; 
			pipe_7_addr[1] <= pipe_6_addr[1][1] ;
		end else begin
			pipe_7_one [1] <= pipe_6_one [1][0] ; 
			pipe_7_addr[1] <= pipe_6_addr[1][0] ;
		end
	
		pipe_7_base[1] <= pipe_6_base[1] ;
	end
end

reg signed [6:0] base_value[0:1] ; 
reg [5:0] pipe_8_out[0:1] ; 
reg [3:0] pipe_8_dist[0:1] ;


always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			base_value [i] <= 'd0 ;
			pipe_8_out [i] <= 'd0 ;
			pipe_8_dist[i] <= 'd0 ; 
		end
	end else begin
		
		pipe_8_out[0] <= pipe_7_one[0] + base_value[0] ;  
		pipe_8_dist[0] <= pipe_7_addr[0] ; 
		// base_value[0] <= base_value[0] + pipe_7_base[0] ; 
		///   ==============================
		pipe_8_out[1] <= pipe_7_one[1] + base_value[1] ; 
		pipe_8_dist[1] <= pipe_7_addr[1] ; 
		// base_value[1] <= base_value[1] + pipe_7_base[1] ; 
		
		if (count_16 == 'd6)begin
			base_value[0] <= 'd0 ; 
			base_value[1] <= 'd0 ; 
		end else begin
			base_value[0] <= base_value[0] + pipe_7_base[0] ; 
			base_value[1] <= base_value[1] + pipe_7_base[1] ; 
		end
	end
end


reg [5:0] max_out ;
reg [7:0] max_distance  ;
reg [7:0] base_distance ; 


always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		start_count_flag <= 'd0 ; 
	end else if ( count_16 == 'd7 && current_state == ST_READ) begin
		if (count_hist == 'd0 )
			start_count_flag <= 'd1 ;
		else if (count_hist == 'd15)
			start_count_flag <= 'd0 ; 
	end else if (count_hist == 'd15 && current_state == ST_SORTING)begin
		start_count_flag <= 'd1 ; 
	end else if (current_state == ST_BUSY)begin
		start_count_flag <= 'd0 ; 
	end
end

always@(posedge clk, negedge rst_n)begin
	if (!rst_n)begin
		max_distance  <= 'd0 ;
		base_distance <= 'd0 ; 
		max_out       <= 'd0 ;
	end else begin
		
		if (start_count_flag)begin
			base_distance  <= base_distance + 'd16 ; 
		end 
		
		if (pipe_8_out[0] < pipe_8_out[1])begin
			if ( (max_out < pipe_8_out[1])  || base_distance == 'd0 )begin
				max_out      <= pipe_8_out[1] ; 
				max_distance <= pipe_8_dist[1] + base_distance ;
			end
		
		end else begin
			if ( (max_out < pipe_8_out[0])  || base_distance == 'd0)begin
				max_out      <= pipe_8_out[0] ; 
				max_distance <= pipe_8_dist[0] + base_distance ; 
			end
		end 
		
		// if (max_out < pipe_8_out[1])begin
			// max_out      <= pipe_8_out[1] ; 
			// max_distance <= pipe_8_dist[1] + base_distance ; 
		// end else if (max_out < pipe_8_out[0])begin
			// max_out      <= pipe_8_out[0] ; 
			// max_distance <= pipe_8_dist[0] + base_distance ; 
		// end else if (base_distance == 'd0)begin
			// if (pipe_8_out[0] > pipe_8_out[1])begin
				// max_out      <= pipe_8_out[0] ; 
				// max_distance <= pipe_8_dist[0] ; 
			// end else begin
				// max_out      <= pipe_8_out[1] ; 
				// max_distance <= pipe_8_dist[1]  ; 
			// end
		// end
		
		// if (base_distance[0] == 'd0)begin
			// max_out[0]      <=  pipe_8_out[0] ; 
			// max_distance[0] <=  pipe_8_dist[0] + base_distance[0] ; 
			// max_out[1]      <=  pipe_8_out[1] ; 
			// max_distance[1] <=  pipe_8_dist[1] + base_distance[1] ; 
		// end else begin
			// if ( pipe_8_out[0]  > max_out[0]) begin
				// max_out[0]      <=  pipe_8_out[0] ; 
				// max_distance[0] <=  pipe_8_dist[0] + base_distance[0] ; 
			// end 
			
			// ///   ==============================
			
			// if ( pipe_8_out[1]  > max_out[1]) begin
				// max_out[1]      <=  pipe_8_out[1] ; 
				// max_distance[1] <=  pipe_8_dist[1] + base_distance[1] ; 
			// end
		// end
		
		
		
	end
end


assign max_distance_two_type = (max_distance > 'd3 ) ? max_distance - 'd3 : 'd1  ;

// always@(posedge clk, negedge rst_n)begin
	// if (!rst_n)begin
		// max_distance_two_type <= 'd0 ; 
		
	// end else begin
		// max_distance_two_type <= max_distance - 'd3 ; 
		// // if ( max_out[1]  > max_out[0]) begin
			// // max_distance_two_type <= max_distance[1] - 'd3 ; 
		// // end else begin
			// // max_distance_two_type <= max_distance[0] - 'd3; 
		// // end 
		
	// end
// end



















endmodule