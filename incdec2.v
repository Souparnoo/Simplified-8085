`timescale 10ns/1ns
module incdec2(input incdec_op, input [7:0] iA, output [7:0] oR);
    assign oR = (incdec_op) ? (iA+2'b10) : (iA-2'b10);
endmodule
