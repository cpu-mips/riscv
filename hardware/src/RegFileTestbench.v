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
            $display("PASS: %d and %d", ra1, ra2);
        end
        else begin
            if (rd1 !== REFrd1)
            begin
                $display("FAIL: address 1, ra1=%d", ra1);
                $display("is: %d, should be: %d", rd1, REFrd1);
            end
            if (rd2 !== REFrd2)
            begin
                $display("FAIL: addres 2, ra2= %d", ra2);
                $display("is: %d, should be: %d", rd2, REFrd2);
            end
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

    integer i=0;
    localparam loops = 32; // number of times to run the tests for
    localparam second_pass = 16;

    // Testing logic:
    initial begin
        ra1 = 0;
        ra2 = 0;
        //for(i = 0; i < loops; i = i + 1)
        //begin
           //#10;
            //if ( 0 == i % 2)
            //begin
                we = 1;
            //end
            //else
            //begin
              //  we = 0;
            //end
            wa = 0;
            wd = 0;
        //end
        //for(i = 0; i < second_pass;i = i + 1)
        //begin
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
       ra1 = 0;
       ra2 = 1;
       REFrd1 = 32'bx;
       REFrd2 = 32'b1;
           //ra1 = (i * 2);
           //ra2 = ra1 + 1;
	   //REFrd1 = 32'bx;
	   //REFrd2 = 32'bx;
       checkOutput();
       ra1=2;
       ra2=3;
       REFrd1 = 32'b10;
       REFrd2 = 32'b11;
       checkOutput();
       
        //end
       $display("ALL TESTS PASS");
       $finish();
       
    end

  endmodule
