`timescale 1ns / 1ps

module tb_TaskC();

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

    // Generate 100MHz Clock
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        switches = 16'd0;

        // Hold reset
        #100;
        rst = 0;
        #200;

        // =========================================================
        // TRIGGER RECURSIVE SUMMATION
        // Flip Switch 4 (Binary 0000_0000_0001_0000)
        // =========================================================
        switches = 16'b0000_0000_0001_0000; // 16'd16
        
        // Wait enough time for the recursion to hit the base case
        // and freeze on the final answer (10). 
        // Note: This assumes you changed the delay loop in task_c.mem to 1!
        #5000000; 

        // Press reset to clear the frozen state
        rst = 1;
        #100;
        rst = 0;
        #100;

        // End simulation
        $stop;
    end

endmodule