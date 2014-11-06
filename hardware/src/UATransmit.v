module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output    reg    SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------
   wire 	SymbolEdge;
   //wire 	Sample;
   wire 	Start;
   wire 	TXRunning;
   wire [9:0] 	TXShift;
   reg [3:0] 	BitCounter;
   reg [ClockCounterWidth-1:0] ClockCounter;
   reg 			       hold;

   assign Start = DataInValid && !TXRunning;
   
   assign  SymbolEdge   = (ClockCounter == SymbolEdgeTime - 1);
   assign TXShift = (DataInValid || hold)?{1'b1,DataIn,1'b0}:10'b0;
   assign DataInReady = !TXRunning;
   assign  TXRunning     = BitCounter != 4'd0;
   
   always @ (posedge Clock) begin
      ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
   end

   always @ (posedge Clock) begin
    if (Reset) 
    begin
      BitCounter <= 0;       
    end 
    else if (Start) 
    begin
      BitCounter <= 10;
    end 
    else if (SymbolEdge && TXRunning) 
    begin
      BitCounter <= BitCounter - 1;
    end
    else
    begin
        BitCounter = BitCounter;
    end
   end

   always @ (posedge Clock) begin
      if (!Reset)begin
	 if (!TXRunning)
	   hold<=0;
	 else
	   hold<=1;
      end
      else
	hold <= 0;
      
      
   end
   

   always @(posedge Clock) begin
    if (TXRunning)
    begin
      SOut <= TXShift[10-BitCounter];
    end
    else
    begin
        SOut <= SOut;
    end
  end
endmodule
