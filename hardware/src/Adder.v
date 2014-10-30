//-----------------------------------------------------------------------------
//  Module: Adder.v
//  Desc: Adds two 32 bit input numbers  
//  Inputs Interface:
//    a: first input (asynchronous)
//    b: second input (asynchronous)
//  Output Interface:
//    c: summation of a and b
//-----------------------------------------------------------------------------

module Adder(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c);

    assign c = a + b;

endmodule
