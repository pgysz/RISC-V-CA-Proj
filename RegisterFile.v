module RegisterFile(
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output [31:0] readData1,
    output [31:0] readData2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [31:0];
    integer i;

    // Synchronous Write and Reset
    always @(posedge clk) begin
        if (rst) begin
            // Clear all registers on reset
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (WriteEnable && rd != 5'd0) begin
            // Write to register only if WriteEnable is high and destination is NOT x0
            registers[rd] <= WriteData;
        end
    end

    // Asynchronous Read (Combinational)
    // Register x0 (address 0) is hardwired to always return 0
    assign readData1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign readData2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule