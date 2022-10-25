/////////////////////////////////////////
//  Functionality: 16 bit negedge triggered up counter 
////////////////////////////////////////

module counterup16_1clk_negedge_async_resetp(clock0, reset, count);

	input clock0, reset;
	output [15:0] count;
	reg [15:0] count;                                   
	


	always @ (negedge clock0 or posedge reset) begin
		if (reset == 1'b1) begin
			count <= 0;
		end 
		else begin
			count <= count + 1;
		end
	end

endmodule
