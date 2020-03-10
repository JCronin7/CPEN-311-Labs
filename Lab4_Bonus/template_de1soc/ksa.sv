module ksa (input CLOCK_50, 
				input [3:0] KEY,
				input [9:0] SW, 
				output [9:0] LEDR, 
				output [6:0] HEX0, 
				output [6:0] HEX1, 
				output [6:0] HEX2, 
				output [6:0] HEX3, 
				output [6:0] HEX4, 
				output [6:0] HEX5
				); 
			
	// displays secret key search and correct key when found 
	SevenSegmentDisplayDecoder	toHexDisplay0 (.nIn(secret_key[3:0]), .ssOut(HEX0)); 
	SevenSegmentDisplayDecoder	toHexDisplay1 (.nIn(secret_key[7:4]), .ssOut(HEX1)); 
	SevenSegmentDisplayDecoder	toHexDisplay2 (.nIn(secret_key[11:8]), .ssOut(HEX2)); 
	SevenSegmentDisplayDecoder	toHexDisplay3 (.nIn(secret_key[15:12]), .ssOut(HEX3)); 
	SevenSegmentDisplayDecoder	toHexDisplay4 (.nIn(secret_key[19:16]), .ssOut(HEX4)); 
	SevenSegmentDisplayDecoder	toHexDisplay5 (.nIn(secret_key[23:20]), .ssOut(HEX5)); 

	logic [23:0] secret_key; //for HEX display
	logic [23:0] secret_keys [3:0]; 
	logic [3:0]  is_string, 
					 core_done, 
					 result, 
					 reset;
	
	assign 	result = is_string & core_done;
	
	// decryption core instantiations, each core contains its own encrypted, decrypted and working mems 
	decryptionCore CoreOne (.clk(CLOCK_50), 
									.reset_n(reset[0]), 
									.upper_key_bound(24'd4194303),
									.lower_key_bound(24'b0),
									.is_string(is_string[0]), 
									.core_done(core_done[0]), 
									.secret_key(secret_keys[0])
									); 
	decryptionCore CoreTwo (.clk(CLOCK_50), 
									.reset_n(reset[1]), 
									.upper_key_bound(24'd8388607),
									.lower_key_bound(24'd4194303),
									.is_string(is_string[1]), 
									.core_done(core_done[1]), 
									.secret_key(secret_keys[1])
									); 
	decryptionCore CoreThree (.clk(CLOCK_50), 
									.reset_n(reset[2]), 
									.upper_key_bound(24'd12582911),
									.lower_key_bound(24'd8388608),
									.is_string(is_string[2]), 
									.core_done(core_done[2]), 
									.secret_key(secret_keys[2])
									); 
	decryptionCore CoreFour (.clk(CLOCK_50), 
									.reset_n(reset[3]), 
									.upper_key_bound(24'd16777215),
									.lower_key_bound(24'd12582912),
									.is_string(is_string[3]), 
									.core_done(core_done[3]), 
									.secret_key(secret_keys[3])
									); 
	// Output logic which stops all cores still searching once key is found and displays correct key on HEX
	always_ff @(posedge CLOCK_50) begin 
		case(result)
			4'b0001:	reset = 4'b0001; 
			4'b0010:	reset = 4'b0010; 
			4'b0100:	reset = 4'b0100; 
			4'b1000:	reset = 4'b1000; 
		default		reset	= 4'b1111; 
		endcase 
		casex({result,SW[3:0]})
			8'b00000001:	secret_key = secret_keys[0];
			8'b00000010:	secret_key = secret_keys[1];
			8'b00000100:	secret_key = secret_keys[2];
			8'b00001000:	secret_key = secret_keys[3];
			8'b0001xxxx:	secret_key = secret_keys[0];
			8'b0010xxxx:	secret_key = secret_keys[1];
			8'b0100xxxx:	secret_key = secret_keys[2];
			8'b1000xxxx:	secret_key = secret_keys[3];
		default  		secret_key = secret_keys[0];
		endcase 
	end 
	
	// logic which shows LED[9] as high when key is found or if no string exists, LED[0] is high 
	logic no_key; 
	assign no_key = ~is_string & core_done;
	
	assign LEDR[9] = |result;
	assign LEDR[0] = no_key;	
	assign LEDR[8:5] = result;
endmodule 