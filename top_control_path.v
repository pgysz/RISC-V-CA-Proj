`timescale 1ns / 1ps

module top_control_path(
    input  wire        clk,
    input  wire        btnC, // Reset
    input  wire [15:0] sw,   // FPGA Switches
    output reg  [15:0] led   // FPGA LEDs
);

    // 1. Debounce the reset button (Reusing Lab 5 component)
    wire rst;
    debouncher u_db(
        .clk(clk),
        .pbin(btnC),
        .pbout(rst)
    );

    // 2. Extract RISC-V fields from the physical switches
    wire [6:0] opcode   = sw[6:0];  // Bottom 7 switches
    wire [2:0] funct3   = sw[9:7];  // Next 3 switches
    wire       funct7_5 = sw[10];   // Switch 10 for bit 5 of funct7

    // 3. Wires to catch the control signals
    wire       Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // 4. Instantiate Main Control
    MainControl u_Main (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    // 5. Instantiate ALU Control
    ALUControl u_ALU (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );

    // 6. Simple FSM to read switches and display to LEDs
    localparam S_READ_SW  = 1'b0;
    localparam S_DISP_LED = 1'b1;
    reg state;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_READ_SW;
            led   <= 16'd0;
        end else begin
            case(state)
                S_READ_SW: begin
                    state <= S_DISP_LED;
                end
                S_DISP_LED: begin
                    // Map output control signals to LEDs
                    led[0]     <= Branch;
                    led[1]     <= MemRead;
                    led[2]     <= MemtoReg;
                    led[3]     <= MemWrite;
                    led[4]     <= ALUSrc;
                    led[5]     <= RegWrite;
                    led[9:6]   <= ALUControl;
                    led[15:10] <= 6'b000000; // Turn off unused LEDs
                    state      <= S_READ_SW;
                end
            endcase
        end
    end
endmodule