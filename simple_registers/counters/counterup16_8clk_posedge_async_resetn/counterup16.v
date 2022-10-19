////////////////////////////////////////
//  Functionality: 16 bit up counter 
////////////////////////////////////////

module counterup16 (clk, reset, count);
	input clk, reset;
	output [15:0] count;
	reg [15:0] count;                                   

	initial begin
      	  count <= 0;
    	end   

	always @ (posedge clk or negedge reset) begin
		if (reset == 1'b0)
		  count <= 16'h0;
		else 
		  count <= count + 1;
	end

endmodule  
