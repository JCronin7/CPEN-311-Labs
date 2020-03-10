module writeToMem_tb;

	 logic clk, reset, start, write, done;			
	 logic [7:0] address, data, q;		
	
	writeToMem DUT (clk, reset, start, q, write, done, address, data); 
	s_memory_simulatior s_memory (clk, data, write, address, q);
	
	initial forever begin 
		clk = 1'b0; #5; 
		clk = 1'b1; #5; 
	end
	initial begin 
		reset = 1'b1; #10; 
		reset = 1'b0; 
		start = 1'b1; 
		#1000; 
		$stop; 
	end 
endmodule 

	