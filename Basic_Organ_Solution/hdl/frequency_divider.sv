/* 
Frequency divider module. Works by syncing a counter with the DE1-SoC's 50MHz clock 
and oscillates an output clock by inerting the signal whenever the varying max 
counter contition is met. Max count is defined by the switch combination chosen. 
*/
module frequency_divider(CLK_in, CLK_out, 
									reset, CLK_sel); 
	input logic CLK_in, reset; 							// Inputs to module are a 50MHz clock, 
	input logic [2:0] CLK_sel; 							// available reset (~KEY[3]). Output is 
	logic [15:0] count_max;									// new clock frequency 
	output logic CLK_out; 								
	
	always_comb begin											// Sets the maximum counter value based on
		case(CLK_sel)											// switch combinations (combinational logic). 
		3'b000:	count_max = 16'd47801;					// Sets clock frequency to between 523Hz and 
		3'b001:	count_max = 16'd42590;					// 1046Hz (aprox.)
		3'b010:	count_max = 16'd37937;
		3'b011:	count_max = 16'd35815;
		3'b100:	count_max = 16'd31927;
		3'b101:	count_max = 16'd28409;
		3'b110:	count_max = 16'd25330;
		3'b111:	count_max = 16'd23900;
		default  count_max = 16'd47801; 					// can't happen
		endcase
	end
	counter #(16) tone(.CLK_in(CLK_in), 
							.CLK_out(CLK_out), 				// Calls the counter module with a varying 
								.count_max(count_max), 		// max count bus. 
									.reset(reset));			
		
endmodule 

module counter #(parameter N = 16) (CLK_in, CLK_out, // scales output clock by cuctom division, parameterized to be used 
											count_max, reset);	// by LED state machine later. 
	input logic CLK_in, reset; 
	input logic [N - 1:0] count_max; 					// smallest frequency output is 523 Hz,  
																	// meaning clock needs to be divided:
	logic [N - 1:0] zero, count;							// 50,000,000 / (2 * 523) = 47,801 times. 
	output logic CLK_out;  									// Log_2(47,801) is aprox. 16 bits.
	
	assign zero = 0;
	
	always_ff @(posedge CLK_in) begin
		if (reset) begin
			count = zero;
			CLK_out = 1'b0;
		end
		count++; 
		if (count == count_max) begin
			CLK_out = ~CLK_out; 
			count = zero;
		end
	end 
	
endmodule
