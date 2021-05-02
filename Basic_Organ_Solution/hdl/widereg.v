module widereg
(
    input [width-1:0] indata,
    output reg [width-1:0] outdata,
    input inclk
);

    parameter width = 8;

    always @ (posedge inclk)
    begin
        outdata <= indata;
    end

endmodule
