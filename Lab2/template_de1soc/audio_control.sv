/*
	This module will take in the data at an address specified by a counter block and
	play the two samples consecutively 
*/
module audio_control(clk, reset, audio, data_in, play_audio, forward); 
	
input logic clk, reset, play_audio, forward;
input logic [31:0] data_in;
logic state; 
output logic [7:0] audio; 

parameter PLAY_LOW   = 1'b0; // play first 8-bit sample
parameter PLAY_HIGH  = 1'b1; // play second 8-bit sample 


always_ff @(posedge clk or posedge reset) begin 
	if (reset) begin state <= PLAY_LOW;			// State machine reset condition 
						  audio <= data_in[15:8]; 
				  end
	else if (forward & play_audio) 				// if forward direction is specified, play low then high 
		case(state)
			PLAY_LOW:	begin audio <= data_in[15:8];
									state <= PLAY_HIGH; 
							end
			PLAY_HIGH:  begin audio <= data_in[31:24];
									state <= PLAY_LOW; 
							end
			default state = PLAY_LOW; 
		endcase 
	else if (~forward & play_audio)				// play high then low if ~forward 
		case(state)
			PLAY_HIGH:  begin audio <= data_in[31:24];
									state <= PLAY_LOW; 
							end
			PLAY_LOW:	begin audio <= data_in[15:8];
									state <= PLAY_HIGH; 
							end
			default state = PLAY_HIGH; 
		endcase 
end 

endmodule 
