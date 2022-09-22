////////////////////////////////////////
//  Functionality: 8 bit down counter 
//  Coder: M Usman Kiani
////////////////////////////////////////

module counterup8_1clk_async_resetp(clk, reset, count);
	input clk, reset;
	output [7:0] count;
	reg [7:0] count;                                   
	
    initial begin
      count <= 0;
    end
	
	always @ (posedge clk or posedge reset) begin
		if (reset)
		  count <= 0 ;
		else 
		  count <= count + 1;
	end

endmodule  
