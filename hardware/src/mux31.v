module mux31 (input a, input b, input c, input [1:0] sel, output reg out);
	always @ (*) begin
		if (sel == 2'b0)
			out = a;
		else if (sel == 2'b1)
			out = b;
		else
			out = c;
	end
endmodule
