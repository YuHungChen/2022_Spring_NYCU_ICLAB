//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Midterm Proejct            : TOF  
//   Author                     : Wen-Yue, Lin
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-3)
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
    window,
    mode,
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
input [1:0]     window; 
input           mode;
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
input  wire                    rlast_m_inf;    // indicate the last transfer 
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


parameter ST_IN   = 2'b00;
parameter ST_BUSY = 2'b01;

parameter ST_Write = 2'b10; 
parameter ST_Read  = 2'b11 ; 

integer i, j ;
/// ====FSM paramter============ 
reg valid_now ; 
wire finish_write ;  
reg [1:0] current_state , next_state ; 
/// ====FSM paramter============ 


/// ====READ paramter============

reg [ADDR_WIDTH-1:0] Read_address      ;
reg [DATA_WIDTH-1:0] Read_data         ;
reg 				 Read_data_ready   ; 
reg 				 Read_addr_valid   ; 
reg [5:0] count_read_number ;

wire read_response ; 
/// ====READ paramter============

/// ====Write paramter============
reg [ADDR_WIDTH-1:0] Write_address ;
reg [DATA_WIDTH-1:0] Write_data    ;
reg 				 Write_addr_valid   ; 
reg					 Write_data_valid   ;
reg [7:0]count_write_number ; 

reg write_response_ready ; 

reg write_last ; 
wire read_finish ; 


// reg addr_flag ; // to check whether addr is transferred or not
reg data_flag ; // to check whether data is transferred or not 
wire write_response ; 
reg [7:0] write_length ; 
/// ====Write paramter ============

/// ==== mode 1 ================
reg [3:0] count_transport ;
 
/// ==== mode 1 ================

/// ====SRAM paramter============ 
wire  [127:0] SRAM_Read   [0:1] ;
wire  [127:0] SRAM_Data   [0:1] ;
reg   [  7:0] count_addr [0:1] ;
wire   wen[0:1] ; 
reg   Read_now ; 

/// ====SRAM paramter============ 

/// ====Input paramter============ 
reg [7:0] histogram[0:15] ;
reg [3:0] total_start_number ; 
reg start_now ; 

reg [4:0] frame_id_data ;
reg mode_data ; 
reg first_data_flag ;
/// ====Input paramter============ 

/// ====Window_method paramter============ 
reg [10:0] max_sum , current_sum ;    //  when histogram[0] has gone through window_method , then store value to the DRAM .  At the same time , histogram[1] is doing windowing method . 
reg [7:0 ] temp_bin [0:15] ;  
reg [7:0 ] max_addr ; 
reg [1:0 ] window_data ;
wire [3:0] window_size ;
wire [2:0] window_size_sub_1 ;  
/// ====Window_method paramter============ 
assign window_size = (window_data == 'd0) ? 1 :   //  can compare to case ; 
					 (window_data == 'd1) ? 2 :
					 (window_data == 'd2) ? 4 :
					 (window_data == 'd3) ? 8 : 0 ; 
assign window_size_sub_1 = (window_data == 'd0) ? 0 :   //  can compare to case ; 
					 (window_data == 'd1) ? 1 :
					 (window_data == 'd2) ? 3 :
					 (window_data == 'd3) ? 7 : 0 ; 

//  ======Write address =========(AXI)
assign awsize_m_inf = 3'b100 ;	// Burst size ;
								// 4 byted matched with  (Data-bus width)   in each transfer.
assign awburst_m_inf = 2'b01 ;  // Burst type   //  2'b01 = INCR  in this project
							    // details how the address of each transfer within the burst
assign awid_m_inf    = 4'd0 ;
assign awlen_m_inf   = write_length ;
assign awvalid_m_inf = Write_addr_valid ;
assign awaddr_m_inf  = Write_address ; 
//  ======Write address =========(AXI)

// ========Write data only 128 bits ======; 
assign wvalid_m_inf = Write_data_valid ; 
assign wdata_m_inf = Write_data ; 
assign wlast_m_inf = write_last ; 	
// ========Write data only 128 bits ======; 

//  ========Write_response =============(AXI)
assign bready_m_inf = write_response_ready; 
assign write_response = (bresp_m_inf==0  & bready_m_inf  & bvalid_m_inf ) ? 1 : 0 ;  //  1 : write finish 
assign read_finish    = (rlast_m_inf  && Read_data_ready && rvalid_m_inf) ? 1 : 0 ;

reg finish ;
always@(posedge clk , negedge rst_n)begin
	if(!rst_n)begin
		finish <= 'd0 ;
	end else if (current_state == ST_IN )begin
		finish <= 'd0 ;
	end else if (write_response || read_finish )begin
		finish <= 'd1 ;
	end
end
//  ========Write_response =============(AXI)

// assign bresp_m_inf =  2'b0 ;   // only  "Okay"  is supported in this project
 							


// ====Read_address=========== (AXI)  

assign    arid_m_inf    = 4'd0 ; 
assign    arsize_m_inf  = 3'b100 ;  // Read  Burst size ;   // 4 byted matched with  (Data-bus width)   in each transfer.
assign    arburst_m_inf = 2'b01  ; // Burst type   //  2'b01 = INCR  in this project
assign 	  arlen_m_inf   = 8'd255 ;
assign    araddr_m_inf  = Read_address ; 
assign    arvalid_m_inf = Read_addr_valid ; 

// ====Read_address=========== (AXI)  


	
	
// =====Read_data is 128 bits=================================;
assign rready_m_inf = Read_data_ready ; 

// =====Read_data is 128 bits=================================;


// ===== SRAM  ==================================;
reg [7:0] pipe_stall_distance[0:4] ; 
assign SRAM_Data[0] = 	{ histogram[15],histogram[14],histogram[13],histogram[12],histogram[11],histogram[10],histogram[9],histogram[8],histogram[7] , histogram[6] ,histogram[5],histogram[4],histogram[3],histogram[2],histogram[1],histogram[0]} ;
assign SRAM_Data[1] = 	{ histogram[15],histogram[14],histogram[13],histogram[12],histogram[11],histogram[10],histogram[9],histogram[8],histogram[7] , histogram[6] ,histogram[5],histogram[4],histogram[3],histogram[2],histogram[1],histogram[0]} ;
// ===== SRAM  ==================================;

always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		write_length <= 'd0 ; 
	end else if (mode_data == 0) begin	
		write_length <= 'd255 ;
	end else begin
		write_length <= 'd0   ; 
	end
end	

always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		count_transport <= 'd0 ; 
	end else if (bready_m_inf & bvalid_m_inf) begin	
		count_transport <= count_transport + 'd1 ;
	end else if (current_state == ST_IN )begin
		count_transport <= 'd0   ; 
	end
end	

// Writing   
// reg write_flag ;
reg [3:0] count_16 ; 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		write_response_ready <= 'd0 ;
	end else if (current_state == ST_Write) begin
		write_response_ready <= 'd1 ;
	end else if (write_last)begin
		write_response_ready <= 'd1 ;
	end else begin
		write_response_ready <= 'd0 ;
	end
end

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		write_last <= 'd0 ;
	end else if (mode_data=='d1 && current_state == ST_Write ) begin
		write_last <= 'd1 ;
	end else if ( (count_16 == 'd0 ) && current_state == ST_Write  &&  count_write_number == awlen_m_inf ) begin
		write_last <= 'd1 ;
	end else if (mode_data == 'd1 ) begin
		write_last <= 'd1 ;
	end else 
		write_last <= 'd0 ;
end

// always@(posedge clk , negedge rst_n)begin
	// if(!rst_n) begin
		// write_flag <= 'd0 ;
	// end else if (mode_data) begin
		// write_flag <= 'd0 ;
	// end else if (busy) begin
		// write_flag <= 'd1 ;
	// end
// end

reg read_before ; 
//  =========address===============
always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Write_addr_valid <= 'd0 ;
	end else if (current_state == ST_Write)begin
		Write_addr_valid <= 'd0 ;
	end else if (Write_addr_valid  & awready_m_inf) begin
		Write_addr_valid <= 'd0 ; 
	end else if (mode_data == 0 & current_state == ST_BUSY)begin
		Write_addr_valid <= 'd1 ;
	end else if (read_before == 0 & current_state == ST_BUSY ) begin
		Write_addr_valid <= 'd1 ;
	end else if (current_state== ST_Read && mode_data == 'd1 & write_response_ready & bvalid_m_inf) begin
		Write_addr_valid <= 'd1 ;
	end
end

wire [3:0] lower_bit ;
assign lower_bit = frame_id_data - 'd16 ;

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Write_address <= 128'd0 ;
	end else if (mode_data == 'd0 )begin 
		if (frame_id_data > 'd15) begin
			Write_address <= {108'b0 , 4'd2 , lower_bit , 12'b0} ;
		end else begin
			Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 12'b0} ;
		end
	end else begin
		if (frame_id_data > 'd15) begin
			case (count_write_number)
				8'd0 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h0 , 4'hf , 4'b0} ;
				8'd1 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h1 , 4'hf , 4'b0} ;
				8'd2 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h2 , 4'hf , 4'b0} ;
				8'd3 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h3 , 4'hf , 4'b0} ;
				8'd4 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h4 , 4'hf , 4'b0} ;
				8'd5 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h5 , 4'hf , 4'b0} ;
				8'd6 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h6 , 4'hf , 4'b0} ;
				8'd7 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h7 , 4'hf , 4'b0} ;
				8'd8 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h8 , 4'hf , 4'b0} ;
				8'd9 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'h9 , 4'hf , 4'b0} ;
				8'd10 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'ha , 4'hf , 4'b0} ;
				8'd11 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'hb , 4'hf , 4'b0} ;
				8'd12 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'hc , 4'hf , 4'b0} ;
				8'd13 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'hd , 4'hf , 4'b0} ;
				8'd14 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'he , 4'hf , 4'b0} ;
				8'd15 : Write_address <= {108'b0 , 4'd2 , lower_bit , 4'hf , 4'hf , 4'b0} ;
				
				default : Write_address <= 'd0 ;
			endcase
		end else begin
			case (count_write_number)
				8'd0 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h0 , 4'hf , 4'b0} ;
				8'd1 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h1 , 4'hf , 4'b0} ;
				8'd2 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h2 , 4'hf , 4'b0} ;
				8'd3 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h3 , 4'hf , 4'b0} ;
				8'd4 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h4 , 4'hf , 4'b0} ;
				8'd5 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h5 , 4'hf , 4'b0} ;
				8'd6 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h6 , 4'hf , 4'b0} ;
				8'd7 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h7 , 4'hf , 4'b0} ;
				8'd8 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h8 , 4'hf , 4'b0} ;
				8'd9 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'h9 , 4'hf , 4'b0} ;
				8'd10 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'ha , 4'hf , 4'b0} ;
				8'd11 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'hb , 4'hf , 4'b0} ;
				8'd12 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'hc , 4'hf , 4'b0} ;
				8'd13 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'hd , 4'hf , 4'b0} ;
				8'd14 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'he , 4'hf , 4'b0} ;
				8'd15 : Write_address <= {108'b0 , 4'd1 , frame_id_data[3:0] , 4'hf , 4'hf , 4'b0} ;
				
				default : Write_address <= 'd0 ;
			endcase
		end
	end
end

//  =========address===============
reg stall_one_cycle; 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n)begin
		count_16 <= 'd0 ;
	end else if (mode_data==0 && busy && stall_one_cycle) begin
		count_16 <= count_16 + 'd1 ;
	end else if (Read_data_ready  & rvalid_m_inf)begin
		count_16 <= count_16 + 'd1 ; 
	end else if (current_state== ST_BUSY && read_before == 'd1 ) begin
		count_16 <= count_16 + 'd1 ; 	
	end else if (current_state == ST_IN)begin
		count_16 <= 'd0 ;
	end
end

reg count_1 ; 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		count_1 <= 'd0 ;
	end else if (rvalid_m_inf) begin
		count_1 <= count_1 + 'd1 ;
	end else if (current_state== ST_BUSY && read_before == 'd1 ) begin
		count_1 <= count_1 + 'd1 ; 	
	end else if (current_state == ST_IN)begin
		count_1 <= 'd0 ;
	end
end

//  ===========Data====================
reg [5:0] count_40 ; 
reg r_valid_flag ; 
always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		r_valid_flag <= 'd0 ;
	end else if (mode_data == 'd1 &&wready_m_inf && Write_data_valid) begin
		r_valid_flag <= 'd0 ;
	end else if (rvalid_m_inf)begin
		r_valid_flag <= 'd1 ;
	end else if (current_state == ST_IN) begin
		r_valid_flag <= 'd0 ;
	end
end
always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		count_40 <= 'd0 ;
	end else if (r_valid_flag) begin
		// if (count_40 == 'd44) 
			// count_40 <= 'd0 ;
		// else 
			count_40 <= count_40 +'d1 ;
	end else begin
		count_40 <= 'd0 ;
	end
end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Write_data_valid <= 'd0 ;
	// end else if (mode_data == 1 && count_16=='d0 && count_1=='d1)begin
		// Write_data_valid <= 'd1 ;
	end else if (mode_data == 'd1 && count_40 == 'd41 && read_before=='d1) begin
		Write_data_valid <= 'd1 ;
	end else if (mode_data == 'd1 && (count_40 == 'd7 || count_40 == 'd8) )begin
		Write_data_valid <= 'd1 ;
	end else if (wlast_m_inf) begin
		Write_data_valid <= 'd0 ; 
	end else if ( (count_addr[Read_now] == 'd3  ||count_addr[Read_now] == 'd4 )  & total_start_number==0 & (current_state==ST_Write || current_state==ST_Read))begin   //  to invoke write_data_ready
		Write_data_valid <= 'd1 ;
	end else if ( (count_16 =='d0 ) && current_state == ST_Write) begin
		Write_data_valid <= 'd1 ;
	end else begin
		Write_data_valid <= 'd0 ; 
	end
end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		count_write_number <= 'd0 ;
	end else if (mode_data == 1'b1 && wready_m_inf && Write_data_valid ) begin
		count_write_number <= count_write_number + 'd1 ;
	end else if (mode_data == 'b0 && count_16 == 'd0 & current_state == ST_Write)begin
		count_write_number <= count_write_number + 'd1 ;
	end else if (!busy) begin
		count_write_number <= 'd0 ; 
	end
end

reg [7:0] max_addr_mode_1; 

reg [3:0] count_bins ; 

reg final_data_flag ; 
always@ (posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		final_data_flag <= 'd0 ;
	end else if ( (current_sum > max_sum) && count_addr[Read_now] == 'd0 && count_bins == 'd15) begin
		final_data_flag <= 'd1 ;
	end else if (count_addr[Read_now] != 0 )begin
		final_data_flag <= 'd0 ;
	end
end

wire [7:0] final_data ;
assign final_data = 8'd0 - window_size ; 

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Write_data <= 'd0 ;
	end else if (current_state == ST_Write )begin
		if (final_data_flag)
		Write_data <= {final_data,histogram[14],histogram[13],histogram[12],histogram[11],histogram[10],histogram[9],histogram[8] ,histogram[7],histogram[6],histogram[5],histogram[4],histogram[3],histogram[2],histogram[1],histogram[0] } ; 
		else
		Write_data <= {histogram[15],histogram[14],histogram[13],histogram[12],histogram[11],histogram[10],histogram[9],histogram[8] ,histogram[7],histogram[6],histogram[5],histogram[4],histogram[3],histogram[2],histogram[1],histogram[0] } ; 
	end else begin
		Write_data <= { max_addr_mode_1 , rdata_m_inf[119:0]} ;
	end
end
//  ===========Data====================



// Reading   

always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		read_before <= 'd0 ;
	end else if (current_state== ST_Read)begin
		read_before <= 'd1 ;
	end else if (current_state== ST_IN) begin
		read_before <= 'd0 ;
	end
end
//  =========address===============
always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Read_addr_valid  <= 'd0 ;
	end else if (Read_addr_valid  & arready_m_inf) begin
		Read_addr_valid <= 'd0 ; 
	end else if (mode_data == 1 & current_state==ST_BUSY && read_before == 'd0) begin
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

//  =========address===============

//  ===========Data====================

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		count_read_number <= 'd0 ;
	end else if ( Read_data_ready  & rvalid_m_inf ) begin
		count_read_number <= count_read_number + 'd1 ; 
	end
end

reg [3:0] stall_eight_cycle ; 
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		stall_eight_cycle <='d0 ;
	end else if (stall_eight_cycle != 'd0 ) begin
		if (stall_eight_cycle == 'd13)
			stall_eight_cycle <='d0 ;
		else
			stall_eight_cycle <= stall_eight_cycle + 'd1 ;
	end else if (count_16 == 'd14 ) begin
		stall_eight_cycle <= stall_eight_cycle +'d1 ;
	end else 
		stall_eight_cycle <= 'd0 ;
end

always@(posedge clk , negedge rst_n)begin
	if (!rst_n )begin
		Read_data_ready <= 'd0 ;   // 
	end else if (stall_eight_cycle != 'd0 ) begin
		Read_data_ready <= 'd0;
	end else if (  rvalid_m_inf )begin
		Read_data_ready <= Read_data_ready + 'd1 ;
	end else 
		Read_data_ready <= 'd0 ;
end

// reg [127:0] Store_read_data ;
// always@(posedge clk , negedge rst_n)begin
	// if(!rst_n)begin
		// Store_read_data <= 'd0 ;
	// end else begin
		// Store_read_data <= rdata_m_inf ; 
	// end
// end
// assign Store_read_data = rdata_m_inf ; 

//  ===========Data====================


//  TA will check our ans at mode == 1 , and it's pulled up by only one cycle after the "busy" signal is pulled down /// 


always@(posedge clk , negedge rst_n)begin   //  current_state
	if (!rst_n)begin
		 busy <= 0 ;   //  ST_BUSY  == test_signal 
	end else if (current_state == ST_BUSY  || current_state == ST_Write  || current_state == ST_Read) begin
		 busy <= 1 ; 
	end else begin
		 busy <= 0 ; 
	end
end


// ======SRAM=========  ; 

RAM256 U_SRAM0 (.Q(SRAM_Read[0]),.CLK(clk),.CEN(1'b0),.WEN(wen[0]),.A(count_addr[0]),.D(SRAM_Data[0]),.OEN(1'b0));// 256 words  / 16 bit
RAM256 U_SRAM1 (.Q(SRAM_Read[1]),.CLK(clk),.CEN(1'b0),.WEN(wen[1]),.A(count_addr[1]),.D(SRAM_Data[1]),.OEN(1'b0));// 256 words  /  40 bit

// reg Write_now ; 

// assign Read_now = (total_start_number%2 == 0) ? 1 : 0  ;   //  odd_number  ==> SRAM0 Read   ,  even_number ==> SRAM1_read    
// assign Write_now = ~Read_now ; 

always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		stall_one_cycle <= 'd0 ;
	end else if (in_valid ) begin
		if (start)
			stall_one_cycle <=  'd1 ;
		else 
			stall_one_cycle <= 'd0; 
	end else if (busy) begin
		stall_one_cycle <=  'd1 ;
	end else 
		stall_one_cycle <= 'd0; 
end

// reg for_first_start ; 
// always@(posedge clk , negedge rst_n) begin
	// if(!rst_n) begin
		// for_first_start <= 'd0 ;
	// end else if (stall_one_cycle == 1 && for_first_start == 0 )begin
		// for_first_start <= 'd1 ;
	// end else if (busy) begin
		// for_first_start <= 'd0 ;
	// end
// end

reg [15:0] stop_pipe_1  ;
always@(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		stop_pipe_1 <= 'd0 ;
	end else if (in_valid)begin
		stop_pipe_1 <= stop ; 
	end else 
		stop_pipe_1 <= 'd0 ;
end


always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		for (i=0 ; i<=1 ; i=i+1)begin
			count_addr[i] <= 'd0 ;
		end	
	end else if (in_valid) begin
		if (count_addr [~Read_now] == 'd253)begin
			count_addr [~Read_now] <= count_addr [~Read_now] + 'd1 ;
		end else if (!start)begin
			count_addr [ Read_now] <= 'd0 ;
			count_addr [~Read_now] <= 'd0 ;
		end else if (valid_now )begin
			count_addr [Read_now]  <= count_addr  [Read_now] + 'd1 ;
			count_addr [~Read_now] <= count_addr [~Read_now] + 'd1 ;
		end else begin
			count_addr [Read_now]  <= count_addr  [Read_now] + 'd1 ;
			count_addr [~Read_now] <= 'd0 ;
		end
	end else if (busy) begin	
		if (mode_data == 1) begin
			if (read_finish) begin
				count_addr [Read_now]  <= 'd1 ;
			end else if (count_16 == 1) begin
				count_addr [Read_now]  <= count_addr  [Read_now] + 'd1 ;  // here
			end else if (current_state == ST_Write) begin
				count_addr [Read_now]  <= count_addr  [Read_now] + 'd1 ;
			end
		end if (count_addr [Read_now] == 'd254)
			count_addr [Read_now] <= 'd0 ;
		else if (count_bins=='d14  && count_addr [Read_now] == 0)
			count_addr [Read_now]  <= count_addr  [Read_now] ;  
		else
			count_addr [Read_now]  <= count_addr  [Read_now] + 'd1 ;
	end else begin
		if (count_addr [~Read_now] == 'd253)begin
			count_addr [~Read_now] <= count_addr [~Read_now] + 'd1 ;
		end else begin
			count_addr [ Read_now] <= 'd0 ;
			count_addr [~Read_now] <= 'd0 ; 
		end	
	end
		
end

assign wen [0] = (Read_now)? 0 : 1 ;
assign wen [1] = (Read_now)? 1 : 0 ;


always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		Read_now  <= 'd0 ;
		// Write_now <= 'd0 ; 
	end else if (finish)begin
		Read_now  <= 'd0 ;
		// Write_now <= 'd0 ; 
	end else if (count_addr[~Read_now] == 'd254)begin
		Read_now  <= ~Read_now ; 
		// Read_now  <= Write_now ;
		// Write_now <= Read_now  ; 
	end
end


// ======SRAM=========  ; 


// ======Input=========  ; 
always@(posedge clk , negedge rst_n)begin   //  to decide current_state to change to Busy or not ;
	if (!rst_n)begin
		valid_now <= 0 ;   
	end else if (stall_one_cycle ) begin
		valid_now <= 'd1 ; 
	end else if (!start)begin
		valid_now <= 'd0 ; 
	end
end

		
always@(posedge clk , negedge rst_n)begin   //  to decide current_state to change to Busy or not ;
	if (!rst_n)begin
		for (i=0 ; i<=15 ; i=i+1)begin
		   histogram[i] <= 0 ;   
		end
	end else if (current_state==ST_IN) begin
		if (total_start_number == 0)begin
			for (i=0 ; i<=15 ; i=i+1)begin
				histogram[i] <= stop_pipe_1[i] ;   
			end
		end else begin
			histogram[ 0] <= SRAM_Read[Read_now][  7:0   ] + {7'b0 , stop_pipe_1[ 0]} ;   
			histogram[ 1] <= SRAM_Read[Read_now][ 15:8   ] + {7'b0 , stop_pipe_1[ 1]} ; 
			histogram[ 2] <= SRAM_Read[Read_now][ 23:16  ] + {7'b0 , stop_pipe_1[ 2]} ; 
			histogram[ 3] <= SRAM_Read[Read_now][ 31:24  ] + {7'b0 , stop_pipe_1[ 3]} ; 
			histogram[ 4] <= SRAM_Read[Read_now][ 39:32  ] + {7'b0 , stop_pipe_1[ 4]} ; 
			histogram[ 5] <= SRAM_Read[Read_now][ 47:40  ] + {7'b0 , stop_pipe_1[ 5]} ; 
			histogram[ 6] <= SRAM_Read[Read_now][ 55:48  ] + {7'b0 , stop_pipe_1[ 6]} ; 
			histogram[ 7] <= SRAM_Read[Read_now][ 63:56  ] + {7'b0 , stop_pipe_1[ 7]} ; 
			histogram[ 8] <= SRAM_Read[Read_now][ 71:64  ] + {7'b0 , stop_pipe_1[ 8]} ; 
			histogram[ 9] <= SRAM_Read[Read_now][ 79:72  ] + {7'b0 , stop_pipe_1[ 9]} ; 
			histogram[10] <= SRAM_Read[Read_now][ 87:80  ] + {7'b0 , stop_pipe_1[10]} ; 
			histogram[11] <= SRAM_Read[Read_now][ 95:88  ] + {7'b0 , stop_pipe_1[11]} ; 
			histogram[12] <= SRAM_Read[Read_now][103:96  ] + {7'b0 , stop_pipe_1[12]} ; 
			histogram[13] <= SRAM_Read[Read_now][111:104 ] + {7'b0 , stop_pipe_1[13]} ; 
			histogram[14] <= SRAM_Read[Read_now][119:112 ] + {7'b0 , stop_pipe_1[14]} ; 
			histogram[15] <= SRAM_Read[Read_now][127:120 ] + {7'b0 , stop_pipe_1[15]} ; 
		end
	end else if (current_state == ST_Read )begin // current_state == ST_Read
		if (count_1 == 0 ) begin
			histogram[ 0] <= rdata_m_inf[  7:0   ] ;
			histogram[ 1] <= rdata_m_inf[ 15:8   ] ;
			histogram[ 2] <= rdata_m_inf[ 23:16  ] ;
			histogram[ 3] <= rdata_m_inf[ 31:24  ] ;
			histogram[ 4] <= rdata_m_inf[ 39:32  ] ;
			histogram[ 5] <= rdata_m_inf[ 47:40  ] ;
			histogram[ 6] <= rdata_m_inf[ 55:48  ] ;
			histogram[ 7] <= rdata_m_inf[ 63:56  ] ;
			histogram[ 8] <= rdata_m_inf[ 71:64  ] ;
			histogram[ 9] <= rdata_m_inf[ 79:72  ] ;
			histogram[10] <= rdata_m_inf[ 87:80  ] ;
			histogram[11] <= rdata_m_inf[ 95:88  ] ;
			histogram[12] <= rdata_m_inf[103:96  ] ;
			histogram[13] <= rdata_m_inf[111:104 ] ;
			histogram[14] <= rdata_m_inf[119:112 ] ;
			if (count_16 == 'd15)
				histogram[15] <= 'd0 ;
			else
				histogram[15] <= rdata_m_inf[127:120 ] ;
		end 
	end else if ((count_bins=='d15  && count_addr [Read_now] == 0))begin
			histogram[count_bins] <= max_addr ;
	end else if (mode_data== 'd0 ) begin  
		case (total_start_number) 
			0  : histogram[count_bins] <= SRAM_Read[Read_now][  7:0  ] ;
			1  : histogram[count_bins] <= SRAM_Read[Read_now][ 15:8  ] ;
			2  : histogram[count_bins] <= SRAM_Read[Read_now][ 23:16 ] ;
			3  : histogram[count_bins] <= SRAM_Read[Read_now][ 31:24 ] ;
			4  : histogram[count_bins] <= SRAM_Read[Read_now][ 39:32 ] ;
			5  : histogram[count_bins] <= SRAM_Read[Read_now][ 47:40 ] ;
			6  : histogram[count_bins] <= SRAM_Read[Read_now][ 55:48 ] ;
			7  : histogram[count_bins] <= SRAM_Read[Read_now][ 63:56 ] ;
			8  : histogram[count_bins] <= SRAM_Read[Read_now][ 71:64 ] ;
			9  : histogram[count_bins] <= SRAM_Read[Read_now][ 79:72 ] ;
			10 : histogram[count_bins] <= SRAM_Read[Read_now][ 87:80 ] ;
			11 : histogram[count_bins] <= SRAM_Read[Read_now][ 95:88 ] ;
			12 : histogram[count_bins] <= SRAM_Read[Read_now][103:96 ] ;
			13 : histogram[count_bins] <= SRAM_Read[Read_now][111:104] ;
			14 : histogram[count_bins] <= SRAM_Read[Read_now][119:112] ;
			15 : histogram[count_bins] <= SRAM_Read[Read_now][127:120] ; 
		endcase
	end
end

 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		mode_data       <= 'd0 ;
		frame_id_data   <= 'd0 ;
		first_data_flag <= 'd0 ;
		window_data     <= 'd0 ;
	end else if (in_valid & first_data_flag==0) begin
		mode_data 	    <= mode ;
		frame_id_data   <= frame_id ;
		window_data     <= window ; 
		first_data_flag <= 'd1 ;
	end else if (busy) begin
		first_data_flag <= 'd0 ;
	end
end 



always@(posedge clk , negedge rst_n)begin   //  to decide current_state to change to Busy or not ;
	if (!rst_n)begin
		total_start_number <= 'd0 ;
	end else if (count_addr[~Read_now] == 'd254 & in_valid) begin   //  not sure is 254 or 255
		total_start_number <= 'd1 ;
	end else if (count_addr[Read_now] ==  'd0 & count_bins=='d15 & busy)begin
		total_start_number <= total_start_number + 'd1  ;	
	end else if (!in_valid  & !busy)begin
		total_start_number <= 'd0 ;
	end
end

// ======Input=========  ; 


reg first_eight_flag ; 
// =======Window_method================
always@(posedge clk , negedge rst_n)begin   
	if (!rst_n)begin
		first_eight_flag <= 'd0 ;
	end else if (count_bins == window_size - 1  ) begin  
		first_eight_flag <= 'd1 ; 
	end else if (count_addr[Read_now] == 'd0)	begin
		first_eight_flag <= 'd0 ; 
	end else if (!busy)begin
		first_eight_flag <= 'd0 ;
	end
end

wire [10:0] new_sum ;
assign new_sum =  	(window_size==1)  ? 0 : 
					(first_eight_flag)? (current_sum - histogram[count_bins - window_size])  :  current_sum ;

reg addr0_stall ;
always@(posedge clk ,negedge rst_n)begin
	if(!rst_n) begin
		addr0_stall <= 'd0 ;
	end else if (count_addr[Read_now] == 'd0 && count_bins == 'd14 )begin
		addr0_stall <= addr0_stall + 'd1 ;
	end else begin
		addr0_stall <= 'd0 ;
	end
end


always@(posedge clk , negedge rst_n)begin   
	if (!rst_n)begin
		current_sum <= 'd0 ;
	// end else if (addr0_stall )begin
		// current_sum <= 'd0 ;
	end else if (addr0_stall || (count_addr[Read_now] == 'd0 && count_16 == 'd0))begin
		current_sum <= 'd0 ;
	end else begin
		case (total_start_number) 
			0  : current_sum <= new_sum + SRAM_Read[Read_now][  7:0  ] ;
			1  : current_sum <= new_sum + SRAM_Read[Read_now][ 15:8  ] ;
			2  : current_sum <= new_sum + SRAM_Read[Read_now][ 23:16 ] ;
			3  : current_sum <= new_sum + SRAM_Read[Read_now][ 31:24 ] ;
			4  : current_sum <= new_sum + SRAM_Read[Read_now][ 39:32 ] ;
			5  : current_sum <= new_sum + SRAM_Read[Read_now][ 47:40 ] ;
			6  : current_sum <= new_sum + SRAM_Read[Read_now][ 55:48 ] ;
			7  : current_sum <= new_sum + SRAM_Read[Read_now][ 63:56 ] ;
			8  : current_sum <= new_sum + SRAM_Read[Read_now][ 71:64 ] ;
			9  : current_sum <= new_sum + SRAM_Read[Read_now][ 79:72 ] ;
			10 : current_sum <= new_sum + SRAM_Read[Read_now][ 87:80 ] ;
			11 : current_sum <= new_sum + SRAM_Read[Read_now][ 95:88 ] ;
			12 : current_sum <= new_sum + SRAM_Read[Read_now][103:96 ] ;
			13 : current_sum <= new_sum + SRAM_Read[Read_now][111:104] ;
			14 : current_sum <= new_sum + SRAM_Read[Read_now][119:112] ;
			15 : current_sum <= new_sum + SRAM_Read[Read_now][127:120] ;
		endcase
	end
end


always@(posedge clk , negedge rst_n)begin   
	if (!rst_n)begin
		max_sum <= 'd0 ;
	end else if (busy ) begin  
		
		if (addr0_stall )begin
			max_sum <= 'd0 ;
		end else if (count_addr[Read_now] == 'd0 && count_bins == 'd0)begin
			max_sum <= 'd0 ;
		end else if (current_sum > max_sum) begin
			max_sum <= current_sum ; 
		end
		
	end else if (!busy)begin
		max_sum <= 'd0 ;
	end
end

always@(posedge clk , negedge rst_n)begin   
	if (!rst_n)begin
		max_addr <= 'd0 ;
	end else if (busy ) begin  
	
		if ((count_addr[Read_now] == 'd1 )) begin
			max_addr <= 'd1 ;
		end else if (current_sum > max_sum) begin
			if (count_addr[Read_now] == 'd0)
				max_addr <= 8'd255 - window_size ; 
			else if (count_addr[Read_now] > window_size)
				max_addr <= count_addr[Read_now] - window_size ;
			else
				max_addr <= 'd1 ;
		end
		
	end else if (!busy)begin
		max_addr <= 'd1 ;
	end
end

// always@(posedge clk , negedge rst_n)begin   
	// if (!rst_n)begin
		// for (i=0 ; i<=15 ; i=i+1)begin
			// temp_bin[i] <= 'd0 ;
		// end 
	// end else if ((count_bins=='d15  && count_addr [Read_now] == 0))begin
			// temp_bin[count_bins] <= max_addr ;
	// end else if (mode_data== 'd0 ) begin  
		// case (total_start_number) 
			// 0  : temp_bin[count_bins] <= SRAM_Read[Read_now][  7:0  ] ;
			// 1  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 15:8  ] ;
			// 2  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 23:16 ] ;
			// 3  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 31:24 ] ;
			// 4  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 39:32 ] ;
			// 5  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 47:40 ] ;
			// 6  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 55:48 ] ;
			// 7  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 63:56 ] ;
			// 8  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 71:64 ] ;
			// 9  : temp_bin[count_bins] <= SRAM_Read[Read_now][ 79:72 ] ;
			// 10 : temp_bin[count_bins] <= SRAM_Read[Read_now][ 87:80 ] ;
			// 11 : temp_bin[count_bins] <= SRAM_Read[Read_now][ 95:88 ] ;
			// 12 : temp_bin[count_bins] <= SRAM_Read[Read_now][103:96 ] ;
			// 13 : temp_bin[count_bins] <= SRAM_Read[Read_now][111:104] ;
			// 14 : temp_bin[count_bins] <= SRAM_Read[Read_now][119:112] ;
			// 15 : temp_bin[count_bins] <= SRAM_Read[Read_now][127:120] ; 
		// endcase
		
	// end
// end


always@(posedge clk , negedge rst_n)begin   //  to decide current_state to change to Busy or not ;
	if (!rst_n)begin
		count_bins <= 'd0 ;
	end else if (stall_one_cycle) begin   //  not sure is 254 or 255
		count_bins <= count_bins + 'd1 ;
	end else begin
		count_bins <= 'd0 ;
	end
end


// =======mode_1_pipeline================
reg signed [8:0] pipe_one[0:7] ;    // -255~255
reg [7:0] tmp_value[0:7] ; 
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<=7 ; i=i+1) 
			pipe_one[i] <= 'd0 ;
		for (i=0; i<=7 ; i=i+1) 
			tmp_value[i] <= 'd0 ;
	end else  begin
		case (window_data)
			2'd0: begin
					if (count_1==1 ) begin
						if (count_16 == 'd0 )
							pipe_one[0] <=  histogram[0] ;
						else 
							pipe_one[0] <=  {1'b0 ,histogram[0]} - { 1'b0 , tmp_value[0] }; 
						
						pipe_one[1] <= {1'b0 ,histogram[1]} - {1'b0 ,histogram[0]};
						pipe_one[2] <= {1'b0 ,histogram[2]} - {1'b0 ,histogram[1]};
						pipe_one[3] <= {1'b0 ,histogram[3]} - {1'b0 ,histogram[2]};
						pipe_one[4] <= {1'b0 ,histogram[4]} - {1'b0 ,histogram[3]};
						pipe_one[5] <= {1'b0 ,histogram[5]} - {1'b0 ,histogram[4]};
						pipe_one[6] <= {1'b0 ,histogram[6]} - {1'b0 ,histogram[5]};
						pipe_one[7] <= {1'b0 ,histogram[7]} - {1'b0 ,histogram[6]};
					end else begin
						pipe_one[0] <= {1'b0 ,histogram[ 8]} - {1'b0 ,histogram[ 7]};
						pipe_one[1] <= {1'b0 ,histogram[ 9]} - {1'b0 ,histogram[ 8]};
						pipe_one[2] <= {1'b0 ,histogram[10]} - {1'b0 ,histogram[ 9]};
						pipe_one[3] <= {1'b0 ,histogram[11]} - {1'b0 ,histogram[10]};
						pipe_one[4] <= {1'b0 ,histogram[12]} - {1'b0 ,histogram[11]};
						pipe_one[5] <= {1'b0 ,histogram[13]} - {1'b0 ,histogram[12]};
						pipe_one[6] <= {1'b0 ,histogram[14]} - {1'b0 ,histogram[13]};
						pipe_one[7] <= {1'b0 ,histogram[15]} - {1'b0 ,histogram[14]};
					end
					tmp_value[0] <= histogram[15] ; 
			   end
			2'd1: begin
					if (count_1==1 ) begin
						if (count_16 == 'd0 ) begin
							pipe_one[0] <=  histogram[0] ;
							pipe_one[1] <=  histogram[1] ; 
						end
						else begin 
							pipe_one[0] <=  {1'b0 ,histogram[0]} - { 1'b0 , tmp_value[0] }; 
							pipe_one[1] <=  {1'b0 ,histogram[1]} - { 1'b0 , tmp_value[1] }; 
						end
						
						pipe_one[2] <= {1'b0 ,histogram[2]} - {1'b0 ,histogram[0]};
						pipe_one[3] <= {1'b0 ,histogram[3]} - {1'b0 ,histogram[1]};
						pipe_one[4] <= {1'b0 ,histogram[4]} - {1'b0 ,histogram[2]};
						pipe_one[5] <= {1'b0 ,histogram[5]} - {1'b0 ,histogram[3]};
						pipe_one[6] <= {1'b0 ,histogram[6]} - {1'b0 ,histogram[4]};
						pipe_one[7] <= {1'b0 ,histogram[7]} - {1'b0 ,histogram[5]};
					end else begin
						pipe_one[0] <= {1'b0 ,histogram[ 8]} - {1'b0 ,histogram[6]};
						pipe_one[1] <= {1'b0 ,histogram[ 9]} - {1'b0 ,histogram[7]};
						pipe_one[2] <= {1'b0 ,histogram[10]} - {1'b0 ,histogram[8]} ;
						pipe_one[3] <= {1'b0 ,histogram[11]} - {1'b0 ,histogram[9]};
						pipe_one[4] <= {1'b0 ,histogram[12]} - {1'b0 ,histogram[10]};
						pipe_one[5] <= {1'b0 ,histogram[13]} - {1'b0 ,histogram[11]};
						pipe_one[6] <= {1'b0 ,histogram[14]} - {1'b0 ,histogram[12]};
						pipe_one[7] <= {1'b0 ,histogram[15]} - {1'b0 ,histogram[13]};
					end
					tmp_value[0] <= histogram[14] ; 
					tmp_value[1] <= histogram[15] ; 
			   end
			2'd2: begin
					if (count_1==1 ) begin
						if (count_16 == 'd0 ) begin
							pipe_one[0] <=  histogram[0] ;
							pipe_one[1] <=  histogram[1] ; 
							pipe_one[2] <=  histogram[2] ;
							pipe_one[3] <=  histogram[3] ; 
						end
						else begin 
							pipe_one[0] <=  {1'b0 ,histogram[0]} - { 1'b0 , tmp_value[0] }; 
							pipe_one[1] <=  {1'b0 ,histogram[1]} - { 1'b0 , tmp_value[1] };  
							pipe_one[2] <=  {1'b0 ,histogram[2]} - { 1'b0 , tmp_value[2] }; 
							pipe_one[3] <=  {1'b0 ,histogram[3]} - { 1'b0 , tmp_value[3] };  
						end
						
						pipe_one[4] <= {1'b0 ,histogram[4]} - {1'b0 ,histogram[0]};
						pipe_one[5] <= {1'b0 ,histogram[5]} - {1'b0 ,histogram[1]};
						pipe_one[6] <= {1'b0 ,histogram[6]} - {1'b0 ,histogram[2]};
						pipe_one[7] <= {1'b0 ,histogram[7]} - {1'b0 ,histogram[3]};
					end else begin
						pipe_one[0] <= {1'b0 ,histogram[ 8]} - {1'b0 ,histogram[ 4]};
						pipe_one[1] <= {1'b0 ,histogram[ 9]} - {1'b0 ,histogram[ 5]};
						pipe_one[2] <= {1'b0 ,histogram[10]} - {1'b0 ,histogram[ 6]};
						pipe_one[3] <= {1'b0 ,histogram[11]} - {1'b0 ,histogram[ 7]};
						pipe_one[4] <= {1'b0 ,histogram[12]} - {1'b0 ,histogram[ 8]};
						pipe_one[5] <= {1'b0 ,histogram[13]} - {1'b0 ,histogram[ 9]};
						pipe_one[6] <= {1'b0 ,histogram[14]} - {1'b0 ,histogram[10]};
						pipe_one[7] <= {1'b0 ,histogram[15]} - {1'b0 ,histogram[11]};
					end
					tmp_value[0] <= histogram[12] ; 
					tmp_value[1] <= histogram[13] ; 
					tmp_value[2] <= histogram[14] ; 
					tmp_value[3] <= histogram[15] ; 
			   end
			2'd3: begin
					if (count_1==1) begin
						if (count_16 == 'd0 ) begin
							pipe_one[0] <=  {1'b0 ,histogram[0]} ; 
							pipe_one[1] <=  {1'b0 ,histogram[1]} ;  
							pipe_one[2] <=  {1'b0 ,histogram[2]} ; 
							pipe_one[3] <=  {1'b0 ,histogram[3]} ;  
							pipe_one[4] <=  {1'b0 ,histogram[4]} ; 
							pipe_one[5] <=  {1'b0 ,histogram[5]} ;  
							pipe_one[6] <=  {1'b0 ,histogram[6]} ; 
							pipe_one[7] <=  {1'b0 ,histogram[7]} ;  
						end else begin
							pipe_one[0] <= {1'b0 ,histogram[0]} - { 1'b0 , tmp_value[0] };
							pipe_one[1] <= {1'b0 ,histogram[1]} - { 1'b0 , tmp_value[1] };
							pipe_one[2] <= {1'b0 ,histogram[2]} - { 1'b0 , tmp_value[2] };
							pipe_one[3] <= {1'b0 ,histogram[3]} - { 1'b0 , tmp_value[3] };
							pipe_one[4] <= {1'b0 ,histogram[4]} - { 1'b0 , tmp_value[4] };
							pipe_one[5] <= {1'b0 ,histogram[5]} - { 1'b0 , tmp_value[5] };
							pipe_one[6] <= {1'b0 ,histogram[6]} - { 1'b0 , tmp_value[6] };
							pipe_one[7] <= {1'b0 ,histogram[7]} - { 1'b0 , tmp_value[7] };
						end
					end else begin
						pipe_one[0] <= {1'b0  ,histogram[ 8]} - {1'b0 ,histogram[0]};
						pipe_one[1] <= {1'b0  ,histogram[ 9]} - {1'b0 ,histogram[1]};
						pipe_one[2] <= {1'b0  ,histogram[10]} - {1'b0 ,histogram[2]};
						pipe_one[3] <= {1'b0  ,histogram[11]} - {1'b0 ,histogram[3]};
						pipe_one[4] <= {1'b0  ,histogram[12]} - {1'b0 ,histogram[4]};
						pipe_one[5] <= {1'b0  ,histogram[13]} - {1'b0 ,histogram[5]};
						pipe_one[6] <= {1'b0  ,histogram[14]} - {1'b0 ,histogram[6]};
						pipe_one[7] <= {1'b0  ,histogram[15]} - {1'b0 ,histogram[7]};
					end
					tmp_value[0] <= histogram[8] ; 
					tmp_value[1] <= histogram[9] ; 
					tmp_value[2] <= histogram[10] ; 
					tmp_value[3] <= histogram[11] ;
					tmp_value[4] <= histogram[12] ; 
					tmp_value[5] <= histogram[13] ; 
					tmp_value[6] <= histogram[14] ; 
					tmp_value[7] <= histogram[15] ;
			   end
		endcase
	end
end

// pipeline_2 ;
// D1+D2  -510~510
reg signed [8:0] pipe_two_1 [0:3] ; 
reg signed [9:0] pipe_two_2 [0:3] ; 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		for (i=0; i<=3 ; i=i+1) begin
			pipe_two_1[i] <= 'd0 ;
			pipe_two_2[i] <= 'd0 ;
		end
	end else begin
		pipe_two_1[0] <= pipe_one[0] ;
		pipe_two_1[1] <= pipe_one[2] ;
		pipe_two_1[2] <= pipe_one[4] ;
		pipe_two_1[3] <= pipe_one[6] ;
		
		pipe_two_2[0] <= {pipe_one[0][8] ,pipe_one[0]} + {pipe_one[1][8] , pipe_one[1]}  ;
		pipe_two_2[1] <= {pipe_one[2][8] ,pipe_one[2]} + {pipe_one[3][8] , pipe_one[3]}  ;
		pipe_two_2[2] <= {pipe_one[4][8] ,pipe_one[4]} + {pipe_one[5][8] , pipe_one[5]}  ;
		pipe_two_2[3] <= {pipe_one[6][8] ,pipe_one[6]} + {pipe_one[7][8] , pipe_one[7]}  ;
	end
end

// pipeline_3 ;
// D1+D2+D3     -765~765
// D1+D2+D3+D4  -1020 ~1020 :
reg signed [8:0] pipe_three_1 [0:1] ; 
reg signed [9:0] pipe_three_2 [0:1] ; 
reg signed [10:0] pipe_three_3 [0:1] ; 
reg signed [10:0] pipe_three_4 [0:1] ;
always@(posedge clk , negedge rst_n)begin
	if(!rst_n)begin
		for (i=0; i<=1 ; i=i+1) begin
			pipe_three_1[i] <= 'd0 ;
			pipe_three_2[i] <= 'd0 ;
			pipe_three_3[i] <= 'd0 ;
			pipe_three_4[i] <= 'd0 ;
		end
	end else begin
		pipe_three_1[0] <= pipe_two_1[0] ; 
		pipe_three_1[1] <= pipe_two_1[2] ; 
		
		pipe_three_2[0] <= pipe_two_2[0] ; 
		pipe_three_2[1] <= pipe_two_2[2] ;

		pipe_three_3[0] <= {pipe_two_2[0][9] , pipe_two_2[0]} + {{2{pipe_two_1[1][8]}} , pipe_two_1[1]} ; 
		pipe_three_3[1] <= {pipe_two_2[2][9] , pipe_two_2[2]} + {{2{pipe_two_1[3][8]}} , pipe_two_1[3]} ;
		
		pipe_three_4[0] <= {pipe_two_2[0][9] , pipe_two_2[0]}  + {pipe_two_2[1][9] ,pipe_two_2[1]} ; 
		pipe_three_4[1] <= {pipe_two_2[2][9] , pipe_two_2[2]}  + {pipe_two_2[3][9] ,pipe_two_2[3]} ;
		
	end
end 

// pipeline_4 ;
// D1+D2+D3     -765~765
// D1+D2+D3+D4  -1020 ~1020 :
// D1 ~ D8      -2040 ~ 2040 ;
reg signed [8:0] pipe_four_1  ; 
reg signed [9:0] pipe_four_2  ; 
reg signed [10:0] pipe_four_3 ; 
reg signed [10:0] pipe_four_4 ;
reg signed [11:0] pipe_four_5  ; 
reg signed [11:0] pipe_four_6  ; 
reg signed [11:0] pipe_four_7 ; 
reg signed [11:0] pipe_four_8 ;

always@(posedge clk , negedge rst_n) begin
	if (!rst_n) begin
		pipe_four_1 <= 'd0 ;
		pipe_four_2 <= 'd0 ;
		pipe_four_3 <= 'd0 ;
		pipe_four_4 <= 'd0 ;
		pipe_four_5 <= 'd0 ;
		pipe_four_6 <= 'd0 ;
		pipe_four_7 <= 'd0 ;
		pipe_four_8 <= 'd0 ;
	end else begin
		pipe_four_1 <= pipe_three_1[0] ;
		pipe_four_2 <= pipe_three_2[0] ;
		pipe_four_3 <= pipe_three_3[0] ;
		pipe_four_4 <= pipe_three_4[0] ;
		pipe_four_5 <= {pipe_three_4[0][10] , pipe_three_4[0]} + {{3{pipe_three_1[1][8]}} , pipe_three_1[1]} ;
		pipe_four_6 <= {pipe_three_4[0][10] , pipe_three_4[0]} + {{2{pipe_three_2[1][9]}} , pipe_three_2[1]};
		pipe_four_7 <= {pipe_three_4[0][10] , pipe_three_4[0]} + {pipe_three_3[1][10],pipe_three_3[1]};
		pipe_four_8 <= {pipe_three_4[0][10] , pipe_three_4[0]} + {pipe_three_4[1][10],pipe_three_4[1]};
	end
end

// pipe_5 
reg [3:0] pipe_5_addr[0:3] ;
reg signed [9:0] pipe_five_out_1 ;
reg signed [10:0] pipe_five_out_2 ;
reg signed [11:0] pipe_five_out_3 ;
reg signed [11:0] pipe_five_out_4 ;

reg signed [11:0] pipe_five_8 ;

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		for (i=0; i<=3 ; i=i+1) begin
			pipe_5_addr[i] <= 'd0 ;
		end
		pipe_five_out_1 <= 'd0 ;
		pipe_five_out_2 <= 'd0 ;
		pipe_five_out_3 <= 'd0 ;
		pipe_five_out_4 <= 'd0 ;
		
		pipe_five_8		<= 'd0 ;
	end else begin
		if (count_40 == 'd38)begin
			pipe_5_addr[0] <= 'd0 ;
		end else if (pipe_four_2 >  pipe_four_1) begin
			pipe_five_out_1 <= pipe_four_2 ; 
			pipe_5_addr[0]		<= 'd2 ; 
		end else begin
			pipe_five_out_1 <= {pipe_four_1[8], pipe_four_1} ; 
			pipe_5_addr[0]		<= 'd1 ; 
		end
		
		if (count_40 == 'd38)begin
			pipe_5_addr[1] <= 'd0 ;
		end else if (pipe_four_4 > pipe_four_3) begin
			pipe_five_out_2 <= pipe_four_4 ; 
			pipe_5_addr[1]	<= 'd4 ; 
		end else begin
		    pipe_five_out_2 <= pipe_four_3 ; 
			pipe_5_addr[1]	<= 'd3 ; 
		end
		
		if (count_40 == 'd38)begin
			pipe_5_addr[2] <= 'd0 ;
		end else if (pipe_four_6 > pipe_four_5) begin
			pipe_five_out_3 <= pipe_four_6 ; 
			pipe_5_addr[2]	<= 'd6 ; 
		end else begin
		    pipe_five_out_3 <= pipe_four_5 ; 
			pipe_5_addr[2]	<= 'd5 ; 		
		end
		
		if (count_40 == 'd38)begin
			pipe_5_addr[3] <= 'd0 ;
		end else if (pipe_four_8 > pipe_four_7) begin
			pipe_five_out_4 <= pipe_four_8 ; 
			pipe_5_addr[3]	<= 'd8 ; 
		end else begin
		    pipe_five_out_4 <= pipe_four_7 ; 
			pipe_5_addr[3]	<= 'd7 ; 
		end
		
		pipe_five_8 <= pipe_four_8 ; 
		
	end
end

// pipe_6 
reg signed [10:0] pipe_6_out_1 ;
reg signed [11:0] pipe_6_out_2 ;
reg [3:0] pipe_6_addr [0:1] ; 

reg signed [11:0] pipe_six_8 ;

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		pipe_6_out_1 <= 'd0 ;
		pipe_6_out_2 <= 'd0 ;
		for (i=0; i<=1 ; i=i+1) begin
			pipe_6_addr[i] <= 'd0 ;
		end
		pipe_six_8 <= 'd0 ;
	end else begin
		if (pipe_five_out_2 > pipe_five_out_1) begin
			pipe_6_out_1 	 	<= pipe_five_out_2 ; 
			pipe_6_addr[0]		<= pipe_5_addr[1] ; 
		end else begin
			pipe_6_out_1 <= {pipe_five_out_1[9], pipe_five_out_1} ; 
			pipe_6_addr[0]		<= pipe_5_addr[0] ; 
		end
		
		if (pipe_five_out_4 > pipe_five_out_3) begin
			pipe_6_out_2 <= pipe_five_out_4 ; 
			pipe_6_addr[1]	<= pipe_5_addr[3] ; 
		end else begin
		    pipe_6_out_2 <= pipe_five_out_3 ; 
			pipe_6_addr[1]	<= pipe_5_addr[2] ; 
		end
		
		pipe_six_8  <= pipe_five_8 ; 
	end
end 

// pipe 7 
reg signed [11:0] pipe_7_out ; 
reg [3:0] pipe_7_addr ; 
reg signed [11:0] pipe_seven_8 ; 

always@(posedge clk , negedge rst_n)begin
	if (!rst_n)begin
		pipe_7_out <= 'd0 ;
		pipe_7_addr <= 'd0 ;
		pipe_seven_8 <= 'd0 ;
	end else begin
		if ( pipe_6_out_2 > pipe_6_out_1) begin
			pipe_7_out  <= pipe_6_out_2 ; 
			pipe_7_addr	<= pipe_6_addr[1] ; 
		end else begin
			pipe_7_out  <= {pipe_6_out_1[10] , pipe_6_out_1} ; 
			pipe_7_addr	<= pipe_6_addr[0] ; 
		end
		
		pipe_seven_8 <= pipe_six_8 ; 
	end
end


// pipe_8 
reg [10:0] pipe_8_out ; 
reg [7:0]  pipe_8_addr ; 
reg [7:0]  temp_addr   ; 
reg signed [11:0] basic ; 
always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		pipe_8_out  <= 'd0 ;
		pipe_8_addr <= 'd0 ;
		basic    <= 'd0 ;
		temp_addr <= 'd0 ; 
	end else begin
	
		if (count_40 >= 'd7 ) begin
			temp_addr   <=  temp_addr + 'd8 ;
			pipe_8_addr <= {4'b0 , pipe_7_addr} + temp_addr ;
			pipe_8_out  <= pipe_7_out + basic ; 
			basic    <= pipe_seven_8  + basic ; 
		end else begin 
			temp_addr   <= 'd0 ;
			pipe_8_addr <= 'd0 ;
			pipe_8_out  <= 'd0 ;
			basic       <= 'd0  ; 
			
		end

	end
end

// pipe_9 
reg [10:0] pipe_9_out ; 
reg [7:0]  pipe_9_addr_mode_1 ; 

reg [7:0] pipe_9_tmp_addr ; 
always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		pipe_9_out  <= 'd0 ;
		pipe_9_addr_mode_1 <= 'd0 ;
		pipe_9_tmp_addr    <= 'd0 ;
	end else begin
		if (pipe_8_out > pipe_9_out) begin
			pipe_9_out  <= pipe_8_out ; 
			pipe_9_addr_mode_1 <= pipe_8_addr ; 
			pipe_9_tmp_addr <= pipe_8_addr - window_size_sub_1 ; 
		end else if (count_40 < 'd8) begin
			pipe_9_out  <= 'd0 ;
			pipe_9_addr_mode_1 <= 'd0 ;
			pipe_9_tmp_addr <= 'd0 ;
		end
		
		
	end
end

// pipe10
reg [10:0] max_out ; 

always@(posedge clk , negedge rst_n)begin
	if(!rst_n) begin
		max_out  <= 'd0 ;
		max_addr_mode_1 <= 'd0 ;
	end else begin
		max_out  <= pipe_9_out ; 
		if (pipe_9_addr_mode_1 < window_size) 
			max_addr_mode_1 <= 'd1 ;
		else 
			max_addr_mode_1 <= pipe_9_tmp_addr ; 
	end
end


// ======FSM=============

always@(posedge clk , negedge rst_n)begin   //  current_state
	if (!rst_n)begin
		 current_state <= ST_IN ;   //  ST_BUSY  == test_signal 
	end else begin
		 current_state <= next_state ; 
	end
end


always@(*)begin
		case(current_state)
		
			ST_IN : begin
					if (in_valid ||  first_data_flag==0 )
						next_state = ST_IN ;
					else 
						next_state = ST_BUSY ; 
			end
			
			ST_BUSY : begin
				    if (Read_addr_valid & arready_m_inf)
						next_state = ST_Read  ;
					else if (Write_addr_valid  & awready_m_inf & mode_data=='d0)
						next_state = ST_Write ;
					else if (count_write_number == 'd16)
						next_state = ST_IN ; 
					else
						next_state = ST_BUSY ; 
			end
			
			ST_Write : begin
					if (bready_m_inf & bvalid_m_inf)
						// if (mode_data == 0)
							next_state = ST_IN ;
						// else if (count_transport == 'd15 )
							// next_state = ST_IN ; 
						// else 
							// next_state = ST_BUSY ; 
					else
						next_state = ST_Write ; 
			end
			
			ST_Read  : begin
					if (rlast_m_inf && Read_data_ready )
						next_state = ST_IN ; 
					else
						next_state = ST_Read ;
			end
		
			
			default : next_state = ST_IN ; 
		endcase
end

















endmodule
