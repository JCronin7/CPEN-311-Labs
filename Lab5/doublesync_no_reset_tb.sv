module doublesync_no_reset_tb; 

logic 	in_clk, 
		out_clk,
		clk; 

doublesync_no_reset DUT 
	(
	.indata(in_clk), 
	.outdata(out_clk), 
	.clk(clk)
	); 
	
initial forever begin 
	clk = 1'b0; #5;
	clk = 1'b1; #5; 
end 

initial forever begin 
	in_clk = 1'b0; #30; 
	in_clk = 1'b1; #30; 
end 

initial begin 
	#1000; 
	$stop; 
end 

endmodule 


