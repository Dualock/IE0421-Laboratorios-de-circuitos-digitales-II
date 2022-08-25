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

