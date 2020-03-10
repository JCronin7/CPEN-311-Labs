module s_memory_simulatior_tb; 
	logic clk, write, reset; 
	logic [7:0] data_in, address, q; 
	
	s_memory_simulatior DUT(clk, reset, data_in, write, address, q); 
	
	initial forever begin 
		clk = 1'b0; #5; 
		clk = 1'b1; #5; 
	end 
	initial begin 
		reset = 1'b1; #10
		reset = 1'b0; 
		data_in = 8'd3; 
		address = 8'b0;
		write = 1'b1; 
		#20; 
		#50; 
	$stop; 
	end 
	
endmodule 
