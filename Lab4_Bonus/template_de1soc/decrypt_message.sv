module decryptMessage(	input logic clk, 
								input logic reset, 
								input logic start, 
								input logic [7:0] S_q,
								input logic [7:0] T_q,
								input logic [7:0] U_q, 
								output logic done, 
								output logic is_string, 
								output logic S_write, 
								output logic U_write, 
								output logic [7:0] S_address,
								output logic [7:0] T_address,
								output logic [7:0] U_address,
								output logic [7:0] S_data,
								output logic [7:0] U_data
								); 

	logic [7:0] i, j, f, f_ind, 
					si, sj, tk, 
					data_out; 
	logic [6:0] state;
	logic [4:0] k; 
	logic [1:0] wait_count; 
	
	parameter 	START			= 7'b0000000,	
					GET_DATA_i  = 7'b0000001,
					WAIT1			= 7'b0000010,
					SET_j			= 7'b0000011,
					GET_DATA_j 	= 7'b0000100,
					WAIT2			= 7'b0000101,
					STORE_i		= 7'b0010110, 
					WAIT3			= 7'b0010111,
					STORE_j		= 7'b0011000, 
					WAIT4			= 7'b0011001,
					SET_f			= 7'b0001010,
					GET_DATA_f 	= 7'b0001011,
					WAIT5			= 7'b0001100, 
					GET_DATA_k  = 7'b0001101,
					WAIT6			= 7'b0001110, 
					DECRYPT		= 7'b0001111,
					STORE_k		= 7'b0101111, 
					WAIT7			= 7'b0100000,
					INC_k			= 7'b1000000,
					VALIDATE	= 7'b1000001;
	
	assign 	S_write = state[4],
				U_write = state[5];
	
	always_ff @(posedge clk) begin 
		if (reset)	begin 
							state <= START; 
							is_string <= 1'b0; 
							i <= 8'b0;
							j <= 8'b0;
							f <= 8'b0;
							f_ind <= 8'b0;
							k <= 5'b0; 
							wait_count <= 2'b0; 
							done	<= 1'b0;
						end 
		else 
		case(state) 
			START:		if (start & ~done) 
							begin 
								state <= GET_DATA_i; 
								i ++; 
							end 
							else 
							begin 
								state <= START; 
								i = 8'b0; 
							end 
			GET_DATA_i: begin 
								S_address <= i; 
								state <= WAIT1; 
							end  
			WAIT1:		if (wait_count == 2'd2) 
							begin 			
								state <= SET_j;	
								wait_count <= 2'd0; 
								si <= S_q;
							end 
							else 	
							begin 	
								state <= WAIT1;	
								wait_count ++; 
							end 
			SET_j: 		begin 
								j <= j + si; 
								state <= GET_DATA_j;
							end 
			GET_DATA_j: begin			  
								S_address <= j; 
								state <= WAIT2; 
							end  
			WAIT2: 		if (wait_count == 2'd2) 
							begin 			
								state <= STORE_i;	
								wait_count <= 2'd0; 
								sj <= S_q;
							end 
							else 
							begin 		
								state <= WAIT2;	
								wait_count ++; 
							end 
			STORE_i:		begin 		  
								S_address <= i;
								S_data  <= sj; 
								state <= WAIT3; 
							end 
			WAIT3: 		if (S_q == sj) 
								state <= STORE_j; 
							else 
								state <= WAIT3; 
			STORE_j:    begin 			  
								S_address <= j;
								S_data <= si; 
								state <= WAIT4; 
							end  
			WAIT4:		if (S_q == si)
								state <= SET_f; 
							else 
								state <= WAIT4;
			SET_f:		begin 
								f_ind <= si + sj; 
								state <= GET_DATA_f;
							end
			GET_DATA_f: begin 
								S_address <= f_ind; 
								state <= WAIT5; 
							end  
			WAIT5:		if (wait_count == 2'd2) 
							begin 			
								state <= GET_DATA_k;	
								wait_count <= 2'd0; 
								f <= S_q;
							end 
							else 	
							begin 	
								state <= WAIT5;	
								wait_count ++; 
							end 
			GET_DATA_k: begin 
								T_address <= k; 
								state <= WAIT6; 
							end  
			WAIT6:		if (wait_count == 2'd2) 
							begin 			
								state <= DECRYPT;	
								wait_count <= 2'd0; 
								tk <= T_q;
							end 
							else 	
							begin 	
								state <= WAIT6;	
								wait_count ++; 
							end 
			DECRYPT: 	begin 
								data_out <= f ^ tk; 
								state <= VALIDATE; 
							end 
			VALIDATE:	if (((data_out >= 8'd97) & (data_out <= 8'd122)) | (data_out == 8'd32))
							begin 
								state	<= STORE_k; 
								is_string <= 1'b1; 
							end 
							else 
							begin 
								done <= 1'b1; 
								is_string <= 1'b0; 
								state <= START; 
							end 
			STORE_k:		begin 			  
								U_address <= k;
								U_data <= data_out; 
								state <= WAIT7; 
							end  
			WAIT7:		if (U_q == data_out)
								state <= INC_k; 
							else 
								state <= WAIT7;
			INC_k:		begin 
								k ++; 
								state	<= START;
								if (k == 5'b0) 
									done = 1'b1; 
								else 	
									done = 1'b0; 
							end
		default 			state <= START;
		endcase
	end 
	
endmodule 
