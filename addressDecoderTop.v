`timescale 1ns / 1ps

module addressDecoderTop(
    input  wire        clk, rst,
    input  wire [31:0] address,
    input  wire        readEnable, writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,
    
    output reg  [31:0] readData,
    output wire [15:0] leds
);

    wire [1:0] device_select = address[9:8];
    
    wire DataMemWrite = (device_select == 2'b00) & writeEnable;
    wire DataMemRead  = (device_select == 2'b00) & readEnable;
    
    // LEDs are selected when address[9:8] == 01
    wire LEDWrite = (device_select == 2'b01) & writeEnable;
    
    // Switches are selected when address[9:8] == 10
    wire SwitchReadEnable = (device_select == 2'b10) & readEnable;

    wire [31:0] mem_read_data;
    wire [31:0] switch_read_data;

    // Data Memory Module (512x32)
    DataMemory u_DataMem (
        .clk(clk),
        .MemWrite(DataMemWrite),
        .MemRead(DataMemRead),
        .address(address[8:0]),    
        .write_data(writeData),
        .read_data(mem_read_data)
    );

    // LED Interface
    leds u_leds (
        .clk(clk),
        .rst(rst),
        .writeData(writeData),      
        .writeEnable(LEDWrite),
        .readEnable(1'b0),          // LEDs are write-only
        .memAddress(30'h00000002),  
        .readData(),                
        .leds(leds)
    );

    // Switch Interface
    switches u_switches (
        .clk(clk),
        .rst(rst),
        .btns(16'd0),                
        .writeData(32'd0),          // Switches are read-only
        .writeEnable(1'b0),
        .readEnable(SwitchReadEnable),
        .memAddress(30'h00000001),
        .switches(switches),
        .readData(switch_read_data)
    );
    
    always @(*) begin
        case (device_select)
            2'b00: readData = mem_read_data;      // Route Data Memory output
            2'b10: readData = switch_read_data;   // Route Switch output
            default: readData = 32'd0;            // Default for LEDs or unused space
        endcase
    end

endmodule