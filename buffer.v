`timescale 10ns/1ns
module buffer(input en , input [7:0] idata, output [7:0] odata);
    assign odata = (en) ? idata : {8{1'bz}};
endmodule