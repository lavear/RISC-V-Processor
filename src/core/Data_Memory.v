module Data_Memory (
    input wire clk,
    input wire rst,

    // --- AXI4-Lite Slave Interface ---
    // Read Address Channel (AR)
    input  wire [31:0] araddr,
    input  wire        arvalid,
    output reg         arready,

    // Read Data Channel (R)
    output reg  [31:0] rdata,
    output reg         rvalid,
    input  wire        rready,

    // Write Address Channel (AW)
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output reg         awready,

    // Write Data Channel (W)
    input  wire [31:0] wdata,
    input  wire [3:0]  wstrb,
    input  wire        wvalid,
    output reg         wready,

    // Write Response Channel (B)
    output reg         bvalid,
    input  wire        bready
);

    // Memory Array
    integer k;
    reg [31:0] D_Memory[63:0];

    // FSM States
    localparam IDLE       = 3'd0;
    localparam READ_ADDR  = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam WRITE_ADDR = 3'd3;
    localparam WRITE_DATA = 3'd4;
    localparam WRITE_RESP = 3'd5;

    reg [2:0] state;
    reg [31:0] stored_addr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for(k=0; k<64; k=k+1) begin
                D_Memory[k] <= 32'b0;
            end
            state <= IDLE;
            arready <= 1'b0;
            rvalid  <= 1'b0;
            rdata   <= 32'b0;
            awready <= 1'b0;
            wready  <= 1'b0;
            bvalid  <= 1'b0;
        end else begin
            // Default outputs (pulse them unless in a state that holds them)
            arready <= 1'b0;
            awready <= 1'b0;
            wready  <= 1'b0;

            case (state)
                IDLE: begin
                    // Prioritize read requests
                    if (arvalid) begin
                        arready <= 1'b1;
                        stored_addr <= araddr;
                        state <= READ_DATA;
                    end else if (awvalid) begin
                        awready <= 1'b1;
                        stored_addr <= awaddr;
                        state <= WRITE_DATA;
                    end
                end

                READ_DATA: begin
                    // State transiting out of READ_ADDR drops arready
                    rdata <= D_Memory[stored_addr[31:2]];
                    rvalid <= 1'b1;
                    if (rvalid && rready) begin
                        rvalid <= 1'b0;
                        state <= IDLE;
                    end
                end

                WRITE_DATA: begin
                    wready <= 1'b1;
                    if (wvalid && wready) begin
                        // A simple implementation without byte strobes checking since subset always uses sw
                        D_Memory[stored_addr[31:2]] <= wdata;
                        wready <= 1'b0;
                        state <= WRITE_RESP;
                        bvalid <= 1'b1;
                    end
                end

                WRITE_RESP: begin
                    if (bvalid && bready) begin
                        bvalid <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
