//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 3) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D 
);

// ===============================================================
// Declaration
// ===============================================================
input  [WIDTH-1:0]   IN_P, IN_Q;
input  [WIDTH*2-1:0] IN_E;
output [WIDTH*2-1:0] OUT_N, OUT_D;
// reg [WIDTH*2-1:0] OUT_D ;

// ===============================================================
// Soft IP DESIGN
// ===============================================================


genvar k ; 

generate
	assign OUT_N = IN_P * IN_Q ;
	wire [WIDTH*2-2:0] phi_N ;
	assign phi_N = (IN_P - 1) * (IN_Q - 1) ;

	for (k=0 ; k<= (2*WIDTH) ; k=k+1) begin : gen_d_level
		if (k == 0) begin :if_lev1 
			wire [WIDTH*2-2:0]r ; 
			wire t ; 
			assign t = 0 ;
			assign r = phi_N ;
		end else if (k==1) begin :if_lev1 
			wire [WIDTH*2-2:0]r ;
			wire t ; 
			assign t = 1 ;
			assign r = IN_E ;
		end else if (k == (2*WIDTH)) begin : if_lev1
			assign OUT_D =(gen_d_level[(2*WIDTH)-1].if_lev1.t > 0 ) ? gen_d_level[(2*WIDTH)-1].if_lev1.t : gen_d_level[(2*WIDTH)-1].if_lev1.t + phi_N; 
		end else begin : if_lev1 
			wire [WIDTH*2-2:0]r ;
			wire [4:0]quotient ; 
			wire signed [WIDTH*2-1:0] t ;
			
			assign quotient = gen_d_level[k-2].if_lev1.r  /  gen_d_level[k-1].if_lev1.r ; 
			assign t = (gen_d_level[k-1].if_lev1.r ==1)? gen_d_level[k-1].if_lev1.t         : gen_d_level[k-2].if_lev1.t  - quotient * gen_d_level[k-1].if_lev1.t ;
			assign r = (gen_d_level[k-1].if_lev1.r ==1)? 1 									: gen_d_level[k-2].if_lev1.r  - quotient * gen_d_level[k-1].if_lev1.r ;

		end 
	end

	
endgenerate


// generate
	// assign OUT_N = IN_P * IN_Q ;
	// wire [WIDTH*2-1:0] phi_N ;
	// assign phi_N = (IN_P - 1) * (IN_Q - 1) ;

	// for (k=0 ; k<= (2*WIDTH+1) ; k=k+1) begin : gen_d_level
		// wire [WIDTH*2-1:0]r , quotient ; 
		// wire signed [WIDTH*2:0] t ;
		// wire [WIDTH*2-1:0] tmp_D  ;
		// if (k == 0) begin 
			// assign t = 0 ;
			// assign r = phi_N ;
		// end else if (k==1) begin 
			// assign t = 1 ;
			// assign r = IN_E ;
		// end else if (k > 1) begin 
			// assign quotient = gen_d_level[k-2].r  /  gen_d_level[k-1].r ; 
			// assign t = (gen_d_level[k-1].r ==1)? gen_d_level[k-1].t         : gen_d_level[k-2].t  - quotient * gen_d_level[k-1].t ;
			// assign r = (gen_d_level[k-1].r ==1)? 1 							: gen_d_level[k-2].r  - quotient * gen_d_level[k-1].r ;
			
			// assign tmp_D = (gen_d_level[k-1].t > 0 )? gen_d_level[k-1].t : gen_d_level[k-1].t + phi_N ; 

		// end
	// end
	
	// assign OUT_D = gen_d_level[(2*WIDTH) +1].tmp_D; 

	
// endgenerate

endmodule
