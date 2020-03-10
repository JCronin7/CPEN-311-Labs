
module decryptionCore(	input logic clk, 
								input logic reset_n, 
								input logic [24:0] upper_key_bound,
								input logic [24:0] lower_key_bound,
								output logic is_string, 
								output logic core_done, 
								output logic [24:0]	secret_key 
								); 
	// Signals used throughout lab 
	
	logic [7:0] 	Smem_data, 
						Smem_address, 
						Sdata_in,
						Tmem_data, 
						Tmem_address, 
						Tdata_in,
						Umem_data, 
						Umem_address, 
						Udata_in; 
						
	logic [2:0] 	state; 
	
	logic 			Smem_write, 
						Tmem_write,
						Umem_write,
						start,
						done;
						
	assign core_done = state[2]; 

	// Code-breaker implemenation 
	parameter 	DATAPATH = 3'b000, 
					CHECK		= 3'b001,
					RESET		= 3'b010,
					DONE		= 3'b111; 
					
	// SM to test datapath against an incrimenting key, SM has start, end and reset flags which are used throughout 
	always_ff @(posedge clk) begin 
		if (~reset_n)	begin 
								secret_key 	<= lower_key_bound;
								state			<= RESET;
								reset <= 1'b1;
							end
		else 
		case(state)
			DATAPATH:	begin 
								reset <= 1'b0;
								start <= 1'b1; 
								if (done) 
								begin
									start <= 1'b0; 
									state	<= CHECK;
								end 	
								else 
									state	<= DATAPATH; 
							end 
			CHECK: 		begin 
								if (is_string) begin
									state	<= DONE;
								end 
								else
								begin
									reset <= 1'b1; 
									secret_key <= secret_key + 24'd1; 
									state	<= RESET; 
									if (secret_key == upper_key_bound) begin
										state <= DONE;
									end 
									else begin
										state	<= RESET; 
									end 
								end
							end 
			RESET:		state	<= DATAPATH;
			DONE: 		state <= DONE; 
			default 		state	<= DATAPATH; 
			endcase
	end 
	
	// modules which perform the algorithms outlined in tasks 1 and 2 
	masterSM datapath (.clk(clk), 	
							.reset(reset),
							.start(start), 
							.secret_key(secret_key), 
							.Smem_data(Smem_data),
							.Tmem_data(Tmem_data),
							.Umem_data(Umem_data),
							.Smem_write(Smem_write), 
							.Umem_write(Umem_write), 
							.Smem_address(Smem_address),
							.Tmem_address(Tmem_address),
							.Umem_address(Umem_address),
							.Sdata_in(Sdata_in),
							.Udata_in(Udata_in),
							.done(done),
							.is_string(is_string)
							);
						
	// memory block for tasks 1 and 2
	s_memory SmemoryInstance (.address(Smem_address),
										.clock(clk),
										.data(Sdata_in),
										.wren(Smem_write), 
										.q(Smem_data));
										
	encrypt_memory TmemoryInstance (.address(Tmem_address),
										.clock(clk),
										.q(Tmem_data));
									
	decrypt_memory UmemoryInstance (.address(Umem_address),
										.clock(clk),
										.data(Udata_in),
										.wren(Umem_write), 
										.q(Umem_data));
endmodule 
