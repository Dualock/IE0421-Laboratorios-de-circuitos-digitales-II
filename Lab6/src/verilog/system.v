`timescale 1 ns / 1 ps
//`include "7_segment_hex.v"
`include "text_display.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	input 					 irq_bit,
	output reg   		[7:0] out_byte,
	output reg       out_byte_en,
	output     			[7:0] out_anode,
	output     			[7:0] out_cathode
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;
	parameter ENABLE_IRQ = 1;
	parameter ENABLE_IRQ_QREGS = 0;
	parameter LATCHED_IRQ = 32'h0000_0000;
	parameter EMPTY_WORD = 32'h0000_0000;


	//parameter MASKED_IRQ = 32'h0000_0000;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	reg [31:0] irq_input = 0;
	reg[3:0] selector;
	wire [7:0] txtd_anode_out;
	wire [7:0] txtd_cathode_out;
	reg [4:0] selector;
	//usamos el bit #10 para el interrupt request


	picorv32 #(.ENABLE_IRQ(ENABLE_IRQ),
													 .ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS),
													 .LATCHED_IRQ(LATCHED_IRQ)

		)picorv32_core(
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
		.mem_la_wstrb(mem_la_wstrb),
		.irq				  (irq_input)
	);

	text_display txt_display(
			.clk				(clk),
			.resetn			(resetn),
			.selector		(selector),
			.enable			(1),
			.an_out			(txtd_anode_out),
			.c_out			(txtd_cathode_out)
		);

	reg [31:0] memory [0:MEM_SIZE-1];

	assign out_anode = txtd_anode_out;
	assign out_cathode = txtd_cathode_out;

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
		  irq_input <= {EMPTY_WORD[31:10], irq_bit, EMPTY_WORD[8:0]};
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
			end
			if (mem_la_write && mem_la_addr == 32'h1000_0010) begin
				out_byte_en <= 1;
				selector <= mem_la_wdata;
			end
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
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0010: begin
					out_byte_en <= 1;
					selector <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
		end
	 endgenerate
endmodule
