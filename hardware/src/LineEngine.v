module LineEngine(
  input                 clk,
  input                 rst,
  output                LE_ready,
  // 8-bit each for RGB, and 8 bits zeros at the top
  input [31:0]          LE_color,
  // 800 x 600 => 10 bits x 10 bits
  input [9:0]           LE_point,
  // Valid signals for the inputs
  input                 LE_color_valid,
  input                 LE_x0_valid,
  input                 LE_y0_valid,
  input                 LE_x1_valid,
  input                 LE_y1_valid,
  // Trigger signal - line engine should start drawing the line
  input                 LE_trigger,
  // FIFO connections
  input                 af_full,
  input                 wdf_full,
  
  output [30:0]         af_addr_din,
  output                af_wr_en,
  output [127:0]        wdf_din,
  output [15:0]         wdf_mask_din,
  output                wdf_wr_en
);

    localparam IDLE = 2'b0;
    localparam START = 2'b1;
	localparam DRAW = 2'b10;
	wire stall;
    reg [1:0] cs, ns;
    reg ystep, steep;
    reg [31:0] x0_temp, x1_temp, y0_temp, y1_temp, x0, x1, y0, y1;
    reg [31:0] abs_deltax, abs_deltay, deltax, deltay, error;
    reg [31:0] x_reg, y_reg, error_reg, x_reg_final;
	reg [31:0] addr, color;
	reg [3:0] we;
    // Implement Bresenham's line drawing algorithm here!
	assign LE_ready = (cs == IDLE) ? 1:0;
    CacheBypass cache(.clk(clk),
						.rst(rst),
						.addr(addr),
						.din(color),
						.we(we),
						.af_full(af_full),
						.wdf_full(wdf_full),
						.stall(stall),
						.af_addr_din(af_addr_din),
						.af_wr_en(af_wr_en),
						.wdf_din(wdf_din),
						.wdf_mask_din(wdf_mask_din),
						.wdf_wr_en(wdf_wr_en)
						);
    always @(*) begin
		if (cs == IDLE || cs == START) begin
        	x0_temp = (cs == IDLE && LE_x0_valid) ? LE_point:x0_temp;
			x1_temp = (cs == IDLE && LE_x1_valid) ? LE_point:x1_temp;
			y0_temp = (cs == IDLE && LE_y0_valid) ? LE_point:y0_temp;
			y1_temp = (cs == IDLE && LE_y1_valid) ? LE_point:y1_temp;
        	if (x1>x0) begin
            	abs_deltax = x1-x0;
        	end else begin
           		abs_deltax = x0-x1;
        	end if (y1>y0) begin
            	abs_deltay = y1-y0;
        	end else begin
            	abs_deltay = y0-y1;
        	end
			steep = (abs_deltay > abs_deltax) ? 1:0;
        	if (steep) begin
				if (x0_temp>x1_temp) begin
					x0 = y1_temp;
					x1 = y0_temp;
					y0 = x1_temp;
					y1 = x0_temp;
				end else begin
					x0 = y0_temp;
					x1 = y1_temp;
					y0 = x0_temp;
					y1 = x1_temp;
				end
			end else begin
				if (x0_temp > x1_temp) begin
					x0 = x1_temp;
					x1 = x0_temp;
					y0 = y1_temp;
					y1 = y0_temp;
				end else begin
					x0 = x0_temp;
					x1 = x1_temp;
					y0 = y0_temp;
					y1 = y1_temp;
				end
			end
			deltax = x1-x0;
			deltay = (y1>y0) ? y1-y0:y0-y1;
			error = deltax/2;
			ystep = (y1>y0) ? 1:-1;
			if (LE_color_valid) color = LE_color;
		end
	end

 
    always @ (posedge clk) begin
		//if (~stall) begin
        	if (rst) begin
            	cs <= IDLE;
        	end else begin
            	cs <= ns;
        	end
		//end
    end

    always @ (*) begin
        case (cs)
            IDLE: ns = (LE_trigger) ? START : IDLE;
			START: ns = (~stall) ? DRAW:START;
            DRAW: ns = (x_reg < x1+1) ? DRAW : IDLE;
			default: ns = IDLE;
        endcase
    end
    
	always @ (*) begin
		if (cs == DRAW) begin
			if (~stall) we = 4'b1111;
			else we = 4'b0;
		end
	end
	
    always @ (posedge clk) begin
		if (~rst) begin
		if (cs == START) begin
			error_reg <= error;
			y_reg <= y0;
			x_reg <= x0;
		end
        if (cs == DRAW) begin
            if (~stall) begin
				//we <= 4'b1111;
				//x_reg<=x_reg+1;
				//addr <= (steep) ? {12'b000000000001, x_reg[9:0], y_reg[9:3], 2'b0}:{12'b000000000001, y_reg[9:0], x_reg[9:3], 2'b0};
				addr <=(steep) ?  {10'b0001000001, x_reg_final[9:0], y_reg[9:0], 2'b0} : {10'b0001000001, y_reg[9:0], x_reg_final[9:0], 2'b0};
				if ($signed(error_reg) < 0) begin
					x_reg_final<=x_reg;
					x_reg<=x_reg+1;
                    y_reg <= y_reg+ystep;
                    error_reg <= error_reg + deltax-deltay;
                end
				else begin
					x_reg_final <= x_reg;
					x_reg <=x_reg+1; 
					error_reg <= error_reg - deltay;
					y_reg<=y_reg;
				end 
            end else begin
				x_reg_final <= x_reg_final;
				x_reg <= x_reg;
				//we <= 4'b0;
				addr <= addr;
				error_reg <= error_reg;
				y_reg <= y_reg;
			end
        end
		end else begin
			x_reg <= 32'b0;
			y_reg<=32'b0;
			error_reg<=32'b0;
		end
    end       



    // Remove these when you implement this module:
    /*assign af_wr_en = 1'b0;
    assign wdf_wr_en = 1'b0;
    assign LE_ready = 1'b1;*/

endmodule
