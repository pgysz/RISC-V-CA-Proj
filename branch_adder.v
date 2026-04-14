`timescale 1ns / 1ps
module branch_adder(
    input wire [31:0] PC,
    input wire [31:0] imm,
    output wire [31:0] BranchTarget
);
    // Standard addition. The immGen already formats the byte offset.
    assign BranchTarget = PC + imm; 
endmodule