module LFSR_tb; 
logic [4:0] lfsr; 
logic clk; 

// Checks to see if output sequencse matches the waveform provided. 
LFSR #(5) DUT(clk, lfsr);

initial forever begin 
	clk = 1'b0; #5; 
	clk = 1'b1; #5; 
end 
// Initialize LFSR to zero to simulate start-up. 
initial begin
	DUT.lfsr = 5'b0;
	#1000; 
	$stop; 
end 

endmodule 

