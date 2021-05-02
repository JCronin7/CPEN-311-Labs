import ascii::*

module display_freq_info
(
    input logic CLK_50M,
    input logic tone_clk,
    input logic [3:0] SW,
    output logic [11:0] LCD_LINE2,
    output logic [23:0] tone
);

    always_comb 
    begin
        if (SW[0])
            tone_clk = CLK_50M;
        else
            tone_clk = 1'b0;

        case(SW[3:1])
            3'b000:	
            begin 
                tone[23:0] = {CHAR_D_U, CHAR_O_L, SPACE};
                LCD_LINE2 = 12'd523; 
            end 
            3'b001:	
            begin 
                tone[23:0] = {CHAR_R_U, CHAR_E_L, SPACE};
                LCD_LINE2 = 12'd587;
            end 
            3'b010:	
            begin
                tone[23:0] = {CHAR_M_U, CHAR_I_L, SPACE};
                LCD_LINE2 = 12'd659;
            end 
            3'b011:	
            begin 
                tone[23:0] = {CHAR_F_U, CHAR_A_L, SPACE};
                LCD_LINE2 = 12'd698;
            end 
            3'b100:	
            begin 
                tone[23:0] = {CHAR_S_U, CHAR_O_L, SPACE};
                LCD_LINE2 = 12'd783;
            end 
            3'b101:	
            begin
                tone[23:0] = {CHAR_L_U, CHAR_A_L, SPACE};
                LCD_LINE2 = 12'd880;
            end 
            3'b110:	
            begin 
                tone[23:0] = {CHAR_S_U, CHAR_I_L, SPACE};
                LCD_LINE2 = 12'd987;
            end 
            3'b111:	
            begin 
                tone[23:0] = {CHAR_D_U, CHAR_O_L, TWO};
                LCD_LINE2 = 12'd1046;
            end 
            default tone[23:0] = {CHAR_Z_U, CHAR_Z_L, SPACE};
        endcase
    end

endmodule