`timescale 1ns / 1ps


module fsm_counter_top #(
    parameter integer CLOCK_FREQ = 100_000_000 // 100 MHz for Basys 3
)(
    input  wire        clk,
    input  wire        btnC, // Reset button
    input  wire [15:0] sw,   // FPGA Switches
    output wire [15:0] led,  // FPGA LEDs
    output wire [6:0]  seg,  // 7-Segment Display Segments
    output wire [3:0]  an    // 7-Segment Display Anodes
);


    wire rst;
    debouncher u_db (
        .clk(clk),
        .pbin(btnC),
        .pbout(rst)
    );

    wire [31:0] sw_readData;
    reg  [31:0] led_writeData;
    
    localparam [29:0] SW_ADDR  = 30'h00000001;
    localparam [29:0] LED_ADDR = 30'h00000002;

    switches u_switches (
        .clk(clk),
        .rst(rst),
        .btns(16'd0),
        .writeData(32'd0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(SW_ADDR),
        .switches(sw),
        .readData(sw_readData)
    );

    leds u_leds (
        .clk(clk),
        .rst(rst),
        .writeData(led_writeData),
        .writeEnable(1'b1),
        .readEnable(1'b0),
        .memAddress(LED_ADDR),
        .readData(),
        .leds(led)
    );

    function [15:0] encode;
        input [15:0] s;
        begin
            if (s[15])      encode = 16'd15;
            else if (s[14]) encode = 16'd14;
            else if (s[13]) encode = 16'd13;
            else if (s[12]) encode = 16'd12;
            else if (s[11]) encode = 16'd11;
            else if (s[10]) encode = 16'd10;
            else if (s[9])  encode = 16'd9;
            else if (s[8])  encode = 16'd8;
            else if (s[7])  encode = 16'd7;
            else if (s[6])  encode = 16'd6;
            else if (s[5])  encode = 16'd5;
            else if (s[4])  encode = 16'd4;
            else if (s[3])  encode = 16'd3;
            else if (s[2])  encode = 16'd2;
            else if (s[1])  encode = 16'd1;
            else            encode = 16'd0;
        end
    endfunction


    reg [31:0] timer;
    wire tick_1hz = (timer == (CLOCK_FREQ - 1));

    always @(posedge clk) begin
        if (rst) begin
            timer <= 32'd0;
        end else begin
            if (tick_1hz)
                timer <= 32'd0;
            else
                timer <= timer + 1;
        end
    end

    
    localparam S_WAIT  = 1'b0;
    localparam S_COUNT = 1'b1;

    reg state;
    reg [15:0] counter;
    reg armed; 

    wire [15:0] encoded_sw = encode(sw_readData[15:0]);

    always @(posedge clk) begin
        if (rst) begin
            state         <= S_WAIT;
            counter       <= 16'd0;
            led_writeData <= 32'd0;
            armed         <= 1'b0; // Disarm on reset
        end else begin
            
            if (sw_readData[15:0] == 16'd0) begin
                armed <= 1'b1;
            end

            case (state)
                S_WAIT: begin
                    led_writeData <= 32'd0;
                    
                    if (armed && (encoded_sw != 16'd0)) begin
                        counter <= encoded_sw;
                        state   <= S_COUNT;
                        armed   <= 1'b0; // Immediately disarm so it doesn't loop
                    end
                end

                S_COUNT: begin
                    led_writeData <= {16'd0, counter};
                    
                    if (tick_1hz) begin
                        if (counter > 0) begin
                            counter <= counter - 1;
                        end else begin
                            state <= S_WAIT;
                        end
                    end
                end
            endcase
        end
    end

 
    assign an = 4'b1110; // Enable only the rightmost digit

    function [6:0] hex7seg;
        input [3:0] x;
        begin
            case (x)
                4'h0: hex7seg = 7'b1000000;
                4'h1: hex7seg = 7'b1111001;
                4'h2: hex7seg = 7'b0100100;
                4'h3: hex7seg = 7'b0110000;
                4'h4: hex7seg = 7'b0011001;
                4'h5: hex7seg = 7'b0010010;
                4'h6: hex7seg = 7'b0000010;
                4'h7: hex7seg = 7'b1111000;
                4'h8: hex7seg = 7'b0000000;
                4'h9: hex7seg = 7'b0010000;
                4'hA: hex7seg = 7'b0001000;
                4'hB: hex7seg = 7'b0000011;
                4'hC: hex7seg = 7'b1000110;
                4'hD: hex7seg = 7'b0100001;
                4'hE: hex7seg = 7'b0000110;
                4'hF: hex7seg = 7'b0001110;
                default: hex7seg = 7'b1111111;
            endcase
        end
    endfunction

    assign seg = hex7seg(counter[3:0]); 

endmodule