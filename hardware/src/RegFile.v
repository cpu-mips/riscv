//-----------------------------------------------------------------------------
//  Module: RegFile
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//-----------------------------------------------------------------------------

module RegFile(input clk,
               input we,
               input  [4:0] ra1, ra2, wa,
               input  [31:0] wd,
               output [31:0] rd1, rd2);

           parameter registers = 32;

           reg [31:0] regfile [0:registers -1];

           assign rd1 = regfile[ra1];
           assign rd2 = regfile[ra2];

           always@(posedge clk)
           begin
               if (1'b1 == we)
               begin
                   if (5'b0 !== wa)
                   begin
                       regfile[wa] <= wd;
                   end
                   else
                   begin
                       regfile[0] <= 0;
                   end
               end
               else
               begin
                   regfile[0] <= 0;
               end
           end
endmodule
