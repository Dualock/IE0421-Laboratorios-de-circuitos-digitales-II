
`include "arr_multiplier_4b.v"
module test;
	reg rstn;
	reg [3:0] A;
	reg [3:0] B;
	reg clk;
	wire [7:0] Result; 

	arr_multiplier_4b arr(.rstn	(rstn),
				.A	(A),
				.B	(B),
				.Result	(Result));
	initial begin
	    	$dumpfile("arr_multiplier_4b.vcd"); 
		$dumpvars;
		$display("RSLT\tA x B = Result");
		$monitor($time,"\t%b\t%b\t%b", A, B, Result);
		rstn = 1;
		@(posedge clk);
		rstn = 1;
		A = 1;
		B = 2;
		@(posedge clk);
		A = 2;
		B = 1;
		@(posedge clk);
		A = 2;
		B = 2;
		$finish;
	end 

	initial	clk 	<= 0;
	always	#2 clk 	<= ~clk;
endmodule
