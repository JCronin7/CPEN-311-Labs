// Module to sum 256 samples and output average to LEDs 
module audio_intensity
	(	
	input logic clk, // Syncronized to audio clock, so we can assume a new sample has been passed at each incrememt
	input logic reset, 			
	input logic [7:0] audio_data, // current audio data
	output logic [7:0] intensity	// output average magnitude
	); 

logic [1:0] 	state; // state variable 
logic [7:0]		prev_sample,	// additional module inputs and outputs 
					increment,
					abs_val,
					sum_upper; 

logic [15:0] 	sum; // 16-bit sum of samples, taking upper byte is the same as division by 256

parameter 		CHECK = 2'b00, // List of states 
					INC	= 2'b01, 
					PRINT = 2'b10; 
					
always_ff @(posedge clk or posedge reset) begin 
	if (reset)	begin			// Reset condition
						state 		<= CHECK; 
						sum 			<= 16'b0; 
						increment 	<= 8'b0; 
					end 
	else 
	case (state)
		CHECK:	begin 
						increment 	<= increment + 1'b1; // Increment couner when SM starts
						state			<= INC; 
					end
		INC:		begin 
						sum 			+= abs_val;	// add absolute value of sample to sum
						if (&increment)
							state 	<= PRINT; 
						else 
							state 	<= CHECK; 
					end 
		PRINT: 	begin 	
						sum_upper 	<= sum[15:8];	// Take upper bits of sum when counter reached 255
						sum 			<= 16'b0;  // reset sum 
						state 		<= CHECK; 
					end 
	default			state 		<= CHECK; 
	endcase
end  
			
reverse_bits reverse
		(
		.in(sum_upper),
		.out(intensity)
		);
		
absolute_value take_abs
		(
		.in(audio_data),
		.out(abs_val)
		);
		
endmodule 

// Identifies most significant bit and maps magnitude to LEDs accordingly 
module reverse_bits
	(	
	input logic [7:0] in, 
	output logic [7:0] out
	);

always_comb
	casex(in)
		8'b1xxxxxxx:	out <= 8'd255;
		8'b01xxxxxx:	out <= 8'd254;
		8'b001xxxxx:	out <= 8'd252;
		8'b0001xxxx:	out <= 8'd248;
		8'b00001xxx:	out <= 8'd240;
		8'b000001xx:	out <= 8'd224;
		8'b0000001x:	out <= 8'd192;
		8'b00000001:	out <= 8'd128;
	default out <= 8'b0; 
	endcase
endmodule 

// Checks if the most significant bit is high (negative number), and performs 2s compliment sign flip 
module absolute_value		
	(	
	input logic [7:0] in, 
	output logic [7:0] out
	);
	
always_comb 
	if(in[7])	out <= ~in + 1'b1; 
	else			out <= in; 
	
endmodule 	