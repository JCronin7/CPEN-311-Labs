`default_nettype none
`define USE_PACOBLAZE

module picoblaze_template
	#(parameter clk_freq_in_hz = 25000000) 
	(
	input clk,
	input phoneme_done,
	output reg[8:0] phoneme,
	output phoneme_start,
	output phoneme_reset
	);

//--
//------------------------------------------------------------------------------------
//--
//-- Signals used to connect KCPSM3 to program ROM and I/O logic
//--

wire[9:0]  address;
wire[17:0]  instruction;
wire[7:0]  port_id;
wire[7:0]  out_port;
reg[7:0]  in_port;
wire  write_strobe;
wire  read_strobe;
reg  interrupt;
wire  interrupt_ack;
wire  kcpsm3_reset;

pacoblaze3 led_8seg_kcpsm
(
                  .address(address),
               .instruction(instruction),
                   .port_id(port_id),
              .write_strobe(write_strobe),
                  .out_port(out_port),
               .read_strobe(read_strobe),
                   .in_port(in_port),
                  .reset(kcpsm3_reset),
                       .clk(clk));

 wire [19:0] raw_instruction;
	
pacoblaze_instruction_memory pacoblaze_instruction_memory_inst
	(
	.addr(address),
	.outdata(raw_instruction)
	);
	
always @ (posedge clk)
begin
	instruction <= raw_instruction[17:0];
end

assign kcpsm3_reset = 0;                       
  	
//  --
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- KCPSM3 input ports 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  --
//  -- The inputs connect via a pipelined multiplexer
//  --

always @ (posedge clk)
begin
   case (port_id[7:0])				
		8'h01:	in_port <= {7'b0, phoneme_done}; // Flag to indecate phoneme to audio has been completed 
      default: in_port <= 8'bx;
   endcase
end
   
//
//  --
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- KCPSM3 output ports 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  -- adding the output registers to the processor
//  --
//   
always @ (posedge clk)
begin

//phoneme_select is port 80 hex 
	if (write_strobe & port_id[7])  //clock enable 
		phoneme <= out_port;
	else if (write_strobe & port_id[6])		// signal to start address controller
		phoneme_start <= out_port[0]; 
	else if (write_strobe & port_id[5])		// signal to restart address controller 
		phoneme_reset <= out_port[0]; 

end


endmodule
