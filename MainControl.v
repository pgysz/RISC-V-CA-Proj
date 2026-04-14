`timescale 1ns / 1ps

module MainControl(
    input  wire [6:0] opcode,
    output reg        Branch,
    output reg        MemRead,
    output reg        MemtoReg,
    output reg  [1:0] ALUOp,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        RegWrite,
    output reg        Jump,      
    output reg        Jalr,      
    output reg        Lui        // NEW: Signal for LUI (U-Type)
);
    always @(*) begin
        // Default values
        Branch   = 1'b0; MemRead  = 1'b0; MemtoReg = 1'b0;
        ALUOp    = 2'b00; MemWrite = 1'b0; ALUSrc   = 1'b0;
        RegWrite = 1'b0; Jump     = 1'b0; Jalr     = 1'b0;
        Lui      = 1'b0;

        case(opcode)
            7'b0110011: begin ALUOp = 2'b10; RegWrite = 1'b1; end // R-Type (includes SLT)
            7'b0010011: begin ALUOp = 2'b11; ALUSrc = 1'b1; RegWrite = 1'b1; end // I-Type
            7'b0000011: begin MemRead = 1'b1; MemtoReg = 1'b1; ALUSrc = 1'b1; RegWrite = 1'b1; end // Load
            7'b0100011: begin MemWrite = 1'b1; ALUSrc = 1'b1; end // Store
            7'b1100011: begin Branch = 1'b1; ALUOp = 2'b01; end // B-Type (includes BNE/BEQ)
            7'b1101111: begin Jump = 1'b1; RegWrite = 1'b1; end // J-Type (JAL)
            7'b1100111: begin Jalr = 1'b1; ALUSrc = 1'b1; ALUOp = 2'b00; RegWrite = 1'b1; end // JALR
            7'b0110111: begin Lui = 1'b1; RegWrite = 1'b1; end // U-Type (LUI)
        endcase
    end
endmodule