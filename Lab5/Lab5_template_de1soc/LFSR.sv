module LFSR #(parameter N = 5)
				(	
				input logic clk, 
				output logic [N - 1:0] lfsr
				); 
	
logic feedback, reset; 	
	
assign feedback = lfsr[0] ^ lfsr[2];
	
// Start-up condition, sets the output to 5'b11111 if it is zero. 
always_comb begin
	if (lfsr == 5'b0)
		reset = 1'b1; 
	else 
		reset = 1'b0; 
end 
	
// Generates the four flip flops that perform the shift operation on posedge of clock 
genvar i;				
generate  
	for (i = N - 1; i > 0; i--) begin : generate_shift_array 
		ff lfsr_ff
			(	
			.clk(clk), 
			.in(lfsr[i]), 
			.reset(reset),
			.out(lfsr[i - 1])
			);
	end 
endgenerate 

// Final ff of LFSR 
ff lfsr_end 
			(	
			.clk(clk), 
			.in(feedback), 
			.reset(reset),
			.out(lfsr[4])
			);
					
endmodule 

// Flip-flop module with reset that drives output high when triggered. 
module ff 
	(	
	input logic clk,
	input logic in, 
	input logic reset, 
	output logic out
	); 

always_ff @(posedge clk or posedge reset) 
	// reset lfsr to a non-zero value if it is zero (start-up)
	if (reset)	out <= 1'b1; 				
	else			out <= in; 

endmodule 
