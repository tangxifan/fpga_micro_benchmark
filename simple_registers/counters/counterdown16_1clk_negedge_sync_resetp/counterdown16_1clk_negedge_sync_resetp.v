/////////////////////////////////////////
//  Functionality: 16 bit down counter 
////////////////////////////////////////

module counterdown16_1clk_negedge_sync_resetp(clock0, reset, count);

	input clock0, reset;
	output [15:0] count;
	reg [15:0] count;
                                    

	always @ (negedge clock0) begin
		if (reset == 1'b1) begin
      	  count <= 16'hffff;
		end 
		else begin
			count <= count - 1;
		end
	end

endmodule
