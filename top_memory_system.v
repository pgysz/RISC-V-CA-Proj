`timescale 1ns / 1ps

module top_memory_system(
    input  wire        clk,
    input  wire        btnC, // Center button for reset
    input  wire [15:0] sw,   // 16 physical switches
    output wire [15:0] led   // 16 physical LEDs
);

    // 1. Debounce the reset button (Reusing Lab 5 component)
    wire rst;
    debouncher u_db(
        .clk(clk),
        .pbin(btnC),
        .pbout(rst)
    );

    // 2. FSM Control Signals
    reg  [31:0] current_address;
    reg         current_re;
    reg         current_we;
    reg  [31:0] current_wdata;
    wire [31:0] read_data_out;

    // 3. Instantiate the Address Decoder System
    addressDecoderTop u_addr_decoder (
        .clk(clk),
        .rst(rst),
        .address(current_address),
        .readEnable(current_re),
        .writeEnable(current_we),
        .writeData(current_wdata),
        .switches(sw),          // Feed physical switches in
        .readData(read_data_out),
        .leds(led)              // Route to physical LEDs
    );

    // 4. FSM States based on Lab 8 Manual Block Diagram
    localparam S_IDLE          = 3'd0;
    localparam S_READ_SWITCHES = 3'd1;
    localparam S_WRITE_DATAMEM = 3'd2;
    localparam S_READ_DATAMEM  = 3'd3;
    localparam S_WRITE_LED     = 3'd4;

    reg [2:0] state, next_state;
    reg [31:0] temp_data; // To hold data between reads and writes

    // State Memory and Data Capture
    always @(posedge clk) begin
        if (rst) begin
            state     <= S_IDLE;
            temp_data <= 32'd0;
        end else begin
            state <= next_state;
            // Capture the data read from switches or memory
            if (state == S_READ_SWITCHES || state == S_READ_DATAMEM) begin
                temp_data <= read_data_out; 
            end
        end
    end

    // Next State and Output Logic
    always @(*) begin
        // Default assignments to prevent latches
        current_address = 32'd0;
        current_re      = 1'b0;
        current_we      = 1'b0;
        current_wdata   = 32'd0;
        next_state      = state;

        case (state)
            S_IDLE: begin
                next_state = S_READ_SWITCHES;
            end
            
            S_READ_SWITCHES: begin
                current_address = 32'd512;   // Decoder routes to Switches (10)
                current_re      = 1'b1;
                next_state      = S_WRITE_DATAMEM;
            end
            
            S_WRITE_DATAMEM: begin
                current_address = 32'd0;     // Decoder routes to Data Mem (00)
                current_we      = 1'b1;
                current_wdata   = temp_data; // Write the data captured from switches
                next_state      = S_READ_DATAMEM;
            end
            
            S_READ_DATAMEM: begin
                current_address = 32'd0;     // Decoder routes to Data Mem (00)
                current_re      = 1'b1;
                next_state      = S_WRITE_LED;
            end
            
            S_WRITE_LED: begin
                current_address = 32'd256;   // Decoder routes to LEDs (01)
                current_we      = 1'b1;
                current_wdata   = temp_data; // Write the data captured from memory
                next_state      = S_READ_SWITCHES; // Loop back to the start!
            end
            
            default: next_state = S_IDLE;
        endcase
    end

endmodule