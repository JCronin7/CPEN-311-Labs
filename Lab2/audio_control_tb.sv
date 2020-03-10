module audio_control_tb; 
	logic clk, reset, play_audio, forward; 
	logic [31:0] data_in; 
	logic [7:0] audio; 

	audio_control DUT(clk, reset, audio, data_in, play_audio, forward); 

initial forever begin 
	clk = 1'b0; #5; 
	clk = 1'b1; #5; 
end 
initial begin 
	forward = 1'b1; 
	play_audio = 1'b1; 
	data_in = 32'h12345678;
	reset = 1'b1; #10; 
	reset = 1'b0; 
	#40; 
	play_audio = 1'b0;
#50;
	$stop; 
end 
endmodule
