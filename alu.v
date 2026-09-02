`timescale 10ns/1ns
module alu(input [1:0] alu_op, input [7:0] A, input [7:0] B, input [7:0] F, output [7:0] oR, output [7:0] oF);

    wire adc, aci, sbb, ana, cmp;
    wire auxa, auxb, auxc;

//fetch
    assign adc = ~alu_op[1] & ~alu_op[0]; //if alu_op is 00, then adc is true
    assign aci = ~alu_op[1] & ~alu_op[0]; //if alu_op is 00, then aci is true (alu does not know if from where the iB is coming)
    assign sbb = ~alu_op[1] & alu_op[0]; //if alu_op is 01, then sbb is true
    assign ana = alu_op[1] & ~alu_op[0]; //if alu_op is 10, then ana is true
    assign cmp = alu_op[1] & alu_op[0]; //if alu_op is 11, then cmp is true

//carry
    assign {oF[0],oR} = (adc) ? A+B+F[0] : {9{1'bz}}; //if adc is true, then oR = A + B + carry flag (0th position), else high impedance
    assign {oF[0],oR} = (aci) ? A+B+F[0] : {9{1'bz}}; //if aci is true, then oR = A + B + carry flag (0th position), else high impedance
    assign {oF[0],oR} = (sbb) ? A-B-F[0] : {9{1'bz}}; //if sbb is true, then oR = A - B - carry flag (0th position), else high impedance
    assign {oF[0],oR} = (cmp) ? A-B : {9{1'bz}}; //if cmp is true, then oR = A - B, else high impedance
    assign {oF[0],oR} = (ana) ? {1'b0,A&B} : {9{1'bz}}; //if ana is true, then oR = A & B, else high impedance

//not used
    assign oF[1] = 1'b0;
    assign oF[3] = 1'b0;
    assign oF[5] = 1'b0;

//zero
    assign oF[6] = ~|oR; //NOR the whole output register

//sign
    assign oF[7] = oR[7]; //Just check MSB of output register

//parity
    assign oF[2] = ~^oR; //XNOR the whole output register

//Auxiliary carry
    assign oF[4] = (adc | aci | sbb | cmp) ? auxc : 1'bz;
    assign auxa = A[4] ^ B[4] ^ oR[4]; //for addition (adc and aci)
    assign auxb = B[3] & (~A[3] | oR[3]);//for subtraction (sbb) and comparison (cmp)
    assign auxc = (adc | aci) ? auxa : auxb;
    assign oF[4] = (ana) ? 1'b1 : 1'bz; //ana always sets auxillary carry flag

endmodule
