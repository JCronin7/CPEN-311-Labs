module s_memory_simulatior(	input logic clk, 
							input logic reset,
							input logic [7:0] data_in, 
							input logic write, 
							input logic [7:0] address, 
							output logic [7:0] q
							); 
				
	logic [7:0] memory [255:0]; 
	
	always_ff @(posedge clk or posedge reset) begin 
		for (int i = 0; i <= 255; i++) begin 
			if (reset) memory[i] = i;//8'b0; <- changed for simulation 
			else 
			if (i == address) begin 
				if (write) begin 
					memory[i] 	<= data_in; 
					q			<= memory[i]; 
				end 
				else 
					q			<= memory[i];
			end 
		end 
	end   
		
endmodule  

