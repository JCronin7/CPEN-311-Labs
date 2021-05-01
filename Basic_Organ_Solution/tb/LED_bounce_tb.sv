module LED_bounce_tb; 
		logic CLK_50M, reset; 
		logic [24:0] count_max;
		logic [7:0] LEDR; 
		
		LED_bounce DUT(CLK_50M, count_max, reset, LEDR);
		
		initial forever begin			// teesting LED bounce module, waveform should show LED bus 
		CLK_50M = 1'b0; #1; 						// as a shifting one hot code from left to rigt and bac over time 
		CLK_50M = 1'b1; #1; 
		end 
		initial begin 
		reset = 1'b1; #5; 
		reset = 1'b0; 
		#100; 
		$stop; 
		end 
		
endmodule 
