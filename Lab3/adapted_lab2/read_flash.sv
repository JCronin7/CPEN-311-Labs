/* 
	Module to interface with the flash memory instance as well as the audio controller module 
	will read queues from a 22kHz FSM controlling audio and collect data from flash. 			
*/
module read_flash(clk, reset, start_read, request_addr, data_recieved, wait_flag, read_valid, addr_out, data_in, data_out, done, read); 

input logic clk, start_read, wait_flag, read_valid, data_recieved, reset;
input logic [22:0] request_addr;
input logic [31:0] data_in;  
logic [3:0] state; 
output logic done, read; 
output logic [22:0] addr_out; 
output logic [31:0] data_out; 

parameter 	ASSERT_ADDR = 4'b0000, 		// will send address index if wait request flag is low and start flag is high
				READ_DATA   = 4'b0110,		// will collect data provided valid read is high and wait is low
				READ_DONE   = 4'b1010;		// waits for audio_control to register data then returns to wait

assign done = state[3]; 
assign read = state[2]; 

always_ff @(posedge clk or posedge reset) // sequential
begin
	if (reset) state <= ASSERT_ADDR; 
	else 
	case(state)	
	ASSERT_ADDR:	if (start_read) 
						begin addr_out <= request_addr;
						
								state    <= READ_DATA;		
						end
						else  state 	<= ASSERT_ADDR; 
		
	READ_DATA: 		if (read_valid) 
						begin state	 	<= READ_DONE;
								data_out <= data_in;
						end 
						else  state 	<= READ_DATA; 
	READ_DONE: 		if (~wait_flag) state <= ASSERT_ADDR; 
						else 	state 	<= READ_DONE; 
	default state = ASSERT_ADDR; 
	endcase 										
end

endmodule 
