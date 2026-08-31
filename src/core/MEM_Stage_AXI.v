module MEM_Stage_AXI (
    input wire clk,
    input wire reset,

    // --- CPU Pipeline Interface ---
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] ALU_Result, // Acts as the memory address
    input  wire [31:0] Rs2_Data,   // Data to write (for sw)
    output reg  [31:0] Read_Data,  // Data fetched (for lw)
    output reg         AXI_STALL,  // Freezes the pipeline

    // --- AXI4-Lite Interface ---
    // Read Address Channel (AR)
    output reg  [31:0] araddr,
    output reg         arvalid,
    input  wire        arready,

    // Read Data Channel (R)
    input  wire [31:0] rdata,
    input  wire        rvalid,
    output reg         rready,

    // Write Address Channel (AW)
    output reg  [31:0] awaddr,
    output reg         awvalid,
    input  wire        awready,

    // Write Data Channel (W)
    output reg  [31:0] wdata,
    output wire [3:0]  wstrb,      // Hardcoded to 1111
    output reg         wvalid,
    input  wire        wready,

    // Write Response Channel (B)
    input  wire        bvalid,
    output reg         bready
);

    // Hardcode the write strobe since we only do 32-bit word stores (sw)
    assign wstrb = 4'b1111;

    // FSM State Encodings
    localparam IDLE       = 3'd0;
    localparam READ_ADDR  = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam WRITE_ADDR = 3'd3;
    localparam WRITE_DATA = 3'd4;
    localparam WRITE_RESP = 3'd5;

    reg [2:0] state, next_state;

    // 1. State Register (Sequential)
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 2. Next State Logic (Combinational)
    always @(*) begin
        next_state = state; // Default: stay in current state

        case (state)
            IDLE: begin
                if (MemRead)       next_state = READ_ADDR;
                else if (MemWrite) next_state = WRITE_ADDR;
            end

            // --- LOAD TRANSACTIONS ---
            READ_ADDR: begin
                if (arready) next_state = READ_DATA;
            end
            READ_DATA: begin
                if (rvalid)  next_state = IDLE;
            end

            // --- STORE TRANSACTIONS ---
            WRITE_ADDR: begin
                if (awready) next_state = WRITE_DATA;
            end
            WRITE_DATA: begin
                if (wready)  next_state = WRITE_RESP;
            end
            WRITE_RESP: begin
                if (bvalid)  next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // 3. Output Logic (Combinational)
    always @(*) begin
        // Default everything to 0 to prevent latches and bus collisions
        AXI_STALL = 1'b0;
        arvalid   = 1'b0; araddr = 32'd0;
        rready    = 1'b0;
        awvalid   = 1'b0; awaddr = 32'd0;
        wvalid    = 1'b0; wdata  = 32'd0;
        bready    = 1'b0;

        // Default Read_Data to 0 to prevent a combinational latch.
        // It will only take the value of rdata when rvalid is high,
        // ensuring the pipeline correctly captures it.
        Read_Data = 32'd0;

        case (state)
            IDLE: begin
                // If a memory instruction is detected, stall immediately
                if (MemRead || MemWrite) AXI_STALL = 1'b1;
            end

            READ_ADDR: begin
                AXI_STALL = 1'b1;
                arvalid   = 1'b1;
                araddr    = ALU_Result;
            end

            READ_DATA: begin
                // Drop stall ONLY when data is valid so the pipeline unfreezes
                AXI_STALL = ~rvalid;
                rready    = 1'b1;
                if (rvalid) Read_Data = rdata; // Capture the data directly for WB register
            end

            WRITE_ADDR: begin
                AXI_STALL = 1'b1;
                awvalid   = 1'b1;
                awaddr    = ALU_Result;
            end

            WRITE_DATA: begin
                AXI_STALL = 1'b1;
                wvalid    = 1'b1;
                wdata     = Rs2_Data;
            end

            WRITE_RESP: begin
                // Drop stall ONLY when write is successful
                AXI_STALL = ~bvalid;
                bready    = 1'b1;
            end
        endcase
    end
endmodule
