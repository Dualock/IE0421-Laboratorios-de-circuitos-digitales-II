// ------------------ Modulo Adder ----------------------------
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

//-------------- Modulo Array Multiplier 4bits ----------------
module arr_multiplier_32b (
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
assign wResult[0] = A[0]&B[0]; //Pasa el primer resultado a R0
// AdderXY [X=Row, Y=Column]
//Primer fila de sumadores		
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
//Segunda fila de sumadores				
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
// Tercer fila de sumadores
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

always @(A,B,rstn) begin
	if(!rstn) begin
		Result <= 7'b0;
	end
	else begin
	Result <= {wResult[7],wResult[6],wResult[5],wResult[4],wResult[3],wResult[2],wResult[1],wResult[0]};
	end
end
endmodule

