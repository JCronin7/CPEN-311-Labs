module audio_control_tb; 
logic 	clk, 
		no_audio;
logic [1:0] byte_sel; 
logic [7:0] audio; 
logic [31:0] data_in;

audio_control DUT (	clk,  
						no_audio, 
						byte_sel, 
						data_in,
						audio 
					); 
initial forever begin 
	byte_sel += 1'b1; 
	clk = 1'b0; #5;
	clk = 1'b1; #5; 
end
initial begin 
	byte_sel = 2'b00; 
	no_audio = 1'b0; 
	data_in = 32'h99775533; 
	#40;
	no_audio = 1'b1; #20; 
	no_audio = 1'b0; #20; 
	data_in = 32'hddccbbaa; 
	#40; 
	data_in = 32'h12345678; 
	#100; 
	$stop; 
end 
endmodule 

