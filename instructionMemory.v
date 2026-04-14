`timescale 1ns / 1ps

module instructionMemory (
    input  [31:0] instAddress,
    output [31:0] instruction
);

    reg [31:0] rom [0:63];

    initial begin
        
        $readmemh("taskA.mem", rom); 
    end

    // Word-aligned: byte address / 4 = index
    assign instruction = rom[instAddress[7:2]]; 

endmodule