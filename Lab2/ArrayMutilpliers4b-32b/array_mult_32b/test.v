
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
		A=0;
		B=0;
		rstn = 0;
		clk = 0;
		end
	initial begin
	    	$dumpfile("arr_multiplier_4b.vcd"); 
		$dumpvars;
		$display("RSLT\tA x B = Result");
		$monitor($time,"\t%b\t%b\t%b", A, B, Result);
		rstn = 0;
		@(posedge clk);
		rstn = 1;
		A = 3;
		B = 2;
		@(posedge clk);
		A = 7;
		B = 4;
		@(posedge clk);
		A = 15;
		B = 8;
		@(posedge clk);
		A = 0;
		B = 0;
		@(posedge clk);
		rstn = 0;
		repeat (2) begin
		@(posedge clk);
		end
		$finish;
	end 

	initial	clk 	<= 0;
	always	#2 clk 	<= ~clk;
endmodule
