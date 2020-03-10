module writeToMem (input logic clk, 				// SM clock
							input logic reset, 			// reset bit
							input logic start,			// start signal for control 
							input logic [7:0] q, 		// data output from memory, used to verify successful write
							output logic write,			// write flag
							output logic done,			// done flag
							output logic [7:0] address,// address to write data to 
							output logic [7:0] data		// data to address, for task one this will be equal to address 
							);          
	// State variable 
	logic [1:0] state; 						
	logic delay;
	
	// Possible states
	parameter 	START 	= 2'b00,	
					WRITEMEM = 2'b01, 
					CHECKW  	= 2'b10;
	
	assign 		write = state[0];
	
always_ff @(posedge clk) begin 
	if (reset) 	begin 
						state 	<= START; 
						address 	<= 8'b0;
						delay 	<= 1'b0; 
						done		<= 1'b0;	
						data		<= 8'b0; 
					end
	else 
	case(state) 
		START: 			if (start & ~done)	
							begin 
								state <= WRITEMEM;
								delay <= 1'b0; 
							end 
							else 			
								state <= START; 
		// used to write data to s_memory 
		WRITEMEM: 	if (delay) 	
								begin 
								delay <= 1'b0; 
								state <= CHECKW;
								end 
							else 		
								begin 
								delay ++; 
								state <= WRITEMEM; 
								end  
		// for task 1, populates s_memory 
		CHECKW: 	if (q == data)  
								begin 
								address ++; 
								data <= address; 
								if (address == 8'b0) 
									begin 
									done <= 1'b1; 
									state <= START;
									end 
								end 
							else 
								state <= WRITEMEM;
		default 				state <= START; 
	endcase
end 

endmodule 
