////////////////////////////////////////
//  Functionality: 10 bit up counter 
//  Coder: M Usman Kiani
////////////////////////////////////////

module counterup10_1clk_async_resetp(clk, reset, count);
	input clk, reset;
	output [9:0] count;
	reg [9:0] count;                                   
	
    initial begin
      count <= 0;
    end
	
	always @ (posedge clk or posedge reset) begin
		if (reset)
		  count <= 0;
		else 
		  count <= count + 1;
	end

endmodule  
