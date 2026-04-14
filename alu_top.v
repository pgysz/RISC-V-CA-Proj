`timescale 1ns / 1ps

// =========================================================================
// TOP MODULE: Dynamic ALU Integration with Basys 3 Peripherals
// =========================================================================
module alu_top (
    input  wire        clk,
    input  wire        btnC, // Reset button
    input  wire [15:0] sw,   // FPGA Switches
    output wire [15:0] led   // FPGA LEDs
);

    // 1. Reuse Lab 5 Debouncer
    wire rst;
    debouncher u_db (
        .clk(clk),
        .pbin(btnC),
        .pbout(rst)
    );

    // 2. Reuse Lab 5 Switch & LED Peripherals
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

    // 3. Instantiate the ALU (Math Engine)
    reg  [3:0]  alu_ctrl;
    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    wire [31:0] alu_result;
    wire        zero_flag;

    ALU u_alu (
        .A(operand_a),
        .B(operand_b),
        .ALUControl(alu_ctrl), 
        .ALUResult(alu_result),
        .Zero(zero_flag)
    );

    // 4. FSM to dynamically read switches and display results
    localparam S_READ = 1'b0;
    localparam S_DISP = 1'b1;
    
    reg state;

    always @(posedge clk) begin
        if (rst) begin
            state         <= S_READ;
            alu_ctrl      <= 4'b0000;
            operand_a     <= 32'd0;
            operand_b     <= 32'd0;
            led_writeData <= 32'd0;
        end else begin
            case (state)
                S_READ: begin
                    // Split the 16 switches exactly how you requested
                    alu_ctrl  <= sw_readData[3:0];             // Bottom 4 switches
                    operand_b <= {26'd0, sw_readData[9:4]};    // Next 6 switches (padded to 32 bits)
                    operand_a <= {26'd0, sw_readData[15:10]};  // Top 6 switches (padded to 32 bits)
                    state     <= S_DISP;
                end
                
                S_DISP: begin
                    // LED 15 gets the Zero flag, the rest get the bottom 15 bits of the result
                    led_writeData <= {16'd0, zero_flag, alu_result[14:0]};
                    state         <= S_READ;
                end
            endcase
        end
    end

endmodule