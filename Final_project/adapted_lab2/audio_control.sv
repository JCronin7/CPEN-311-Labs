/*
	This module will take in the data at an address specified by a counter block and
	play the two samples consecutively 
*/
module audio_control	
	(	
	input logic clk, 
	input logic no_audio,
	input logic [1:0] byte_sel, 	// Byte address, used to select which byte of flash data will be played per clock cycle 
	input logic [31:0] data_in,	// Data from flash 
	output logic [7:0] audio 		// Output audio sample 
	); 

always_ff @(posedge clk) begin 	
	casex({no_audio, byte_sel})
		3'b000: 	audio <= data_in[7:0];		// if byte zero, play sample at lowest byte
		3'b001: 	audio <= data_in[15:8];		// if byte one, play sample at middle low byte
		3'b010: 	audio <= data_in[23:16];	// if byte two, play sample at middle high byte
		3'b011: 	audio <= data_in[31:24];	// if byte three, play sample at highest byte
		3'b1xx:	audio <= 8'b10111100; 
		default 	audio <= 8'b10111100; 
	endcase 
end 

endmodule 
