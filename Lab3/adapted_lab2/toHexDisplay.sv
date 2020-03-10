module toHexDisplay(number_in, diplay0, diplay1, diplay2, diplay3, diplay4, diplay5);  
	input logic [31:0] number_in; 
	output logic [6:0] diplay0, 
							 diplay1, 
							 diplay2, 
							 diplay3, 
							 diplay4, 
							 diplay5;
endmodule 

module convertion(hex_dig, conv);
	input logic [3:0] hex_dig; 
	output logic 
always_comb begin
	if (hex_dig == 4'b0) conv = 7'b1111111;
	case
endmodule 