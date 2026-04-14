`timescale 1ns / 1ps

module TaskB_OpcodeTester(
    input  wire [3:0] switches, // SW0 to SW3
    output reg  [7:0] leds      // LED0 to LED7 (LED7 will be 0)
);

    // RISC-V 7-bit Opcodes [cite: 2921, 2925-2927]
    parameter OPC_RTYPE = 7'b0110011; // For SLT 
    parameter OPC_JTYPE = 7'b1101111; // For JAL 
    parameter OPC_BTYPE = 7'b1100011; // For BNE 
    parameter OPC_UTYPE = 7'b0110111; // For LUI 

    always @(*) begin
        if (switches[3])      // Switch 3 ON -> LUI
            leds = {1'b0, OPC_UTYPE};
        else if (switches[2]) // Switch 2 ON -> BNE
            leds = {1'b0, OPC_BTYPE};
        else if (switches[1]) // Switch 1 ON -> JAL
            leds = {1'b0, OPC_JTYPE};
        else if (switches[0]) // Switch 0 ON -> SLT
            leds = {1'b0, OPC_RTYPE};
        else
            leds = 8'b00000000; // All OFF if no switch is up
    end

endmodule