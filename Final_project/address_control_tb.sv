module address_control_tb; 

logic 	clk, 
		reset, 
		start, 
		next_read,
		done;
logic [23:0] 	start_address,
				end_address; 
logic [24:0]	next_addr;

address_control DUT (	clk,
						reset, 
						start,
						next_read, 
						start_address,
						end_address,
						next_addr,
						done
					); 
initial forever begin 
	clk = 1'b0; #5;
	clk = 1'b1; #5; 
end
initial begin
	start = 1'b1; 
	next_read = 1'b0; 
	reset = 1'b1; #10; 
	reset = 1'b0; 
	start_address = 23'd0; 
	end_address = 23'd3;   
	#30;
	next_read = 1'b1; 
	#90; 
	reset = 1'b1; #10; 
	reset = 1'b0; 
	start_address = 23'd200; 
	end_address = 23'd203; 
	#130;
	$stop; 
	
end 
endmodule 

