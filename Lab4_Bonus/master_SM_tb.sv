module masterSM_tb;
	logic clk, reset, start, wren;
	// memory signals 
	// working:
	logic [7:0] data, q, address;
				
	masterSM DUT(clk, reset, start, q, wren, data, address); 
	
	initial forever begin 
		clk = 1'b0; #5; 
		clk = 1'b1; #5; 
	end
	initial forever begin 
		#30; 
		q = q + 8'd1;  
	end      
	initial begin 
		q = 8'd0; 
		reset = 1'b1; #1; 
		reset = 1'b0; 
		start = 1'b1; 
		#10000; 
		$stop; 
	end 
endmodule 
 
