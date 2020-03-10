module masterSM(	input logic clk, 	
						input logic reset,
						input logic start, 
						input logic [23:0] secret_key, 
						input logic [7:0] Smem_data,
						input logic [7:0] Tmem_data,
						input logic [7:0] Umem_data,
						output logic Smem_write, 
						output logic Umem_write, 
						output logic [7:0] Smem_address,
						output logic [7:0] Tmem_address,
						output logic [7:0] Umem_address,
						output logic [7:0] Sdata_in,
						output logic [7:0] Udata_in,
						output logic done, 
						output logic is_string
						); 
						 
	// write SM signals
	logic [7:0] writeSM_data, writeSM_address;
	logic writeSM_write, start_write, writeSM_done;   

	// writes each address index to its data
	writeToMem writeSM (.clk(clk), 
								.reset(reset), 
								.start(start_write), 
								.q(Smem_data),
								.write(writeSM_write),
								.done(writeSM_done),
								.address(writeSM_address),
								.data(writeSM_data));
	
	// shuffle SM signals
	logic [7:0] shuffleSM_data, shuffleSM_address;
	logic shuffleSM_write, shuffleSM_done; 
	
	// rewrites memory according to algorithm 
	shuffle shuffeleSM (.clk(clk), 
								.reset(reset), 
								.start(writeSM_done), 
								.secret_key(secret_key),
								.q(Smem_data),
								.write(shuffleSM_write),
								.done(shuffleSM_done),  // FILL IN
								.address(shuffleSM_address),
								.data(shuffleSM_data));
	
	logic [7:0] decrypt_address, decrypt_data; 
	logic decrypt_write;
	
	decryptMessage RC4decryption (.clk(clk),
											.reset(reset), 
											.start(shuffleSM_done), 
											.S_q(Smem_data),
											.T_q(Tmem_data),
											.U_q(Umem_data),
											.done(done),
											.is_string(is_string), 
											.S_write(decrypt_write),
											.U_write(Umem_write),
											.S_address(decrypt_address),
											.T_address(Tmem_address),
											.U_address(Umem_address),
											.S_data(decrypt_data),
											.U_data(Udata_in)
											);
			// to ensure SM doesn't continue running after write is finished
	always_ff @(posedge clk) begin 	
		if (reset)	begin 
							start_write  <= 1'b0; 
							Smem_address <= 8'b0; 
							Sdata_in		 <= 8'b0; 
							Smem_write	 <= 1'b0;
						end 
		else 								
		case({writeSM_done,shuffleSM_done})
			2'b00:	begin	
							start_write <= start; 
							Smem_address <= writeSM_address; 
							Sdata_in		<= writeSM_data; 
							Smem_write	<= writeSM_write;
						end 
			2'b10: 	begin 
							Smem_address <= shuffleSM_address; 
							Sdata_in		<= shuffleSM_data; 
							Smem_write	<= shuffleSM_write;
						end 
			2'b11:	begin 
							Smem_address <= decrypt_address; 
							Sdata_in		<= decrypt_data; 
							Smem_write	<= decrypt_write;
						end
		default 		begin 
							Smem_address <= 8'b0; 
							Sdata_in		 <= 8'b0; 
							Smem_write	 <= 1'b0;
						end 
		endcase
	end 
endmodule 