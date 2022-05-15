`timescale 1 ns / 1 ps
// mux obtenido de https://www.chipverify.com/verilog/verilog-4to1-mux
module mux ( 
		       input [7:0] 	a, // 4-bit input called a
                       input [7:0] 	b, // 4-bit input called b
                       input [7:0] 	c, // 4-bit input called c
                       input [7:0] 	d, // 4-bit input called d
                       input [1:0] 	sel, // input sel used to select between a,b,c,d
		       input 		clk,
		       input 		resetn,
                       output reg [7:0] out
		       );         // 4-bit output based on input sel

   // This always block gets executed whenever a/b/c/d/sel changes value
   // When that happens, based on value in sel, output is assigned to either a/b/c/d
   always @ (posedge clk) begin
      if (!resetn) begin
	 out <= 0;
      end else begin
	 case (sel)
           2'b00 : out <= a;
           2'b01 : out <= b;
           2'b10 : out <= c;
           2'b11 : out <= d;
	 endcase // case (sel)
      end
   end
endmodule

module mux32 ( 
		       input [31:0] 	a, // 32-bit input called a
                       input [31:0] 	b, // 32-bit input called b
                       input [31:0] 	c, // 32-bit input called c
                       input [31:0] 	d, // 32-bit input called d
                       input [1:0] 	sel, // input sel used to select between a,b,c,d
		       input 		clk,
		       input 		resetn,
                       output reg [31:0] out
		       );         // 32-bit output based on input sel

   // This always block gets executed whenever a/b/c/d/sel changes value
   // When that happens, based on value in sel, output is assigned to either a/b/c/d
   always @ (posedge clk) begin
      if (!resetn) begin
	 out <= 0;
      end else begin
	 case (sel)
           2'b00 : out <= a;
           2'b01 : out <= b;
           2'b10 : out <= c;
           2'b11 : out <= d;
	 endcase // case (sel)
      end
   end
endmodule

module lut_multiplier_4b(
			 input [3:0] 	  factor0,
			 input [3:0] 	  factor1,
			 input 		  resetn,
			 input 		  clk,
			 output reg [7:0] resultado
);
   wire [7:0] 				  calc0, calc1;
   reg [7:0] 				  a0,b0,c0,d0;
   reg [1:0] 				  sel0, sel1;
   reg [7:0] 				  temp;
   
   mux mux0(
	   // Outputs
	    .out			(calc0),
	   // Inputs
	    .a				(a0),
	    .b				(b0),
	    .c				(c0),
	    .d				(d0),
	    .sel			(sel0),
	    .clk		       	(clk),
	    .resetn			(resetn));
   mux mux1(
	   // Outputs
	    .out			(calc1),
	   // Inputs
	    .a				(a0),
	    .b				(b0),
	    .c				(c0),
	    .d				(d0),
	    .sel			(sel1),
	    .clk			(clk),
	    .resetn			(resetn));
   
   always @(posedge clk) begin
      if(!resetn) begin
	 resultado <= 0;
	 a0 <= 0;
	 b0 <= 0;
	 c0 <= 0; 
	 d0 <= 0;
	 temp <= 0;
	 sel0 <= 0;
	 sel1 <= 0;
      end
      else begin
	 resultado <= 0;
	 a0 <= 8'b0;
	 b0 <= factor0;
	 c0 <= factor0 << 1;
	 d0 <= (factor0 << 1) + factor0;
	 sel0 <= factor1 [1:0];
	 sel1 <= factor1 [3:2];
	 temp <= calc1<<2;
	 resultado <= temp + calc0;
      end // else: !if(!resetn)
   end // always @ (posedge clk)
endmodule

module lut_multiplier_8b(
			 input [7:0] 	   factor0,
			 input [7:0] 	   factor1,
			 input 		   resetn,
			 input 		   clk,
			 output reg [15:0] resultado
);
   reg [15:0] 				   temp0, temp1, temp2, temp3;
   wire [7:0] 				   multiOutA, multiOutB, multiOutC, multiOutD;
   
   lut_multiplier_4b multA(
			   // Outputs
			   .resultado		(multiOutA[7:0]),
			   // Inputs
			   .factor0		(factor0[3:0]),
			   .factor1		(factor1[7:4]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_4b multB(
			   // Outputs
			   .resultado		(multiOutB[7:0]),
			   // Inputs
			   .factor0		(factor0[3:0]),
			   .factor1		(factor1[3:0]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_4b multC(
			   // Outputs
			   .resultado		(multiOutC[7:0]),
			   // Inputs
			   .factor0		(factor0[7:4]),
			   .factor1		(factor1[7:4]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_4b multD(
			   // Outputs
			   .resultado		(multiOutD[7:0]),
			   // Inputs
			   .factor0		(factor0[7:4]),
			   .factor1		(factor1[3:0]),
			   .resetn		(resetn),
			   .clk			(clk));
   
   always @(posedge clk) begin
      if(!resetn) begin
	 resultado <= 0;
	 temp0 <= 0;
	 temp1 <= 0;
	 temp2 <= 0;
	 temp3 <= 0;
      end else begin
	 temp0 <= multiOutA << 4;
	 temp1 <= multiOutB;
	 temp2 <= multiOutC << 8;
	 temp3 <= multiOutD << 4;
	 resultado <= temp1 + temp0 + temp2 + temp3;
      end // else: !if(!resetn)
   end // always @ (posedge clk)
endmodule // lut_multiplier_8b

module lut_multiplier_16b(input [15:0] 	   factor0,
			 input [15:0] 	   factor1,
			 input 		   resetn,
			 input 		   clk,
			 output reg [31:0] resultado
);
   reg [31:0] 				   temp0, temp1, temp2, temp3;
   wire [15:0] 				   multiOutA, multiOutB, multiOutC, multiOutD;

   lut_multiplier_8b multA(
			   // Outputs
			   .resultado		(multiOutA[15:0]),
			   // Inputs
			   .factor0		(factor0[7:0]),
			   .factor1		(factor1[15:8]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_8b multB(
			   // Outputs
			   .resultado		(multiOutB[15:0]),
			   // Inputs
			   .factor0		(factor0[7:0]),
			   .factor1		(factor1[7:0]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_8b multC(
			   // Outputs
			   .resultado		(multiOutC[15:0]),
			   // Inputs
			   .factor0		(factor0[15:8]),
			   .factor1		(factor1[15:8]),
			   .resetn		(resetn),
			   .clk			(clk));
   lut_multiplier_8b multD(
			   // Outputs
			   .resultado		(multiOutD[15:0]),
			   // Inputs
			   .factor0		(factor0[15:8]),
			   .factor1		(factor1[7:0]),
			   .resetn		(resetn),
			   .clk			(clk));
   always @(posedge clk) begin
      if(!resetn) begin
	 resultado <= 0;
	 temp0 <= 0;
	 temp1 <= 0;
	 temp2 <= 0;
	 temp3 <= 0;
      end else begin
	 temp0 <= multiOutA << 8;
	 temp1 <= multiOutB;
	 temp2 <= multiOutC << 16;
	 temp3 <= multiOutD << 8;
	 resultado <= temp1 + temp0 + temp2 + temp3;
      end // else: !if(!resetn)
   end // always @ (posedge clk)
endmodule // lut_multiplier_16b

module lut_multiplier_32b(
			 input [31:0] 	  factor0,
			 input [31:0] 	  factor1,
			 input 		  resetn,
			 input 		  clk,
			 output reg [63:0] resultado
);
   reg [63:0] 				   temp0, temp1, temp2, temp3;
   wire [31:0] 				   multiOutA, multiOutB, multiOutC, multiOutD;

   lut_multiplier_16b multA(
			    // Outputs
			    .resultado		(multiOutA[31:0]),
			    // Inputs
			    .factor0		(factor0[15:0]),
			    .factor1		(factor1[31:16]),
			    .resetn		(resetn),
			    .clk		(clk));
   lut_multiplier_16b multB(
			    // Outputs
			    .resultado		(multiOutB[31:0]),
			    // Inputs
			    .factor0		(factor0[15:0]),
			    .factor1		(factor1[15:0]),
			    .resetn		(resetn),
			    .clk		(clk));
   lut_multiplier_16b multC(
			    // Outputs
			    .resultado		(multiOutC[31:0]),
			    // Inputs
			    .factor0		(factor0[31:16]),
			    .factor1		(factor1[31:16]),
			    .resetn		(resetn),
			    .clk		(clk));
   lut_multiplier_16b multD(
			    // Outputs
			    .resultado		(multiOutD[31:0]),
			    // Inputs
			    .factor0		(factor0[31:16]),
			    .factor1		(factor1[15:0]),
			    .resetn		(resetn),
			    .clk		(clk));
   
   always @(posedge clk) begin
      if(!resetn) begin
	 resultado <= 0;
	 temp0 <= 0;
	 temp1 <= 0;
	 temp2 <= 0;
	 temp3 <= 0;
      end
      else begin
	 temp0 <= multiOutA << 16;
	 temp1 <= multiOutB;
	 temp2 <= multiOutC << 32;
	 temp3 <= multiOutD << 16;
	 resultado <= temp1 + temp0 + temp2 + temp3;
      end // else: !if(!resetn)
   end // always @ (posedge clk)
endmodule

// ------------------ Module Adder ----------------------------
module adder(
	input rstn,
	input ab0,
	input ab1,
	input ci,
	output adder_result,
	output co
);
assign {co,adder_result} = ci + ab0+ab1;
endmodule

//-------------- Module Array Multiplier 4bits ----------------
module arr_multiplier_4b (
	input rstn,
	input [3:0]A,
	input [3:0]B,
	input clk,
	output reg [7:0] Result
);
wire[3:0] carry_row0;
wire[3:0] carry_row1;
wire[3:0] carry_row2;
wire[3:0] column_result_row0;
wire[3:0] column_result_row1;
wire [7:0] wResult;
assign wResult[0] = A[0]&B[0]; //First R0
// AdderXY [X=Row, Y=Column]
//First row of adders			
adder add00(			.rstn		(rstn),	
				.ab0		(A[0]&B[1]),
				.ab1		(A[1]&B[0]),
				.ci		(1'b0),
				.adder_result	(wResult[1]),
				.co		(carry_row0[0])
				);
				
adder add01(			.rstn		(rstn),	
				.ab0		(A[1]&B[1]),
				.ab1		(A[2]&B[0]),
				.ci		(carry_row0[0]),
				.adder_result	(column_result_row0[0]),
				.co		(carry_row0[1])
				);
adder add02(			.rstn		(rstn),	
				.ab0		(A[2]&B[1]),
				.ab1		(A[3]&B[0]),
				.ci		(carry_row0[1]),
				.adder_result	(column_result_row0[1]),
				.co		(carry_row0[2])
				);
adder add03(			.rstn		(rstn),	
				.ab0		(A[3]&B[1]),
				.ab1		(1'b0),
				.ci		(carry_row0[2]),
				.adder_result	(column_result_row0[2]),
				.co		(carry_row0[3])
				);
//Second row of adders				
adder add10(			.rstn		(rstn),	
				.ab0		(A[0]&B[2]),
				.ab1		(column_result_row0[0]),
				.ci		(1'b0),
				.adder_result	(wResult[2]),
				.co		(carry_row1[0])
				);
adder add11(			.rstn		(rstn),	
				.ab0		(A[1]&B[2]),
				.ab1		(column_result_row0[1]),
				.ci		(carry_row1[0]),
				.adder_result	(column_result_row1[0]),
				.co		(carry_row1[1])
				);
adder add12(			.rstn		(rstn),	
				.ab0		(A[2]&B[2]),
				.ab1		(column_result_row0[2]),
				.ci		(carry_row1[1]),
				.adder_result	(column_result_row1[1]),
				.co		(carry_row1[2])
				);
adder add13(			.rstn		(rstn),	
				.ab0		(A[3]&B[2]),
				.ab1		(carry_row0[3]),
				.ci		(carry_row1[2]),
				.adder_result	(column_result_row1[2]),
				.co		(carry_row1[3])
				);
// Third row of adders
adder add20(			.rstn		(rstn),	
				.ab0		(A[0]&B[3]),
				.ab1		(column_result_row1[0]),
				.ci		(1'b0),
				.adder_result	(wResult[3]),
				.co		(carry_row2[0])
				);
adder add21(			.rstn		(rstn),	
				.ab0		(A[1]&B[3]),
				.ab1		(column_result_row1[1]),
				.ci		(carry_row2[0]),
				.adder_result	(wResult[4]),
				.co		(carry_row2[1])
				);
adder add22(			.rstn		(rstn),	
				.ab0		(A[2]&B[3]),
				.ab1		(column_result_row1[2]),
				.ci		(carry_row2[1]),
				.adder_result	(wResult[5]),
				.co		(carry_row2[2])
				);
adder add23(			.rstn		(rstn),	
				.ab0		(A[3]&B[3]),
				.ab1		(carry_row1[3]),
				.ci		(carry_row2[2]),
				.adder_result	(wResult[6]),
				.co		(wResult[7])
				);

always @(posedge clk) begin
	if(!rstn) begin
		Result <= 7'b0;
	end
	else begin
	Result <= {wResult[7],wResult[6],wResult[5],wResult[4],wResult[3],wResult[2],wResult[1],wResult[0]};
	end
end
endmodule

//-------------- Module Array Multiplier 32bits ----------------
module arr_multiplier_32b #(parameter MAX_COLS=32) (
						   input 		       rstn,
						   input [MAX_COLS-1:0]        A,
						   input [MAX_COLS-1:0]        B,
						   input 		       clk,
						   output reg [2*MAX_COLS-1:0] Result
				       		   );
   //wCarry[Rows][Columns]
   wire [MAX_COLS:0]   		wCarry[MAX_COLS-2:0]; // MAX_COLS carries per row, MAX_COLS-2 rows
   wire [MAX_COLS:0]   		ColumnResult[MAX_COLS:0]; //MAX_COLS columns, MAX_COLS-2 rows
   wire [2*MAX_COLS-1:0] 	wResult;
   assign wResult[0] = A[0]&B[0]; //First R0
   genvar 		 	CurrentRow, CurrentCol;
   //CurrentRow = 0;
   generate 
      for (CurrentRow = 0; CurrentRow<MAX_COLS-1; CurrentRow = CurrentRow+1)
	begin:MUL_ROW
	   for(CurrentCol = 0; CurrentCol<MAX_COLS; CurrentCol = CurrentCol+1)
	     begin: MUL_COL
	     	//Set the carry in for all first columns to 0
		assign wCarry[CurrentRow][0] = 0;
		
		if(CurrentRow == 0) begin //if(CurrentCol == MAX_COLS-1 & CurrentRow == 0) begin
		   //Special Case for last row first column
		   if(CurrentCol == MAX_COLS-1) begin
		      adder add(			.rstn		(rstn),	
							.ab0		(B[CurrentRow+1]&A[CurrentCol]),
							.ab1		(1'b0),
							.ci		(wCarry[CurrentRow][CurrentCol]),
							.adder_result	(ColumnResult[CurrentRow][CurrentCol]),
							.co		(wCarry[CurrentRow][CurrentCol+1])
							);		
		   end //  if(CurrentCol == MAX_COLS-1) begin
		   else begin
		      // Special case for all the first Row
		      adder add(			.rstn		(rstn),	
							.ab0		(B[CurrentRow+1]&A[CurrentCol]),
							.ab1		(B[CurrentRow]&A[CurrentCol+1]),
							.ci		(wCarry[CurrentRow][CurrentCol]),
							.adder_result	(ColumnResult[CurrentRow][CurrentCol]),
							.co		(wCarry[CurrentRow][CurrentCol+1])
							);
		   end //else begin
		   
		end // if(CurrentRow == 0)
		//Special case for all the last adder of each row
		else if(CurrentCol == MAX_COLS-1 & CurrentRow!= 0) begin
		   adder add(			.rstn		(rstn),	
						.ab0		(B[CurrentRow+1]&A[CurrentCol]),
						.ab1		(wCarry[CurrentRow-1][CurrentCol+1]),
						.ci		(wCarry[CurrentRow][CurrentCol]),
						.adder_result	(ColumnResult[CurrentRow][CurrentCol]),
						.co		(wCarry[CurrentRow][CurrentCol+1])
						);
		end //else if(CurrentCol == MAX_COLS-1 & CurrentRow!= 0) 
		//Normal adders
		else begin
		   adder add(			.rstn		(rstn),	
						.ab0		(B[CurrentRow+1]&A[CurrentCol]),
						.ab1		(ColumnResult[CurrentRow-1][CurrentCol+1]),
						.ci		(wCarry[CurrentRow][CurrentCol]),
						.adder_result	(ColumnResult[CurrentRow][CurrentCol]),
						.co		(wCarry[CurrentRow][CurrentCol+1])
						);
		   
		end //else begin
		// if first column, add the results to wResult (Adds the first half bits of the result)
		if(CurrentCol==0) begin
		   assign wResult[CurrentRow+1] = ColumnResult[CurrentRow][CurrentCol];
		   assign counterR = CurrentRow;
		   assign counterC = CurrentCol;
		end
		// if last row, add the results to wResult (Adds the rest half-1 bits to the result)
		if(CurrentRow == MAX_COLS-2 & CurrentCol!=0) begin
		   assign wResult[CurrentCol+MAX_COLS-1] = ColumnResult[CurrentRow][CurrentCol];
		end
		// if last row and last column, add the carry to the MSB
	     end
	end//end begin MULT_ROW
	assign wResult[2*MAX_COLS-1] = wCarry[MAX_COLS-2][MAX_COLS];
   endgenerate
   always @(posedge clk) begin
      if(!rstn) begin
	 Result <= 7'b0;
      end
      else begin
	 Result <= wResult;
      end
   end
endmodule

module system (
	       input 		clk,
	       input 		resetn,
	       output 		trap,
	       output reg [7:0] out_byte,
	       output reg 	out_byte_en
	       );
   
   // set this to 0 for better timing but less performance/MHz
   parameter FAST_MEMORY = 1;

   // 4096 32bit words = 16kB memory
   parameter MEM_SIZE = 4096;
   parameter MAX_COLS = 32;
   
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
   
   reg 				out_fact_en;
   reg [31:0] 			out_fact;

   wire [7:0] 			multiOut;
   reg [3:0]			factor0;
   reg [3:0]			factor1;

   wire [63:0] 			multiOut32;
   reg [31:0] 			factor32_0;
   reg [31:0] 			factor32_1;	

   wire [7:0] 			multArrOut;
   reg [3:0] 			factorArr0, factorArr1;
   
   wire [63:0] 			multArrOut32;
   reg [31:0] 			factor32_Arr0,factor32_Arr1; 			
   

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
   
   lut_multiplier_4b multiplicador(
				   // Outputs
				   .resultado		(multiOut),
				   // Inputs
				   .factor0		(factor0),
				   .factor1		(factor1),
				   .resetn		(resetn),
				   .clk			(clk));
   
   lut_multiplier_32b multiplicador32(
				      // Outputs
				      .resultado	(multiOut32),
				      // Inputs
				      .factor0		(factor32_0),
				      .factor1		(factor32_1),
				      .resetn		(resetn),
				      .clk		(clk));
   
   arr_multiplier_4b multiplicadorArr(
				      // Outputs
				      .Result		(multArrOut[7:0]),
				      // Inputs
				      .rstn		(rstn),
				      .A		(factorArr0[3:0]),
				      .B		(factorArr1[3:0]),
				      .clk		(clk));
   arr_multiplier_32b arr_32(
   				      //Outputs
  				      .Result		(multArrOut32[63:0]),
				      // Inputs
				      .rstn		(rstn),
				      .A		(factor32_Arr0[31:0]),
				      .B		(factor32_Arr1[31:0]),
				      .clk		(clk));
   

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
	 out_fact_en <= 0;
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
	   if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
	      out_fact_en <= 1;
	      out_fact <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'h1000_0004) begin
	      factor32_0 <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'h1000_0008) begin
	      factor32_1 <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'h1000_000C) begin
	      factor32_0 <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'h1000_0010) begin
	      factor32_1 <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'hFFFF_FFF0) begin
	      factorArr0 <= mem_la_wdata;
	      factor32_Arr0 <= mem_la_wdata;
	   end
	   if (mem_la_write && mem_la_addr == 32'hFFFF_FFF4) begin
	      factorArr1 <= mem_la_wdata;
	      factor32_Arr1 <= mem_la_wdata;
	   end
	   if (mem_la_read && mem_la_addr == 32'hFFFF_FFF8) begin
	      mem_rdata <= multArrOut;
	      mem_rdata <= multArrOut32[31:0];
	   end
	   if (mem_la_read && mem_la_addr == 32'hFFFF_FFFC) begin
	      mem_rdata <= multArrOut32[63:32];
	   end
	   
      end
   end else begin
      always @(posedge clk) begin
	 m_read_en <= 0;
	 mem_ready <= mem_valid && !mem_ready && m_read_en;

	 m_read_data <= memory[mem_addr >> 2];
	 mem_rdata <= m_read_data;
	 
	 out_byte_en <= 0;
	 out_fact_en <= 0;
	 
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
	      out_fact_en <= 1;
	      out_byte <= mem_wdata;
	      out_fact <= mem_wdata;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0004: begin
	      factor0 <= mem_la_wdata[3:0];
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0008: begin
	      factor1 <= mem_la_wdata[3:0];
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_000C: begin
	      factor32_0 <= mem_la_wdata;
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0010: begin
	      factor32_1 <= mem_la_wdata;
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'hFFFF_FFF0: begin
	      factorArr0 <= mem_la_wdata;
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'hFFFF_FFF4: begin
	      factorArr1 <= mem_la_wdata;
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
	   mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'hFFFF_FFF8: begin
	      mem_rdata <= multArrOut;
	      m_read_en <= 0;
	      mem_ready <= 1;
	   end
   endcase
      end // always @ (posedge clk)
   end endgenerate
endmodule
