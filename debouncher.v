`timescale 1ns / 1ps

module debouncher(
    input  wire clk,
    input  wire pbin,
    output reg  pbout
);
    // 20ms delay at 100MHz to filter physical bounces
    parameter integer COUNT_MAX = 2_000_000;
    
    reg sync1 = 0, sync2 = 0;
    reg [31:0] cnt = 0;
    reg stable = 0;

    always @(posedge clk) begin
        // 2-flop synchronizer to prevent metastability
        sync1 <= pbin;
        sync2 <= sync1;

        if (sync2 == stable) begin
            cnt <= 0; // Already stable
        end else begin
            if (cnt == COUNT_MAX-1) begin
                stable <= sync2;
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
        
        pbout <= stable;
    end
endmodule