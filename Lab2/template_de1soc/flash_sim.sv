module flash_sim(clk, address, wait_req, read, read_data, read_valid);
	input logic clk, read; 
	input logic [23:0] address; 
	logic state; 
	logic [32:0] data; 
	output logic wait_req, read_valid; 
	output logic [32:0] read_data; 

parameter state1 = 1'b0;
parameter state2 = 1'b1; 

always_ff @(posedge clk) begin
case(state) 
	state1: begin 	wait_req <= 1'b0; 
					read_valid <= 1'b0;
					if (read)
						state <= state2; 
					else 
						state <= state1; 
			end 
	state2: begin 	read_valid <= 1'b1; 
					if (read) begin 
						read_data <= data; 
						state <= state1; 
					end 
			end 
	default state <= state1; 
endcase
end 
always_comb begin
case(address)
	23'd0:	data = 32'd424567;
	23'd1:	data = 32'd992345;
	23'd2:	data = 32'd100234;
	23'd3:	data = 32'd523456;
	23'd4:	data = 32'd223546;
	23'd5:	data = 32'd982345;
	23'd6:	data = 32'd602345;
	23'd7:	data = 32'd404586;
	23'd8:	data = 32'd696420;
	default data = 32'd400000; 
endcase
end
endmodule 
