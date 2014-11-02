module Reg(input clk, input d, input wr_en, output reg q);
   
	always @ (posedge clk)begin
	   if (wr_en)
		q<=d;
	   end
endmodule
