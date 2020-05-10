module audio_intensity_tb; 

logic 	clk, 
		reset;

logic [7:0] audio_data,
			intensity; 
		
 audio_intensity DUT
	(
	.clk(clk), 
	.reset(reset), 
	.audio_data(audio_data), 
	.intensity(intensity)
	);

initial forever begin 
	clk = 1'b0; #1; 
	clk = 1'b1; #1; 
end	

initial forever begin 
	#4; 
	audio_data += 1'b1; 
end

initial begin 
	DUT.sum_upper = 8'b0; 
	DUT.prev_sample = 8'b0; 
	DUT.increment = 8'b0; 
	audio_data = 8'b0; 
	reset = 1'b1; #2; 
	reset = 1'b0; 
	#5000;
	$stop; 
end 

endmodule 
