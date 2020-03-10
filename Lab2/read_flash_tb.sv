module read_flash_tb; 
	logic clk, start, wait_flag, 
			read_valid, recieved, reset; 
				//slow_clk, reset ;
	logic [22:0] addr;
	logic [31:0] data; 
	 
	logic done, read; 
	logic [22:0] addr_out; 
	logic [31:0] data_out;// audio; 
	
	read_flash DUT(clk, reset, start, addr, recieved, wait_flag, read_valid, addr_out, data, data_out, done, read); 
	
	flash_sim flash_mem(clk, addr_out, wait_flag, read, data, read_valid);
	
	//audio_control control(slow_clk, reset, audio, start, addr, data_out, recieved, done);

initial forever begin 
clk = 1'b0; #1; 
clk = 1'b1; #1; 
end 
/*initial forever begin 
slow_clk = 1'b0; #20; 
slow_clk = 1'b1; #20;  
end*/
initial begin
	reset = 1'b1;
	start = 1'b1; 
	addr = 23'd1; 
	recieved = 1'b0; 
	#2;
	reset = 1'b0; 
	#20; 
	/*if (data_out == 8'd99) begin 
		recieved = 1'b1; 
		start = 1'b0; 
	end
	*/
	#10; 
	$stop;  
end 
endmodule 