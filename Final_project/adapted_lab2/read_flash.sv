/* 
	Module to interface with the flash memory instance as well as the audio controller module 
	will read queues from a 7.2kHz FSM controlling audio and collect data from flash. 			
*/
module read_flash	
	(	
	input logic clk, 
	input logic reset, 
	input logic start_read, 			// start signal 
	input logic [22:0] request_addr, // requested addess from conroller
	input logic data_recieved, 		// data recieved flag, not used in this instance 
	input logic wait_flag, 				// input from flash 
	output logic [22:0] addr_out, 	// output address for flash memory
	input logic [31:0] data_in, 		// data returned from flash 
	output logic [31:0] data_out, 	// data sent to audio 
	output logic done, 					// done flag
	output logic read						// read flag for flash 
	); 
 
logic [3:0] state; 

parameter 	ASSERT_ADDR = 4'b0000, 		// will send address index if wait request flag is low and start flag is high
				READ_DATA   = 4'b0110,		// will collect data provided valid read is high and wait is low
				READ_DONE   = 4'b1010;		// waits for audio_control to register data then returns to wait

assign 		done = state[3]; 
assign 		read = state[2]; 

always_ff @(posedge clk or posedge reset) // sequential
begin
	if (reset) 				state 	<= ASSERT_ADDR; // If reset occures, return to first state 
	else 
	case(state)	
	ASSERT_ADDR:	if (start_read) begin 
								addr_out <= request_addr;// If start is initiated, asser address and read flag
								state    <= READ_DATA;		
						end
						else  state 	<= ASSERT_ADDR; 
	READ_DATA: 		begin state	 	<= READ_DONE;	// Flash is known to take one cycle to return data, so we 
								data_out <= data_in;		// ouput after one posedge 
						end 
	READ_DONE: 		if (~wait_flag) state <= ASSERT_ADDR; // Once flash memory lowers wait flag, return to start 
						else 	state 	<= READ_DONE; 
	default 					state 	<= ASSERT_ADDR; // default condition 
	endcase 										
end

endmodule 
