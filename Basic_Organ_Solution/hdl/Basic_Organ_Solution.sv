`default_nettype none

import ascii::*;

module Basic_Organ_Solution
(
    input logic CLOCK_50,

    input logic [3:0] KEY,
    input logic [9:0] SW,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5,
    output logic [9:0] LEDR,

    // Audio
    input logic AUD_ADCDAT,
    inout logic AUD_ADCLRCK,
    inout logic AUD_BCLK,
    inout logic AUD_DACLRCK,
    output logic AUD_XCK,
    output logic AUD_DACDAT,

    // I2C for Audio
    inout logic FPGA_I2C_SDAT,
    output logic FPGA_I2C_SCLK,

    // GPIO
    inout logic [35:0] GPIO_0,
    inout logic [35:0] GPIO_1

);

    //=======================================================
    //  REG/WIRE declarations
    //=======================================================

    // Input and output declarations
    logic CLK_50M;
    logic Clock_1KHz;
    logic Clock_1Hz;
    logic Sample_Clk_Signal;
    logic [7:0] LED;
    wire [7:0] LCD_DATA;
    logic LCD_EN;
    logic LCD_ON;
    logic LCD_RS;
    logic LCD_RW;

    assign CLK_50M =  CLOCK_50;
    assign LEDR[7:0] = LED[7:0];
    assign GPIO_0[7:0] = LCD_DATA;
    assign GPIO_0[8] = LCD_EN;
    assign GPIO_0[9] = LCD_ON;
    assign GPIO_0[10] = LCD_RS;
    assign GPIO_0[11] = LCD_RS;
    assign GPIO_0[12] = LCD_RW;

    //=======================================================================================================================
    //
    // Insert your code for Lab1 here!
    //
    //

    logic tone_clk; // Will be the input of my divider module, needs to be enabled by SW[0]
    logic [11:0] LCD_LINE2; // logic to write different messages to LCD.
    logic [23:0] tone; // writes to LCD

    display_freq_info display_scales
    (
        .CLK_50M(CLK_50M),
        .tone_clk(tone_clk),
        .SW(SW),
        .LCD_LINE2(LCD_LINE2),
        .tone(tone)
    );
    
    // frequency_divider module, produces  8 different clock speeds depending on switch input
    frequency_divider audio_clock 
    (
        .CLK_in(tone_clk), 
        .CLK_out(Sample_Clk_Signal), 
        .reset(~KEY[3]), 
        .CLK_sel(SW[3:1])
    );

    // FSM controlling the LED sequence, need 25 bits to represent clock division for 1 Hz clock
    LED_bounce bounce_one_Hz
    (
        .CLK_50M(CLK_50M), 
        .count_max(25'd25_000_000), 
        .reset(~KEY[3]), 
        .LEDR(LED)
    );

    // Audio Generation Signal
    // Note that the audio needs signed data - so convert 1 bit to 8 bits signed
    // Generate signed sample audio signal
    wire [7:0] audio_data = {
        ~Sample_Clk_Signal,
        {7{Sample_Clk_Signal}}
    }; 
                    
    //=====================================================================================
    //
    // LCD Scope Acquisition Circuitry Wire Definitions                 
    //
    //=====================================================================================

    wire allow_run_LCD_scope;
    wire [15:0] scope_channelA, scope_channelB;
    (* keep = 1, preserve = 1 *) wire scope_clk;
    reg user_scope_enable_trigger;
    wire user_scope_enable;
    wire user_scope_enable_trigger_path0, user_scope_enable_trigger_path1;
    wire scope_enable_source = SW[8];
    wire choose_LCD_or_SCOPE =  SW[9];

    doublesync user_scope_enable_sync1
    (
        .indata(scope_enable_source),
        .outdata(user_scope_enable),
        .clk(CLK_50M),
        .reset(1'b1)
    ); 

    //Generate the oscilloscope clock
    Generate_Arbitrary_Divided_Clk32 Generate_LCD_scope_Clk
    (
        .inclk(CLK_50M),
        .outclk(scope_clk),
        .outclk_Not(),
        .div_clk_count(scope_sampling_clock_count),
        .Reset(1'h1)
    );

    //Scope capture channels

    (* keep = 1, preserve = 1 *) logic ScopeChannelASignal;
    (* keep = 1, preserve = 1 *) logic ScopeChannelBSignal;

    assign ScopeChannelASignal = Sample_Clk_Signal;
    assign ScopeChannelBSignal = SW[1];

    scope_capture LCD_scope_channelA
    (
        .clk(scope_clk),
        .the_signal(ScopeChannelASignal),
        .capture_enable(allow_run_LCD_scope & user_scope_enable), 
        .captured_data(scope_channelA),
        .reset(1'b1)
    );

    scope_capture LCD_scope_channelB
    (
        .clk(scope_clk),
        .the_signal(ScopeChannelBSignal),
        .capture_enable(allow_run_LCD_scope & user_scope_enable), 
        .captured_data(scope_channelB),
        .reset(1'b1)
    );

    assign LCD_ON = 1'b1;
    //The LCD scope and display
    LCD_Scope_Encapsulated_pacoblaze_wrapper LCD_LED_scope
    (
        //LCD control signals
        .lcd_d(LCD_DATA),   //don't touch
        .lcd_rs(LCD_RS),    //don't touch
        .lcd_rw(LCD_RW),    //don't touch
        .lcd_e(LCD_EN),     //don't touch
        .clk(CLK_50M),      //don't touch

        //LCD Display values 
        .InH(8'hAA),
        .InG(8'hAA),
        .InF({{3'b000,SW[3]}, {3'b000,SW[2]}}),
        .InE({{3'b000,SW[1]}, {3'b000,SW[0]}}),
        .InD(8'hAA),
        .InC(8'hAA),
        .InB(LCD_LINE2[11:4]),
        .InA({LCD_LINE2[3:0], {4'hA}}),

        //LCD display information signals, changed to reflect the sound frequency 
        .InfoH({CHAR_S_U, CHAR_W_U}),
        .InfoG({SPACE, THREE}),
        .InfoF({TWO, ONE}),
        .InfoE({ZERO, SPACE}),
        .InfoD({CHAR_F_U, CHAR_R_U}),
        .InfoC({CHAR_E_U, CHAR_Q_U}),
        .InfoB({SPACE, CHAR_H_U}),
        .InfoA({CHAR_Z_L, SPACE}),

        //choose to display the values or the oscilloscope
        .choose_scope_or_LCD(choose_LCD_or_SCOPE),

        //scope channel declarations
        .scope_channelA(scope_channelA), //don't touch
        .scope_channelB(scope_channelB), //don't touch

        //scope information generation
        .ScopeInfoA(tone),
        .ScopeInfoB({CHAR_S_U, CHAR_W_U, ONE, SPACE}),

        //enable_scope is used to freeze the scope just before capturing 
        //the waveform for display (otherwise the sampling would be unreliable)
        .enable_scope(allow_run_LCD_scope) //don't touch
                            
    );  

    //=====================================================================================
    //
    //  Seven-Segment and speed control
    //
    //=====================================================================================

    wire speed_up_event, speed_down_event;

    //Generate 1 KHz Clock
    Generate_Arbitrary_Divided_Clk32 Gen_1KHz_clk
    (
        .inclk(CLK_50M),
        .outclk(Clock_1KHz),
        .outclk_Not(),
        .div_clk_count(32'h61A6), //change this if necessary to suit your module
        .Reset(1'h1)
    ); 

    wire speed_up_raw;
    wire speed_down_raw;

    doublesync key0_doublsync
    (
        .indata(!KEY[0]),
        .outdata(speed_up_raw),
        .clk(Clock_1KHz),
        .reset(1'b1)
    );

    doublesync key1_doublsync
    (
        .indata(!KEY[1]),
        .outdata(speed_down_raw),
        .clk(Clock_1KHz),
        .reset(1'b1)
    );

    parameter num_updown_events_per_sec = 10;
    parameter num_1KHZ_clocks_between_updown_events = 1000/num_updown_events_per_sec;

    reg [15:0] updown_counter = 0;
    always @(posedge Clock_1KHz)
    begin
        if (updown_counter >= num_1KHZ_clocks_between_updown_events)
        begin
            if (speed_up_raw)
            begin
                speed_up_event_trigger <= 1;          
            end 
            
            if (speed_down_raw)
            begin
                speed_down_event_trigger <= 1;            
            end 
            updown_counter <= 0;
        end
        else 
        begin
            updown_counter <= updown_counter + 1;
            speed_up_event_trigger <=0;
            speed_down_event_trigger <= 0;
        end     
    end

    wire speed_up_event_trigger;
    wire speed_down_event_trigger;

    async_trap_and_reset_gen_1_pulse make_speedup_pulse
    (
        .async_sig(speed_up_event_trigger), 
        .outclk(CLK_50M), 
        .out_sync_sig(speed_up_event), 
        .auto_reset(1'b1), 
        .reset(1'b1)
    );
    
    async_trap_and_reset_gen_1_pulse make_speedown_pulse
    (
        .async_sig(speed_down_event_trigger), 
        .outclk(CLK_50M), 
        .out_sync_sig(speed_down_event), 
        .auto_reset(1'b1), 
        .reset(1'b1)
    );

    wire speed_reset_event; 

    doublesync key2_doublsync
    (
        .indata(!KEY[2]),
        .outdata(speed_reset_event),
        .clk(CLK_50M),
        .reset(1'b1)
    );

    parameter oscilloscope_speed_step = 100;

    wire [15:0] speed_control_val;                      
    speed_reg_control speed_reg_control_inst
    (
        .clk(CLK_50M),
        .up_event(speed_up_event),
        .down_event(speed_down_event),
        .reset_event(speed_reset_event),
        .speed_control_val(speed_control_val)
    );

    logic [15:0] scope_sampling_clock_count;
    parameter [15:0] default_scope_sampling_clock_count = 12499; //2KHz

    always @ (posedge CLK_50M) 
    begin
        scope_sampling_clock_count <= default_scope_sampling_clock_count+{{16{speed_control_val[15]}},speed_control_val};
    end 

    logic [7:0] Seven_Seg_Val[5:0];
    logic [3:0] Seven_Seg_Data[5:0];

    genvar i;
    generate
    for (i = 0; i < 6; i++)
    begin : SevenSegmentDisplayDecoder
        SevenSegmentDisplayDecoder decoder_inst 
        (
            .ssOut(Seven_Seg_Val[i]), 
            .nIn(Seven_Seg_Data[i])
        );
    end
    endgenerate

    assign HEX0 = Seven_Seg_Val[0];
    assign HEX1 = Seven_Seg_Val[1];
    assign HEX2 = Seven_Seg_Val[2];
    assign HEX3 = Seven_Seg_Val[3];
    assign HEX4 = Seven_Seg_Val[4];
    assign HEX5 = Seven_Seg_Val[5];
    
    wire Clock_2Hz;
                
    Generate_Arbitrary_Divided_Clk32 Gen_2Hz_clk
    (
        .inclk(CLK_50M),
        .outclk(Clock_2Hz),
        .outclk_Not(),
        .div_clk_count(32'h17D7840 >> 1),
        .Reset(1'h1)
    ); 
            
    logic [23:0] actual_7seg_output;
    reg [23:0] regd_actual_7seg_output;

    always @(posedge Clock_2Hz)
    begin
        regd_actual_7seg_output <= actual_7seg_output;
        Clock_1Hz <= ~Clock_1Hz;
    end

    assign Seven_Seg_Data[0] = regd_actual_7seg_output[3:0];
    assign Seven_Seg_Data[1] = regd_actual_7seg_output[7:4];
    assign Seven_Seg_Data[2] = regd_actual_7seg_output[11:8];
    assign Seven_Seg_Data[3] = regd_actual_7seg_output[15:12];
    assign Seven_Seg_Data[4] = regd_actual_7seg_output[19:16];
    assign Seven_Seg_Data[5] = regd_actual_7seg_output[23:20];

    assign actual_7seg_output = scope_sampling_clock_count;

    //=======================================================================================================================
    //
    //   Audio controller code - do not touch
    //
    //========================================================================================================================
    wire [$size(audio_data)-1:0] actual_audio_data_left, actual_audio_data_right;
    wire audio_left_clock, audio_right_clock;

    to_slow_clk_interface interface_actual_audio_data_right
    (
        .indata(audio_data),
        .outdata(actual_audio_data_right),
        .inclk(CLK_50M),
        .outclk(audio_right_clock)
    );

    to_slow_clk_interface interface_actual_audio_data_left
    (
        .indata(audio_data),
        .outdata(actual_audio_data_left),
        .inclk(CLK_50M),
        .outclk(audio_left_clock)
    );

    audio_controller audio_control (
        // Clock Input (50 MHz)
        .iCLK_50(CLK_50M), // 50 MHz
        .iCLK_28(), // 27 MHz
        //  7-SEG Displays
        // I2C
        .I2C_SDAT(FPGA_I2C_SDAT),   // I2C Data
        .oI2C_SCLK(FPGA_I2C_SCLK),  // I2C Clock
        // Audio CODEC
        .AUD_ADCLRCK(AUD_ADCLRCK),  //  Audio CODEC ADC LR Clock
        .iAUD_ADCDAT(AUD_ADCDAT),   //  Audio CODEC ADC Data
        .AUD_DACLRCK(AUD_DACLRCK),  //  Audio CODEC DAC LR Clock
        .oAUD_DACDAT(AUD_DACDAT),   //  Audio CODEC DAC Data
        .AUD_BCLK(AUD_BCLK),        //  Audio CODEC Bit-Stream Clock
        .oAUD_XCK(AUD_XCK),         //  Audio CODEC Chip Clock
        .audio_outL({actual_audio_data_left,8'b1}), 
        .audio_outR({actual_audio_data_right,8'b1}),
        .audio_right_clock(audio_right_clock), 
        .audio_left_clock(audio_left_clock)
    );

    //=======================================================================================================================
    //
    //   End Audio controller code
    //
    //========================================================================================================================

endmodule
