module frequency_divider_tb;
	reg CLK_in, reset; 
	reg [2:0] CLK_sel; 
	
	wire CLK_out; 
	
	frequency_divider DUT(CLK_in, CLK_out, reset, CLK_sel); 

	// ** while testing module, clock frequencies were raised much higher so that informative simulations
	// could be seen across smaller time steps
	initial forever begin	
		CLK_in = 1'b0;
		#1;
		CLK_in = 1'b1;
		#1;
	end
	initial begin
		reset = 1'b1;
		#5;
		CLK_sel = 3'b000;
		reset = 1'b0;
		#50;
		CLK_sel = 3'b001; 
		#50;
		CLK_sel = 3'b010; 
		#50;
		CLK_sel = 3'b011; 
		#50;
		CLK_sel = 3'b100; 
		#50;
		CLK_sel = 3'b101; 
		#50;
		CLK_sel = 3'b110; 
		#50;
		CLK_sel = 3'b111; 
		#1000;
		$stop;
	end
endmodule

