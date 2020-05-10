module address_control  
	(
	input logic clk,
	input logic reset, 	// Signal used by Picoblaze to resset the SM
	input logic start,	// Signal remains high at all times 
	input logic next_read, // enable bit, used to pause speech and increment byte address
	input logic [23:0] start_address,	// Start address specified by narrator_ctrl
	input logic [23:0] end_address,	// End address specified by narrator_ctrl
	output logic [24:0] next_addr,	// The byte address of the sample being played
	output logic done	// Done flag for Picoblaze 
	);  

logic [1:0] state; 	// State signal 

parameter 	START = 2'b00, 
				INC 	= 2'b01,
				CHECK	= 2'b10, 
				DONE 	= 2'b11; 

assign 		done 	= &state; // Done Signal is high in the DONE state only 

always @(posedge clk or posedge reset) begin 
	if	(reset)		state			<= START; 		// reset condition 
	else 
	case (state) 
		START:	begin 
						next_addr 	<= {1'b0, start_address}; 	// On reset, begin byte counter at start address 
						if (start)
							state 	<= INC; 	// While start is high, begin state transitions 
						else 
							state		<= START; // Otherwise remain in START
					end 
		INC:		if (next_read) begin
						next_addr 	<= next_addr + 1'b1; // increment address given speech isn't paused and the 7.2KHz clock is high
						state		 	<= CHECK;	
					end 
					else 
						state		 	<= INC; 
		CHECK:	if (next_addr == end_address + 1'b1)	// if address exceeds end address, halt increment and goto DONE
						state		 	<= DONE; 
					else 	
						state		 	<= INC; 
		DONE:    	state 		<= DONE; // wait for picoblaze to reset the SM
	default 			state 		<= START; 
	endcase 
end 

endmodule 
