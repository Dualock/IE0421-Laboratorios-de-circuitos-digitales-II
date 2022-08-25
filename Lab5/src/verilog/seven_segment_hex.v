module seven_segment_hex (
			  output reg [7:0] out_cathode,
			  output reg [7:0] out_anode,
			  input 	   clk,
			  input 	   resetn,
			  input [31:0] 	   number_display
			  );
   reg [2:0] 				   counter;
   reg [17:0]				   counter1;
   reg [3:0] 				   current_nibble;
   reg [7:0]				   anode_alt;

   always @(posedge clk) begin
      if(!resetn) begin
		counter   <= 0;  
	 	counter1  <= 18'b111111111111111111;
	 	anode_alt <= 8'b1111_1110;
	 //out_cathode <= 0;
      end
	  else begin
		  if (counter1 == 18'b111111111111111111) begin
			case(counter)
			3'b000: begin
				anode_alt <= 8'b11111110;
				current_nibble <= number_display[3:0];
			end
			3'b001: begin
				anode_alt <= 8'b11111101;
				current_nibble <= number_display[7:4];
			end
			3'b010: begin
				anode_alt <= 8'b11111011;
				current_nibble <= number_display[11:8];
			end
			3'b011: begin
				anode_alt <= 8'b11110111;
				current_nibble  <= number_display[15:12];
			end
			3'b100: begin
				anode_alt <= 8'b11101111;
				current_nibble <= number_display[19:16];
			end
			3'b101: begin
				anode_alt <= 8'b11011111;
				current_nibble <= number_display[23:20];
			end
			3'b110: begin
				anode_alt <= 8'b10111111;
				current_nibble  <= number_display[27:24];
			end
			3'b111: begin
				anode_alt <= 8'b01111111;
				current_nibble <= number_display[31:28];
			end
			endcase
			counter <= counter +1;
			counter1 <= 0;
		  end
		  else begin
			  counter1 <= counter1 +1;
		  end
	  end
			case(current_nibble)
			//cathode = ABCDEFG(DP)
			//El bit DP siempre va en 1
			4'b0000: begin 
				out_cathode <= 8'b00000011;
			end
			4'b0001: begin
				out_cathode <= 8'b10011111;
			end
			4'b0010: begin
				out_cathode <= 8'b00100101;
			end
			4'b0011: begin
				out_cathode <= 8'b00001101;
			end
			4'b0100: begin
				out_cathode <= 8'b10011001;
			end
			4'b0101: begin
				out_cathode <= 8'b01001001;
			end
			4'b0110: begin
				out_cathode <= 8'b01000001;
			end
			4'b0111: begin
				out_cathode <= 8'b00011111;
			end
			4'b1000: begin
				out_cathode <= 8'b00000001;
			end
			4'b1001: begin
				out_cathode <= 8'b00001001;
			end
			4'b1010: begin
				out_cathode <= 8'b00010001;
			end
			4'b1011: begin
				out_cathode <= 8'b11000001;
			end
			4'b1100: begin
				out_cathode <= 8'b01100011;
			end
			4'b1101: begin
				out_cathode <= 8'b10000101;
			end
			4'b1110: begin
				out_cathode <= 8'b01100001;
			end
			4'b1111: begin
				out_cathode <= 8'b01110001;
			end
			endcase
			out_anode <= anode_alt;
		end
endmodule
