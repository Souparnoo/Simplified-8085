`timescale 10ns/1ns
module incdec(input incdec_op, input [7:0] iA, output [7:0] oR);
    assign oR = (incdec_op) ? (iA+1'b1) : (iA-1'b1);
endmodule