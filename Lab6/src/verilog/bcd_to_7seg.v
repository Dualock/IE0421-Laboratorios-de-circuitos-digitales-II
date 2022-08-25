module bcd_to_7seg(
        input resetn,
	input  [5:0] num_bcd,
	output reg [7:0] num_7seg
);
        always @(*) begin
                if (!resetn) begin
                        num_7seg = 8'b11111111; // "0"
                end
                else begin
                        case (num_bcd)            //DpGFEDCBA
                                6'h00: num_7seg = 8'b11000000; // "0"
                                6'h01: num_7seg = 8'b11111001; // "1"
                                6'h02: num_7seg = 8'b10100100; // "2"
                                6'h03: num_7seg = 8'b10110000; // "3"
                                6'h04: num_7seg = 8'b10011001; // "4"
                                6'h05: num_7seg = 8'b10010010; // "5"
                                6'h06: num_7seg = 8'b10000010; // "6"
                                6'h07: num_7seg = 8'b11111000; // "7"
                                6'h08: num_7seg = 8'b10000000; // "8"
                                6'h09: num_7seg = 8'b10010000; // "9"
                                6'h0a: num_7seg = 8'b10100000; // "a"
                                6'h0b: num_7seg = 8'b10000011; // "b"
                                6'h0c: num_7seg = 8'b10100111; // "c"
                                6'h0d: num_7seg = 8'b10100001; // "d"
                                6'h0e: num_7seg = 8'b10000110; // "e"
                                6'h0f: num_7seg = 8'b10001110; // "f"
                                //added cases
                                6'h10: num_7seg = 8'b11000010; // "g"
                                6'h11: num_7seg = 8'b10001011;  // "h"
                                6'h12: num_7seg = 8'b11101110; // "i"
                                6'h13: num_7seg = 8'b11110010; // "j"
                                6'h14: num_7seg = 8'b10001010; // "k"
                                6'h15: num_7seg = 8'b11000111; // "l"
                                6'h16: num_7seg = 8'b10101010; // "m"
                                6'h17: num_7seg = 8'b10101011; // "n"
                                6'h18: num_7seg = 8'b10100011; // "o"
                                6'h19: num_7seg = 8'b10001100; // "p"
                                6'h1a: num_7seg = 8'b10011000; // "q"
                                6'h1b: num_7seg = 8'b10101111; // "r"
                                6'h1c: num_7seg = 8'b11010010; // "s"
                                6'h1d: num_7seg = 8'b10000111; // "t"
                                6'h1e: num_7seg = 8'b11100011; // "u"
                                6'h1f: num_7seg = 8'b11010101; // "v"
                                6'h20: num_7seg = 8'b10010101; // "w"
                                6'h21: num_7seg = 8'b11101011; // "x"
                                6'h22: num_7seg = 8'b10010001; // "y"
                                6'h23: num_7seg = 8'b11100100; // "z"
                                6'h24: num_7seg = 8'b11111111; // " "
                                6'h25: num_7seg = 8'b11101000; // "@"

                        endcase
                end
        end
endmodule
