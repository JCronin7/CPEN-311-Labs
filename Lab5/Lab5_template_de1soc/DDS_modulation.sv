module DDS_modulation
	(
	input logic clk,
	input logic [1:0] RBG,
	input logic [31:0] word_interrupt, 
	input logic [11:0] sine, 
	input logic [11:0] cosine, 
	input logic [11:0] square, 
	input logic [11:0] saw,
	input logic [2:0] channel0_select,
	input logic [1:0] channel1_select,
	output logic [31:0] phase_inc_word,
	output logic [11:0] channel0_data,
	output logic [11:0] channel1_data
	); 
// sine and cosine with negative amplitude 
logic [11:0] sine_n, 
				 cosine_n; 
				
// Default phase_inc word to waveform_gen, corresponds to 3-Hz carrier. 	
parameter	DEFAULT = 32'd258; 
	
// Sine wave of negative amplitude relatve to waveform_gen output. 
assign 		sine_n = ~sine + 12'd1, 
				cosine_n = ~cosine + 12'd1;

// Multiplexers to select the channel outputs based on VGA button selections 
always @(posedge clk) begin 
	// performs the different modulations by manipulating oscilliscope data and phase_in word 
	case(channel0_select) 
		3'b000:	begin channel0_data = RBG[0] ? sine : 12'b0;	
							phase_inc_word = DEFAULT; 
					end 
		3'b001:	begin channel0_data = sine; 
							phase_inc_word = word_interrupt; 
					end
		3'b010:	begin channel0_data = RBG[0] ? sine : sine_n; 
							phase_inc_word = DEFAULT;
					end 
		3'b011:	begin channel0_data = {~RBG[0], 11'b0};
							phase_inc_word = DEFAULT;
					end 
		3'b100:  begin phase_inc_word = DEFAULT;
							case(RBG)
								2'b00: 	channel0_data = cosine_n; 
								2'b01: 	channel0_data = sine_n;
								2'b10: 	channel0_data = cosine;
								2'b11: 	channel0_data = sine;
							default 	 	channel0_data = cosine_n;
							endcase 
					end 
	default 		begin channel0_data = RBG[0] ? sine : 12'b0;	
							phase_inc_word = DEFAULT; 
					end 
	endcase 
	// Selects the signal output to be displayed depending on button selection 
	case(channel1_select)
		2'b00:	channel1_data = sine;
		2'b01:	channel1_data = cosine; 
		2'b10:	channel1_data = saw;
		2'b11:	channel1_data = square;
	default 		channel1_data = sine;
	endcase 
end 

endmodule 
