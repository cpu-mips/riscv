//  Module: RegFileTestbench
//  Desc:   32-bit Adder testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module RegFileTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd, REFrd1, REFrd2;
    wire [31:0] rd1, rd2;

    // Task for checking output
    task checkOutput;
        if ( rd1 == REFrd1 && rd2 == REFrd2 ) begin
            $display("PASS: Registers %b and %b", ra1, ra2);
        end
        else begin
            if (rd1 !== REFrd1)
            begin
                $display("FAIL: ra1=%b", ra1);
                $display("\tis: %b, should be: %b", rd1, REFrd1);
            end
            if (rd2 !== REFrd2)
            begin
                $display("FAIL: ra2= %b", ra2);
                $display("\tis: %b, should be: %b", rd2, REFrd2);
            end
            $finish();
        end
    endtask

    RegFile DUT(
        .clk(Clock),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2));

    // Testing logic:
    initial begin
       we = 1'b1;
       ra1 = 1'b0;
       ra2 = 1'b0;
       wa = 32'b0;
       wd = 32'b0;
       #10;
       wa=1;
       wd=1;
       #10;
       wa=2;
       wd=2;
       #10;
       wa=3;
       wd=3;
       #10
       we = 1'b0;
       ra1 = 0;
       ra2 = 1;
       REFrd1 = 32'b0;
       REFrd2 = 32'b1;
       #10
       checkOutput();

       ra1=2;
       ra2=3;
       REFrd1 = 32'b10;
       REFrd2 = 32'b11;
       #10
       checkOutput();

       wa = 5;
       wd = 5;
       #10

       ra1 = 5;
       REFrd1 = 32'b0;
       checkOutput();


       
       $display("ALL TESTS PASS");
       $finish();
       
    end

  endmodule
