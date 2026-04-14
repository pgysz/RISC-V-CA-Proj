module DataMemory (
    input  wire        clk,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire [31:0] address,      // FIX: Changed to 32 bits to accept ALUResult
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    // Create the 512x32 memory array
    reg [31:0] memory [0:511];

    // FIX: Only use the lower 9 bits (address[8:0]) to index the array
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[8:0]] <= write_data; 
        end
    end

    always @(*) begin
        if (MemRead) begin
            read_data = memory[address[8:0]];
        end else begin
            read_data = 32'd0;
        end
    end

endmodule