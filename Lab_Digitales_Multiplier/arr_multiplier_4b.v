module adder(
	input rstn,
	input ab0,
	input ab1,
	input ci,
	output a_plus_b,
	output co,
);
assign {co,a_plus_b} = ci + ab0+ab1
endmodule
module arr_multiplier_4b (
	input rstn,
	input [3:0]A,
	input [3:0]B,
	input clk,
	output reg [7:0] Result
);
wire[7:0] wCarry;
wire [7:0] wResult;
assign wResult[0] = A[0]&B[0];
assign {wCarry[0], wResult[1]} =  A[1]&B[0]+A[0]&B[1];
//assign {wcarry[1], wResult[2]} = A[1]&B[1] + A[2]&B[0] + wCarry[0];

always @(*) begin
	if(!rstn) begin
		Result <= 7'b0;
	end
	else begin
	
	Result = {wResult[7],wResult[6],wResult[5],wResult[4],wResult[3],wResult[2],wResult[1],wResult[0]};
	end
end
endmodule

