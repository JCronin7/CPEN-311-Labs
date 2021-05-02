// All states that the LED's can take on. 
`define STATE0 8'b00000001
`define STATE1 8'b00000010
`define STATE2 8'b00000100
`define STATE3 8'b00001000
`define STATE4 8'b00010000
`define STATE5 8'b00100000
`define STATE6 8'b01000000
`define STATE7 8'b10000000

/* 
This module produces a one Hertz cloack frequency and uses it to control a 
State machine driving the LED pattern on the DE1-SoC
*/

module LED_bounce
(
    input logic CLK_50M,
    input logic reset,
	input logic [24:0] count_max,
    output logic [7:0] LEDR
);

    logic CLK_1, forward;

	counter #(25) LED_counter
    (
        .CLK_in(CLK_50M),
        .CLK_out(CLK_1), 
        .count_max(count_max), 
        .reset(reset)
    );

	always_ff @(posedge CLK_1) 
    begin
		if (reset)
        begin
			LEDR = `STATE0;
			forward = 1'b1;
		end

		if (forward)
        begin
			case(LEDR)
                `STATE0: LEDR = `STATE1;
                `STATE1: LEDR = `STATE2;
                `STATE2: LEDR = `STATE3;
                `STATE3: LEDR = `STATE4;
                `STATE4: LEDR = `STATE5;
                `STATE5: LEDR = `STATE6;
                `STATE6: LEDR = `STATE7;
                `STATE7:
                begin 
                    LEDR = `STATE6;
                    forward = 1'b0; 
                end
                default LEDR = `STATE0;
			endcase
        end
		else
        begin
            case (LEDR)
                `STATE7: LEDR = `STATE6;
                `STATE6: LEDR = `STATE5;
                `STATE5: LEDR = `STATE4;
                `STATE4: LEDR = `STATE3;
                `STATE3: LEDR = `STATE2;
                `STATE2: LEDR = `STATE1;
                `STATE1: LEDR = `STATE0;
                `STATE0: 
                begin 
                    LEDR = `STATE1;
                    forward = 1'b1; 
                end
                default LEDR = `STATE0;
            endcase
        end
	end 
		
endmodule
