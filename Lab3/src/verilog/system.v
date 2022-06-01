`timescale 1 ns / 1 ps
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

module seven_segment_dec (
	input clk,
	input resetn,
	input [31:0] number_display,
	output reg [7:0] out_cathode,
	output reg [7:0] out_anode
);
	wire [3:0] decimal [9:0];

	assign decimal[9] = number_display / (10**9);

	genvar i;
	for (i = 0; i < 9; i = i+1) begin
		assign decimal[i] = (number_display % (10**(i+1))) / (10**i);
	end

	reg [2:0] counter;
	reg [3:0] current_nibble;
	reg [7:0] anode_alt;
	reg [17:0] counter1;

	always @(posedge clk) begin
		if (!resetn) begin
			counter <= 0;
			anode_alt <= 8'b1111_1110;
			counter1 <= 18'b111111111111111111;
		end
		else begin
		  if (counter1 == 18'b111111111111111111) begin
                if (number_display > 99999999) begin
                    case (counter)
                        3'b000: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11111110;
                        end
                        3'b001: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11111101;
                        end
                        3'b010: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11111011;
                        end
                        3'b011: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11110111;
                        end
                        3'b100: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11101111;
                        end
                        3'b101: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b11011111;
                        end
                        3'b110: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b10111111;
                        end
                        3'b111: begin
                            current_nibble <= 9;
                            anode_alt <= 8'b01111111;
                        end
                    endcase
                end
                else begin
                    case (counter)
                        3'b000: begin
                            current_nibble <= decimal[0];
                            anode_alt <= 8'b11111110;
                        end
                        3'b001: begin
                            current_nibble <= decimal[1];
                            anode_alt <= 8'b11111101;
                        end
                        3'b010: begin
                            current_nibble <= decimal[2];
                            anode_alt <= 8'b11111011;
                        end
                        3'b011: begin
                            current_nibble <= decimal[3];
                            anode_alt <= 8'b11110111;
                        end
                        3'b100: begin
                            current_nibble <= decimal[4];
                            anode_alt <= 8'b11101111;
                        end
                        3'b101: begin
                            current_nibble <= decimal[5];
                            anode_alt <= 8'b11011111;
                        end
                        3'b110: begin
                            current_nibble <= decimal[6];
                            anode_alt <= 8'b10111111;
                        end
                        3'b111: begin
                            current_nibble <= decimal[7];
                            anode_alt <= 8'b01111111;
                        end
                    endcase
                end
                counter <= counter + 1;
                counter1 <= 0;
            end
            else begin
                counter1 <= counter1 + 1;
            end
		end

		case (current_nibble)
			4'b0000: begin
				out_cathode <= 8'b00000011;
			end
			4'b0001: begin
				out_cathode <= 8'b10011111;
			end
			4'b0010:begin
				out_cathode <= 8'b00100101;
			end
			4'b0011:begin
				out_cathode <= 8'b00001101;
			end
			4'b0100:begin
				out_cathode <= 8'b10011001;
			end
			4'b0101:begin
				out_cathode <= 8'b01001001;
			end
			4'b0110:begin
				out_cathode <= 8'b01000001;
			end
			4'b0111:begin
				out_cathode <= 8'b00011111;
			end
			4'b1000:begin
				out_cathode <= 8'b00000001;
			end
			4'b1001:begin
				out_cathode <= 8'b00001001;
			end
			default: out_cathode <= 8'b00000011;
		endcase
		out_anode <= anode_alt;
	end
endmodule

module seven_segment_switch (
	input clk,
	input resetn,
	input switch,
	input [31:0] number_display,
	output reg [7:0] out_cathode,
	output reg [7:0] out_anode
);
	wire [7:0] cathode_result [1:0];
	wire [7:0] anode_result [1:0];

	seven_segment_dec	decimal (
		.clk	(clk),
		.resetn	(resetn),
		.number_display	(number_display),
		.out_cathode(cathode_result[0]),
		.out_anode	(anode_result[0])
	);

	seven_segment_hex	hexadecimal (
		.clk	(clk),
		.resetn	(resetn),
		.number_display	(number_display),
		.out_cathode(cathode_result[1]),
		.out_anode	(anode_result[1])
	);

	always @(posedge clk) begin
		case (switch)
			1'b0: begin
				out_cathode <= cathode_result[1];
				out_anode <= anode_result[1];
			end
			1'b1: begin
				out_cathode <= cathode_result[0];
				out_anode <= anode_result[0];
			end
		endcase
	end
endmodule

module system (
	       input 		clk,
	       input 		resetn,
	       input 		switch, 
	       output 		trap,
	       output reg [7:0] out_byte,
	       output reg 	out_byte_en,
	       output reg [7:0] out_anode,
	       output reg [7:0] out_cathode
	       );
   // set this to 0 for better timing but less performance/MHz
   parameter FAST_MEMORY = 1;

   // 4096 32bit words = 16kB memory
   parameter MEM_SIZE = 4096;

   wire 			mem_valid;
   wire 			mem_instr;
   reg 				mem_ready;
   wire [31:0] 			mem_addr;
   wire [31:0] 			mem_wdata;
   wire [3:0] 			mem_wstrb;
   reg [31:0] 			mem_rdata;

   wire 			mem_la_read;
   wire 			mem_la_write;
   wire [31:0] 			mem_la_addr;
   wire [31:0] 			mem_la_wdata;
   wire [3:0] 			mem_la_wstrb;

   reg [31:0] 			number_display;
   wire [7:0]			outcathode;
   wire [7:0]			outanode;

   picorv32 picorv32_core (
			   .clk         (clk         ),
			   .resetn      (resetn      ),
			   .trap        (trap        ),
			   .mem_valid   (mem_valid   ),
			   .mem_instr   (mem_instr   ),
			   .mem_ready   (mem_ready   ),
			   .mem_addr    (mem_addr    ),
			   .mem_wdata   (mem_wdata   ),
			   .mem_wstrb   (mem_wstrb   ),
			   .mem_rdata   (mem_rdata   ),
			   .mem_la_read (mem_la_read ),
			   .mem_la_write(mem_la_write),
			   .mem_la_addr (mem_la_addr ),
			   .mem_la_wdata(mem_la_wdata),
			   .mem_la_wstrb(mem_la_wstrb)
			   );
   
   seven_segment_switch seven_seg(
				  // Outputs
				  .out_cathode		(outcathode[7:0]),
				  .out_anode		(outanode[7:0]),
				  // Inputs
				  .clk			(clk),
				  .resetn		(resetn),
				  .switch		(switch),
				  .number_display	(number_display[31:0]));
   
   

   reg [31:0] 			memory [0:MEM_SIZE-1];

`ifdef SYNTHESIS
   initial $readmemh("../firmware/firmware.hex", memory);
`else
   initial $readmemh("firmware.hex", memory);
`endif

   reg [31:0] 			m_read_data;
   reg 				m_read_en;

   generate if (FAST_MEMORY) begin
      always @(posedge clk) begin
	 mem_ready <= 1;
	 out_byte_en <= 0;
	 mem_rdata <= memory[mem_la_addr >> 2];
	 if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
	    if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
	    if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
	    if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
	    if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
	 end
	 else
	   if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
	      out_byte_en <= 1;
	      out_byte <= mem_la_wdata;
		  number_display <= mem_la_wdata;
	   end
	   out_anode <= outanode;
	   out_cathode <= outcathode;
      end
   end else begin
      always @(posedge clk) begin
	 m_read_en <= 0;
	 mem_ready <= mem_valid && !mem_ready && m_read_en;

	 m_read_data <= memory[mem_addr >> 2];
	 mem_rdata <= m_read_data;

	 out_byte_en <= 0;

	 (* parallel_case *)
	 case (1)
	   mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
	      m_read_en <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
	      if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
	      if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
	      if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
	      if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
	      out_byte_en <= 1;
	      out_byte <= mem_wdata;
	      mem_ready <= 1;
	   end
	 endcase
      end
   end endgenerate
endmodule
