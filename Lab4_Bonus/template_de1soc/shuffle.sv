module shuffle(input logic clk, 				// SM clock
					input logic reset, 			// reset bit
					input logic start,			// start signal for control 
					input logic [23:0] secret_key,
					input logic [7:0] q, 		// data output from memory, used to verify successful write
					output logic write,			// write flag
					output logic done,			// done flag
					output logic [7:0] address,// address to write data to 
					output logic [7:0] data		// data to address, for task one this will be equal to address 
					);   
					
	logic [7:0] i, j,  
					secret_byte, 
					si, sj; 
	logic [4:0] state; 
	logic [1:0] wait_count; 		// adds cycles to wait states to ensure successful reads
	
	parameter 	START 		= 5'b00000, 
					GET_DATA_i 	= 5'b00001,
					WAIT1 		= 5'b01001,
					SET_j			= 5'b00010,
					GET_DATA_j 	= 5'b00011,
					WAIT2			= 5'b01010,
					STORE_i		= 5'b10110, 
					WAIT3			= 5'b11011,
					STORE_j		= 5'b10111, 
					WAIT4			= 5'b11100,
					INC_i			= 5'b01000;
					
	assign write = state[4]; 
	
	moduloOnSecretKey returnByte(.clk(clk), .i(i), .secret_key(secret_key), .byte_out(secret_byte));
	
	always_ff @(posedge clk) begin  
		if (reset) 	begin	
							state <= START; 
							j <= 8'b0; 
							i <= 8'b0; 
							sj <= 8'b0; 
							si <= 8'b0; 
							wait_count <= 2'b0; 
							done <= 1'b0;
						end 
		else 
		case(state) 
			START:		if (start & ~done)	
								state <= GET_DATA_i; 
							else 						
								state <= START; 
			GET_DATA_i: begin
								address <= i; 
								state <= WAIT1; 
							end  
			WAIT1:		if (wait_count == 2'd2) 
							begin 			
								state <= SET_j;	
								wait_count <= 2'd0; 
								si <= q;
							end 
							else 	
							begin 	
								state <= WAIT1;	
								wait_count ++; 
							end 
			SET_j: 		begin 					
								j <= j + si + secret_byte; 
								state <= GET_DATA_j;
							end 
			GET_DATA_j: begin			  
								address <= j; 
								state <= WAIT2; 
							end  
			WAIT2: 		if (wait_count == 2'd2) 
							begin 			
								state <= STORE_i;	
								wait_count <= 2'd0; 
								sj <= q;
							end 
							else 
							begin 		
								state <= WAIT2;	
								wait_count ++; 
							end 
			STORE_i:		begin 		  
								address <= i;
								data  <= sj; 
								state <= WAIT3; 
							end 
			WAIT3: 		if (q == sj)
								state <= STORE_j; 
							else 
								state <= WAIT3; 
			STORE_j:    begin 			  
								address <= j;
								data <= si; 
								state <= WAIT4; 
							end 
			WAIT4:		if (q == si)
								state <= INC_i; 
							else 
								state <= WAIT4; 
			INC_i:		begin 
								i ++; 
								state	<= START;
								if (i == 8'b0) 
									done = 1'b1; 
								else 	
									done = 1'b0; 
							end
		default 				state <= START; 
		endcase
	end 
	
endmodule 

module moduloOnSecretKey(	input logic clk, 
									input logic [7:0] i, 
									input logic [23:0] secret_key, 
									output logic [7:0] byte_out
									);
	logic [1:0] result; 

	assign result = i % 2'd3; 

	always_ff @(posedge clk) begin 
		case(result)
			2'b00:  byte_out[7:0] = secret_key[23:16];
			2'b01:  byte_out[7:0] = secret_key[15:8];
			2'b10:  byte_out[7:0] = secret_key[7:0];
			default byte_out[7:0] = 8'b0; 
		endcase 
	end 
	
endmodule 
