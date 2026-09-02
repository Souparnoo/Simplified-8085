`timescale 10ns/1ns
module register(input clk, input rst, input en, input [7:0] idata, output reg [7:0] odata);

	always @(posedge clk or posedge rst) begin
		if(rst)
			odata <= {8{1'b0}};
		else if(en)
			odata <= idata;
	end

endmodule
