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

module memoryExt(
	input            	clk,
	input            	resetn,
	input			 	mem_valid,
	input			 	mem_instr,
	input [31:0]	 	mem_addr,
	input [31:0]	 	mem_wdata,
	input [3:0]		 	mem_wstrb,
	output reg  	 	mem_ready,
	output reg		 	out_byte_en,
	output reg [31:0]	mem_rdata,
	output reg [31:0]	bin
);
	parameter MEM_SIZE = 16384;
	
	reg m_read_en;
	reg [31:0] memory [0:MEM_SIZE-1];
	reg [31:0] m_read_data;
	reg [3:0] writeDelay;
	reg [3:0] readDelay;
	reg [3:0] readDelaySec;
	
	`ifdef SYNTHESIS
		initial $readmemh("../firmware/firmware.hex", memory);
	`else
		initial $readmemh("firmware.hex", memory);
	`endif

	always @(posedge clk) begin
		if (!resetn) begin
			readDelay <= 0;
			readDelaySec <= 0;
			writeDelay <= 0;
		end
		else begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;
				
			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;
			
			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (readDelay == 9) begin
						m_read_en <= 1;
						readDelay <= 0;
					end
					else begin
						if (m_read_en != 1) begin
						readDelay <= readDelay + 1;
						end
					end
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					if (writeDelay == 14) begin
					   mem_ready <= 1;
					   writeDelay <= 0;
					end
					else begin
						writeDelay <= writeDelay + 1;
					end
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					//bin <= mem_wdata;
					if (readDelay == 9) begin
					   mem_ready <= 1;
					   readDelay <= 0;
					   out_byte_en <= 1;
					   bin <= mem_wdata;
					end
					else begin
						readDelay <= readDelay + 1;
					end
				end
			endcase
		end
	end
endmodule

module cache_direct(
	input clk,
	input resetn,

	input mem_valid_cpu,
	input mem_instr_cpu,
	input [3:0] mem_wstrb_cpu,
	input [31:0] mem_addr_cpu,
	input [31:0] mem_wdata_cpu,

	output reg mem_ready_cpu,
	output reg [31:0] mem_rdata_cpu,

	input mem_ready_ext,
	input [31:0] mem_rdata_ext,

	output reg mem_valid_ext,
	output reg mem_instr_ext,
	output reg [3:0] mem_wstrb_ext,
	output reg [31:0] mem_addr_ext,
	output reg [31:0] mem_wdata_ext
);
	// 1kB de cache
	parameter CACHE_SIZE = 1024;
	parameter WORDS = 2;
	parameter BLOCK_SIZE = WORDS*32/8;
	parameter OFFSET_SIZE = $clog2(BLOCK_SIZE);
	parameter BLOCKS = CACHE_SIZE/BLOCK_SIZE;
	parameter INDEX_SIZE = $clog2(BLOCKS);
	parameter TAG_SIZE = 32 - INDEX_SIZE - OFFSET_SIZE;
	parameter WORD_SIZE = 32;
	parameter DATA_SIZE = WORDS*WORD_SIZE;
	parameter MEM_SIZE = DATA_SIZE + TAG_SIZE + 2;
	parameter WORDS_ITR = $clog2(WORDS);
	
	parameter IDLE = 0;
	parameter READ = 1;
	parameter WRITE = 2;
	parameter READ_MISS = 3;
	parameter WRITE_MISS = 4;
	parameter MEM_READ = 5;
	parameter MEM_WRITE = 6;
	parameter WRITE_BACK = 7;

	reg [MEM_SIZE-1:0] cache [BLOCKS-1:0];
	reg hit;
	reg [31:0] hit_count;
	reg [31:0] miss_count;
	reg [3:0] state;
	wire [OFFSET_SIZE-1:0] offset;
	wire [INDEX_SIZE-1:0] index;
	wire [TAG_SIZE-1:0] tag;
	reg [WORDS_ITR-1:0] word_count;
	reg write;
	reg read;
	reg write_m;
	reg read_m;
	reg delay;

	integer i;
	initial begin
		for (i = 0; i < BLOCKS; i = i+1) begin
			cache[i] = 0;
		end
	end

	assign offset = mem_addr_cpu[OFFSET_SIZE-1:0];
	assign index = mem_addr_cpu[INDEX_SIZE+OFFSET_SIZE-1:OFFSET_SIZE];
	assign tag = mem_addr_cpu[TAG_SIZE+INDEX_SIZE+OFFSET_SIZE-1:INDEX_SIZE+OFFSET_SIZE];

	always @(posedge clk ) begin
		if (!resetn) begin
			hit <= 0;
			hit_count <= 0;
			miss_count <= 0;
			word_count <= 0;
			state <= IDLE;
			write <= 0;
			read <= 0;
			write_m <= 0;
			read_m <= 0;
			delay <= 0;
		end
		else begin
			case (state)
				IDLE: begin
					mem_ready_cpu <= 0;
					if (mem_valid_cpu && !mem_ready_cpu) begin
						if (mem_addr_cpu >= 32'h1000_0000) begin
							mem_valid_ext <= mem_valid_cpu;
							mem_ready_cpu <= mem_ready_ext;
							mem_addr_ext <= mem_addr_cpu;
							mem_wdata_ext <= mem_wdata_cpu;
							mem_wstrb_ext <= mem_wstrb_cpu;
						end
						else if (!mem_wstrb_cpu) begin
							if (tag == cache[index][MEM_SIZE-3:DATA_SIZE] && cache[index][MEM_SIZE-1]) begin
								hit <= 1;
								hit_count <= hit_count + 1;
								state <= READ;
							end
							else if (!cache[index][MEM_SIZE-1]) begin
								hit <= 0;
								miss_count <= miss_count + 1;
								state <= READ_MISS;
								read_m <= 1;
								write_m <= 0;
							end
							else begin
								if (cache[index][MEM_SIZE-2]) begin
									state <= WRITE_BACK;
									read <= 1;
									write <= 0;
									read_m <= 1;
									write_m <= 0;
								end
								else begin
									state <= READ_MISS;
									read_m <= 1;
									write_m <= 0;
								end
								hit <= 0;
								miss_count <= miss_count + 1;
							end
						end
						else if (mem_wstrb_cpu) begin
							if (tag == cache[index][MEM_SIZE-3:DATA_SIZE] && cache[index][MEM_SIZE-1]) begin
								hit <= 1;
								hit_count <= hit_count + 1;
								if (cache[index][MEM_SIZE-2]) begin
									state <= WRITE_BACK;
									write <= 1;
									read <= 0;
									read_m <= 0;
									write_m <= 1;
								end
								else begin
									state <= WRITE;
								end
							end
							else if (!cache[index][MEM_SIZE-1]) begin
								hit <= 0;
								miss_count <= miss_count + 1;
								state <= WRITE_MISS;
								read_m <= 0;
								write_m <= 1;
							end
							else begin
								if (cache[index][MEM_SIZE-2]) begin
									state <= WRITE_BACK;
									read <= 0;
									write <= 1;
									read_m <= 0;
									write_m <= 1;
								end
								else begin
									state <= WRITE_MISS;
									read_m <= 0;
									write_m <= 1;
								end
								hit <= 0;
								miss_count <= miss_count + 1;
							end
						end
					end
					else state <= IDLE;
				end
				READ: begin
					case (offset)
						4'b0000, 4'b0001, 4'b0010, 4'b0011: begin
							mem_rdata_cpu <= cache[index][0 +: WORD_SIZE];
							mem_ready_cpu <= 1;
						end
						4'b0100, 4'b0101, 4'b0110, 4'b0111: begin
							mem_rdata_cpu <= cache[index][WORD_SIZE +: WORD_SIZE];
							mem_ready_cpu <= 1;
						end
						4'b1000, 4'b1001, 4'b1010, 4'b1011: begin
							mem_rdata_cpu <= cache[index][2*WORD_SIZE +: WORD_SIZE];
							mem_ready_cpu <= 1;
						end
						4'b1100, 4'b1101, 4'b1110, 4'b1111: begin
							mem_rdata_cpu <= cache[index][3*WORD_SIZE +: WORD_SIZE];
							mem_ready_cpu <= 1;
						end
					endcase
					state <= IDLE;
				end
				READ_MISS: begin
					case (offset)
						4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b1000, 4'b1001, 4'b1010, 4'b1011: begin
							mem_addr_ext <= mem_addr_cpu;
						end
						4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1100, 4'b1101, 4'b1110, 4'b1111: begin
							mem_addr_ext <= mem_addr_cpu - 4;
						end
					endcase
				   mem_valid_ext <= 1;
				   mem_wstrb_ext <= 0;
				   state <= MEM_READ;
				end
				MEM_READ: begin
					if (mem_ready_ext) begin
						cache[index][word_count*WORD_SIZE +: WORD_SIZE] <= mem_rdata_ext;
						if (word_count == WORDS-1) begin
							cache[index][MEM_SIZE-1] <= 1;
							cache[index][MEM_SIZE-2] <= 0;
							cache[index][MEM_SIZE-3:DATA_SIZE] <= tag;
							mem_valid_ext <= 0;
							word_count <= 0;
							if (read_m) begin
								state <= READ;
								read_m <= 0;
								write_m <= 0;
							end
							if (write_m) begin
								state <= WRITE;
								write_m <= 0;
								read_m <= 0;
							end
						end
						else begin
							word_count <= word_count + 1;
							mem_addr_ext <= mem_addr_ext + 4;
							mem_valid_ext <= 1;
							mem_wstrb_ext <= 0;
							state <= MEM_READ;
						end
					end
					else begin
						state <= MEM_READ;
					end
				end
				WRITE: begin
					case (offset)
						4'b0000, 4'b0001, 4'b0010, 4'b0011: begin
							if (mem_wstrb_cpu[0]) cache[index][0 +: 8] <= mem_wdata_cpu[0 +: 8];
							if (mem_wstrb_cpu[1]) cache[index][8 +: 8] <= mem_wdata_cpu[8 +: 8];
							if (mem_wstrb_cpu[2]) cache[index][16 +: 8] <= mem_wdata_cpu[16 +: 8];
							if (mem_wstrb_cpu[3]) cache[index][24 +: 8] <= mem_wdata_cpu[24 +: 8];
							cache[index][MEM_SIZE-2] <= 1;
							cache[index][MEM_SIZE-1] <= 1;
							mem_ready_cpu <= 1;
						end
						4'b0100, 4'b0101, 4'b0110, 4'b0111: begin
							if (mem_wstrb_cpu[0]) cache[index][32 +: 8] <= mem_wdata_cpu[0 +: 8];
							if (mem_wstrb_cpu[1]) cache[index][40 +: 8] <= mem_wdata_cpu[8 +: 8];
							if (mem_wstrb_cpu[2]) cache[index][48 +: 8] <= mem_wdata_cpu[16 +: 8];
							if (mem_wstrb_cpu[3]) cache[index][56 +: 8] <= mem_wdata_cpu[24 +: 8];
							cache[index][MEM_SIZE-2] <= 1;
							cache[index][MEM_SIZE-1] <= 1;
							mem_ready_cpu <= 1;
						end
						4'b1000, 4'b1001, 4'b1010, 4'b1011: begin
							if (mem_wstrb_cpu[0]) cache[index][64 +: 8] <= mem_wdata_cpu[0 +: 8];
							if (mem_wstrb_cpu[1]) cache[index][72 +: 8] <= mem_wdata_cpu[8 +: 8];
							if (mem_wstrb_cpu[2]) cache[index][80 +: 8] <= mem_wdata_cpu[16 +: 8];
							if (mem_wstrb_cpu[3]) cache[index][88 +: 8] <= mem_wdata_cpu[24 +: 8];
							cache[index][MEM_SIZE-2] <= 1;
							cache[index][MEM_SIZE-1] <= 1;
							mem_ready_cpu <= 1;
						end
						4'b1100, 4'b1101, 4'b1110, 4'b1111: begin
							if (mem_wstrb_cpu[0]) cache[index][96 +: 8] <= mem_wdata_cpu[0 +: 8];
							if (mem_wstrb_cpu[1]) cache[index][104 +: 8] <= mem_wdata_cpu[8 +: 8];
							if (mem_wstrb_cpu[2]) cache[index][112 +: 8] <= mem_wdata_cpu[16 +: 8];
							if (mem_wstrb_cpu[3]) cache[index][120 +: 8] <= mem_wdata_cpu[24 +: 8];
							cache[index][MEM_SIZE-2] <= 1;
							cache[index][MEM_SIZE-1] <= 1;
							mem_ready_cpu <= 1;
						end
					endcase
					state <= IDLE;
				end
				WRITE_MISS: begin
					case (offset)
						4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b1000, 4'b1001, 4'b1010, 4'b1011: begin
							mem_addr_ext <= mem_addr_cpu;
						end
						4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1100, 4'b1101, 4'b1110, 4'b1111: begin
							mem_addr_ext <= mem_addr_cpu - 4;
						end
					endcase
					mem_valid_ext <= 1;
				   	mem_wstrb_ext <= 0;
				   	state <= MEM_READ;
				end
				MEM_WRITE: begin
					if (mem_ready_ext) begin
						if (word_count == WORDS-1) begin
							mem_valid_ext <= 0;
							word_count <= 0;
							mem_wstrb_ext <= 4'b0000;
							if (write) begin
								if (hit) state <= WRITE;
								else state <= WRITE_MISS;
								write <= 0;
								read <= 0;
							end
							if (read) begin
								state <= READ_MISS;
								read <= 0;
								write <= 0;
							end
						end
						else begin
							word_count <= word_count + 1;
							mem_addr_ext <= mem_addr_ext + 4;
							mem_wdata_ext <= cache[index][(word_count+1)*WORD_SIZE +: WORD_SIZE];
							mem_valid_ext <= 1;
							mem_wstrb_ext <= 4'b1111;
						end
					end
					else begin
						state <= MEM_WRITE;
					end
				end
				WRITE_BACK: begin
					mem_addr_ext <= {cache[index][MEM_SIZE-3:DATA_SIZE], index, {OFFSET_SIZE{1'b0}}};
					mem_wdata_ext <= cache[index][word_count*WORD_SIZE +: WORD_SIZE];
					mem_valid_ext <= 1;
					mem_wstrb_ext <= 4'b1111;
					state <= MEM_WRITE;
				end
			endcase
		end
		mem_instr_ext <= mem_instr_cpu;
	end
endmodule

module system (
	input            clk,
	input            resetn,
	input			 switch,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en,
	output reg [7:0] out_anode,
	output reg [7:0] out_cathode
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 16,384 32bit words = 64kB memory
	parameter MEM_SIZE = 16384;

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	wire mem_valid_ext;
	wire mem_instr_ext;
	wire mem_ready_ext;
	wire [31:0] mem_addr_ext;
	wire [31:0] mem_wdata_ext;
	wire [3:0] mem_wstrb_ext;
	wire [31:0] mem_rdata_ext;

	wire 				enable_mem_ext;
	wire [31:0] 		number_display;
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
				  .clk				(clk),
				  .resetn			(resetn),
				  .switch			(switch),
				  .number_display	(number_display[31:0]));

	memoryExt memoryExtern(
				  // Outputs
				  .mem_ready	(mem_ready_ext),
				  .out_byte_en	(enable_mem_ext),
				  .mem_rdata	(mem_rdata_ext[31:0]),
				  .bin			(number_display[31:0]),
				  // Inputs
				  .clk			(clk),
				  .resetn		(resetn),
				  .mem_valid	(mem_valid_ext),
				  .mem_instr	(mem_instr_ext),
				  .mem_addr		(mem_addr_ext[31:0]),
				  .mem_wdata	(mem_wdata_ext[31:0]),
				  .mem_wstrb	(mem_wstrb_ext[3:0])
	);

	cache_direct cache(
		.clk			   	(clk),
		.resetn			   	(resetn),
		.mem_valid_cpu		(mem_valid),
		.mem_instr_cpu		(mem_instr),
		.mem_ready_cpu		(mem_ready),
		.mem_addr_cpu 		(mem_addr),
		.mem_wdata_cpu		(mem_wdata),
		.mem_wstrb_cpu		(mem_wstrb),
		.mem_rdata_cpu		(mem_rdata),

		.mem_valid_ext		(mem_valid_ext),
		.mem_instr_ext		(mem_instr_ext),
		.mem_ready_ext		(mem_ready_ext),
		.mem_addr_ext 		(mem_addr_ext),
		.mem_wdata_ext		(mem_wdata_ext),
		.mem_wstrb_ext		(mem_wstrb_ext),
		.mem_rdata_ext		(mem_rdata_ext)
	);
	

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			/*
				Fast mem is off, so skipping this case.
			*/
      	end
	end else begin
		always @(posedge clk) begin
			out_anode <= outanode;
			out_cathode <= outcathode;
			out_byte_en <= enable_mem_ext;
		end
	end endgenerate
endmodule
