`timescale 1 ns / 1 ps
`include "seven_segment_hex.v"
`include "memoryExt.v"
`include "cache.v"
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
	input            clk,
	input            resetn,
	input			 switch,
	output           trap,
	output  	[7:0] out_byte,
	output        	out_byte_en,
	output  	[7:0] out_anode,
	output  	[7:0] out_cathode
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 16,384 32bit words = 64kB memory
	parameter MEM_SIZE = 16384;
	
		// Seccion 1
	
	parameter CACHETOTALSIZE = 1024;
	parameter WAYS = 2;
	parameter WORDS = 2;
	
	
	// Seccion 2.1
	/*
	parameter CACHETOTALSIZE = 2048;
	parameter WAYS = 2;
	parameter WORDS = 2;
	*/
	
	// Seccion 2.2
	/*
	parameter CACHETOTALSIZE = 2048;
	parameter WAYS = 2;
	parameter WORDS = 4;
	*/
	
	// Seccion 2.3
	
	/*parameter CACHETOTALSIZE = 4096;
	parameter WAYS = 2;
	parameter WORDS = 2;
	*/
	// Seccion 2.4
	
	/*parameter CACHETOTALSIZE = 4096;
	parameter WAYS = 2;
	parameter WORDS = 4;*/
	

	// interfaz procesador-cache
	wire core_mem_valid;
	wire core_mem_instr;
	wire core_mem_ready;
	wire [31:0] core_mem_addr;
	wire [31:0] core_mem_wdata;
	wire [3:0] core_mem_wstrb;
	wire [31:0] core_mem_rdata;
	wire core_mem_la_read;
	wire core_mem_la_write;
	wire [31:0] core_mem_la_addr;
	wire [31:0] core_mem_la_wdata;
	wire [3:0] core_mem_la_wstrb;
	
	// interfaz cache-memoria
	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire 				enable_mem;
	wire [31:0] 			number_display;
	wire [7:0]			outcathode;
	wire [7:0]			outanode;
	
	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	
	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (core_mem_valid   ),
		.mem_instr   (core_mem_instr   ),
		.mem_ready   (core_mem_ready   ),
		.mem_addr    (core_mem_addr    ),
		.mem_wdata   (core_mem_wdata   ),
		.mem_wstrb   (core_mem_wstrb   ),
		.mem_rdata   (core_mem_rdata   ),
		.mem_la_read (core_mem_la_read ),
		.mem_la_write(core_mem_la_write),
		.mem_la_addr (core_mem_la_addr ),
		.mem_la_wdata(core_mem_la_wdata),
		.mem_la_wstrb(core_mem_la_wstrb)
	);

	cache_2_way_random #(.CACHETOTALSIZE(CACHETOTALSIZE),
				.WAYS(WAYS),
				.WORDS(WORDS)
	) cache(
		.clk         (clk         ),
		.resetn      (resetn      ),
		// interfaz procesador-cache
		.core_mem_valid   (core_mem_valid   ),
		.core_mem_instr   (core_mem_instr   ),
		.core_mem_ready   (core_mem_ready   ),
		.core_mem_addr    (core_mem_addr    ),
		.core_mem_wdata   (core_mem_wdata   ),
		.core_mem_wstrb   (core_mem_wstrb   ),
		.core_mem_rdata   (core_mem_rdata   ),
		// interfaz cache-memoria
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   )
	);
	
		/*memory mem (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready_delay   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb),
		.out_byte_32 (number_display[31:0]),
		.out_byte_en (enable_mem )
	);*/
	memoryExt memoryExtern(
				  // Outputs
				  .mem_ready	(mem_ready),
				  .out_byte_en	(enable_mem),
				  .mem_rdata	(mem_rdata[31:0]),
				  .bin			(number_display[31:0]),
				  // Inputs
				  .clk			(clk),
				  .resetn		(resetn),
				  .mem_valid	(mem_valid),
				  .mem_instr	(mem_instr),
				  .mem_addr		(mem_addr[31:0]),
				  .mem_wdata	(mem_wdata[31:0]),
				  .mem_wstrb	(mem_wstrb[3:0])
	);
	wire [31:0] out_byte_32;
	wire wout_byte_en;
	wire [7:0] an_out, c_out;
	seven_segment_switch seven_seg(
				  // Outputs
				  .out_cathode		(outcathode[7:0]),
				  .out_anode		(outanode[7:0]),
				  // Inputs
				  .clk				(clk),
				  .resetn			(resetn),
				  .switch			(switch),
				  .number_display	(number_display[31:0]));
	/*assign out_anode = outanode;
	assign out_cathode = outcathode;
	assign out_byte_en = enable_mem;	
*/
	assign out_byte_en = enable_mem;
	assign out_byte = number_display[7:0];
	assign out_cathode = outcathode;
	assign out_anode = outanode;
	
	/*generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
      	end
	end else begin
		always @(posedge clk) begin
			out_anode <= outanode;
			out_cathode <= outcathode;
			out_byte_en <= enable_mem_ext;
		end
	end endgenerate*/
endmodule
