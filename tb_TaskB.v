`timescale 1ns / 1ps

module tb_TaskB();

    // Inputs
    reg clk;
    reg rst;
    reg [15:0] switches;

    // Outputs
    wire [15:0] leds;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Top Level Processor
    TopLevelProcessor uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .leds(leds),
        .seg(seg),
        .an(an)
    );

    // Generate 100MHz Clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        switches = 16'd0;

        // Hold reset for 100ns
        #100;
        rst = 0;
        #200; // Wait for processor to initialize and enter POLL state

        // =========================================================
        // TEST 1: SLT (Switch 1 -> Binary 0000_0000_0000_0010)
        // Expected LEDs: 16'h0001
        // =========================================================
        switches = 16'b0000_0000_0000_0010; // 16'd2
        #1500; // Wait for execution
        switches = 16'd0; // Turn switch off
        #1000; // Wait for FSM to clear LEDs and return to POLL

        // =========================================================
        // TEST 2: JAL & JALR (Switch 2 -> Binary 0000_0000_0000_0100)
        // Expected LEDs: 16'h0002
        // =========================================================
        switches = 16'b0000_0000_0000_0100; // 16'd4
        #1500; 
        switches = 16'd0; 
        #1000; 

        // =========================================================
        // TEST 3: BNE (Switch 4 -> Binary 0000_0000_0001_0000)
        // Expected LEDs: 16'h0004
        // =========================================================
        switches = 16'b0000_0000_0001_0000; // 16'd16
        #1500; 
        switches = 16'd0; 
        #1000; 

        // =========================================================
        // TEST 4: LUI (Switch 8 -> Binary 0000_0001_0000_0000)
        // Expected LEDs: 16'hF000
        // =========================================================
        switches = 16'b0000_0001_0000_0000; // 16'd256
        #1500; 
        switches = 16'd0; 
        #1000; 

        // End simulation
        $stop;
    end

endmodule