module frequency_divider(CLK_in, CLK_out, reset, CLK_sel); 
	input CLK_in, reset; 
	input [2:0] CLK_sel; 
	reg [15:0] count_max;
	output CLK_out; 
	
	always @(*) begin
		case(CLK_sel)
		3'b000:	count_max = 16'd47;
		3'b001:	count_max = 16'd42590;
		3'b010:	count_max = 16'd37937;
		3'b011:	count_max = 16'd35815;
		3'b100:	count_max = 16'd31927;
		3'b101:	count_max = 16'd28409;
		3'b110:	count_max = 16'd25330;
		3'b111:	count_max = 16'd23900;
		default  count_max = 16'd47801; 	// can't happen
		endcase
	end
	counter tone(CLK_in, CLK_out, count_max, reset);
		
endmodule 

module counter(CLK_50M, CLK_out, count_max, reset);
	input CLK_50M, reset; 
	input [15:0] count_max; 	// smallest frequency output is 523 Hz, meaning clock needs to be divided: 
									   // 50,000,000 / (2 * 523) = 47,801 times. Log_2(47,801) is aprox. 16 bits. 
	reg [15:0] count; 
	output reg CLK_out; 
	
	always @(posedge CLK_50M) begin
		count = reset ? 16'b0 : count;
		CLK_out = reset ? 1'b0 : CLK_out; 
		count = count + 1'b1; 
		if (count == count_max) begin
			CLK_out = ~CLK_out; 
			count = 16'b0;
		end
	end 
	
endmodule
