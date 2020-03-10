module ksa (input CLOCK_50, 
			input [3:0] KEY,
			input [9:0] SW, 
			output [9:0] LEDR, 
			output [6:0] HEX0, 
			output [6:0] HEX1, 
			output [6:0] HEX2, 
			output [6:0] HEX3, 
			output [6:0] HEX4, 
			output [6:0] HEX5
			); 
			
	SevenSegmentDisplayDecoder	toHexDisplay0 (.nIn(secret_key[3:0]), .ssOut(HEX0)); 
	SevenSegmentDisplayDecoder	toHexDisplay1 (.nIn(secret_key[7:4]), .ssOut(HEX1)); 
	SevenSegmentDisplayDecoder	toHexDisplay2 (.nIn(secret_key[11:8]), .ssOut(HEX2)); 
	SevenSegmentDisplayDecoder	toHexDisplay3 (.nIn(secret_key[15:12]), .ssOut(HEX3)); 
	SevenSegmentDisplayDecoder	toHexDisplay4 (.nIn(secret_key[19:16]), .ssOut(HEX4)); 
	SevenSegmentDisplayDecoder	toHexDisplay5 (.nIn(secret_key[23:20]), .ssOut(HEX5)); 

	// Signals used throughout lab 
	logic [24:0] 	secret_key; 
	
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
	
	logic 			clk, reset_n,  
						Smem_write, 
						Tmem_write,
						Umem_write,
						start,
						is_string,
						done;

	assign 			clk 	= CLOCK_50, 
						reset_n = KEY[3];
	
	// Code-breaker implemenation 
	parameter 	DATAPATH = 2'b00, 
					CHECK		= 2'b01,
					RESET		= 2'b10,
					DONE		= 2'b11; 
					
	always_ff @(posedge clk) begin 
		if (~reset_n)	begin 
								secret_key 	<= 14'b0;
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
									LEDR[9:8] <= 2'b11;
								end 
								else
								begin
									reset <= 1'b1; 
									secret_key <= secret_key + 24'd1; 
									state	<= RESET; 
									if (secret_key == 24'hFFFFFF) begin
										LEDR[1:0] <= 2'b11;
										state <= DONE;
									end 
									else begin
										LEDR	<= 10'd0;
										state	<= RESET; 
									end 
								end
							end 
			RESET:		state	<= DATAPATH;
			DONE: 		state <= DONE; 
			default 		state	<= DATAPATH; 
			endcase
	end 
	
	
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
						
	// memory block for task 2a and task 1
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
