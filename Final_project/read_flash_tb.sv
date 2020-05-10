module read_flash_tb; 

logic 	clk, 
		read,
		wait_req, 
		read_valid,
		read_done;

logic [23:0] 	address, 
				address_to_mem; 

logic [31:0] 	read_data,
				data_out; 

s_memory_simulatior memory 
	(
	.clk(clk), 
	.reset(1'b0),
	.address(address_to_mem), 
	.write(~read), 
	.q(read_data)
	); 
	
read_flash DUT
	(
	.clk(clk),
	.reset(1'b0),   
	.start_read(1'b1), 
	.request_addr(address), 
	.wait_flag(1'b0), 
	.addr_out(address_to_mem), 
	.data_in({16'b0,read_data}),
	.data_out(data_out),
	.done(read_done),
	.read(read)
	); 
	
initial forever begin 
	clk = 1'b0; #1; 
	clk = 1'b1; #1; 
end

initial begin 
	address = 24'd0; #20; 
	address = 24'd1; #20; 
	address = 24'd2; #20; 
	address = 24'd3; #20; 
	address = 24'd4; #20; 
	address = 24'd5; #20; 
	address = 24'd6; #20; 
	address = 24'd7; #20; 
	address = 24'd8; #20; 
	#100; 
	$stop; 
end 

endmodule 
