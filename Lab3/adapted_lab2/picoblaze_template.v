`default_nettype none
`define USE_PACOBLAZE

module picoblaze_template#(parameter clk_freq_in_hz = 25000000) (
																						output reg[8:0] led,
																						input clk,
																						input [22:0] current_address,
																						input [15:0] address_data
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

//--
//-- Signals used to generate interrupt 
//--
reg[26:0] int_count;
reg event_new_addr;

pacoblaze3 led_8seg_kcpsm
(
                  .address(address),
               .instruction(instruction),
                   .port_id(port_id),
              .write_strobe(write_strobe),
                  .out_port(out_port),
               .read_strobe(read_strobe),
                   .in_port(in_port),
                 .interrupt(interrupt),
             .interrupt_ack(interrupt_ack),
                     .reset(kcpsm3_reset),
                       .clk(clk));

 wire [19:0] raw_instruction;
	
	pacoblaze_instruction_memory 
	pacoblaze_instruction_memory_inst(
     	.addr(address),
	    .outdata(raw_instruction)
	);
	
	always @ (posedge clk)
	begin
	      instruction <= raw_instruction[17:0];
	end

    assign kcpsm3_reset = 0;                       
  
//  ----------------------------------------------------------------------------------------------------------------------------------
//  -- Interrupt 
//  ----------------------------------------------------------------------------------------------------------------------------------
//  --
//  --
//  -- Interrupt is used to provide a 1 second time reference.
//  --
//  --
//  -- A simple binary counter is used to divide the 50MHz system clock and provide interrupt pulses.
//  --

// Note that because we are using clock enable we DO NOT need to synchronize with clk

wire [22:0] last_address; 

// Will check previous address to current address and impliment interrupt if not equal
always @ (posedge clk) begin 
	if (last_address != current_address) begin
		event_new_addr <= 1'b1;
		last_address 	<= current_address; 
	end 
	else if (last_address == current_address) begin
		event_new_addr <= 1'b0;
		last_address	<= last_address; 
	end
end

always @ (posedge clk or posedge interrupt_ack)  //FF with clock "clk" and reset "interrupt_ack"
begin
	if (interrupt_ack) //if we get reset, reset interrupt in order to wait for next clock.
		interrupt <= 0;
	else	
	begin 
		if (event_new_addr)   //clock enable
			interrupt <= 1;
		else
			interrupt <= interrupt;
	end
end

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
		8'h00:	in_port <= address_data[7:0];
		8'h01:	in_port <= address_data[15:8];
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

        //LED is port 80 hex 
			if (write_strobe & port_id[7])  //clock enable 
				led[8:1] <= out_port;
			else if (write_strobe & port_id[6])
				led[0]	<= out_port[0]; 
  end


endmodule
