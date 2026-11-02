module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [DATA_WIDTH-1:0] wdata,
    output wire                  wfull,
    
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire                  rempty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Dual-Port SRAM Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    always @(posedge wclk) begin
        if (winc && !wfull)
            mem[waddr[ADDR_WIDTH-1:0]] <= wdata;
    end
    assign rdata = mem[raddr[ADDR_WIDTH-1:0]];

    // Internal registers and wires
    reg [ADDR_WIDTH:0] wptr_bin, rptr_bin;
    reg [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    reg [ADDR_WIDTH:0] wq2_rptr, wq1_rptr;
    reg [ADDR_WIDTH:0] rq2_wptr, rq1_wptr;

    wire [ADDR_WIDTH:0] wptr_gray_next, rptr_gray_next;
    wire [ADDR_WIDTH:0] waddr, raddr;

    // 2-Flop Synchronizer: Read pointer to Write Clock Domain
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wq1_rptr <= 0;
            wq2_rptr <= 0;
        end else begin
            wq1_rptr <= rptr_gray;
            wq2_rptr <= wq1_rptr;
        end
    end

    // 2-Flop Synchronizer: Write pointer to Read Clock Domain
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rq1_wptr <= 0;
            rq2_wptr <= 0;
        end else begin
            rq1_wptr <= wptr_gray;
            rq2_wptr <= rq1_wptr;
        end
    end

    // Write Pointer Logic
    wire [ADDR_WIDTH:0] wptr_bin_next = wptr_bin + (winc & !wfull);
    assign wptr_gray_next = (wptr_bin_next >> 1) ^ wptr_bin_next;
    assign waddr = wptr_bin;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= 0;
            wptr_gray <= 0;
        end else begin
            wptr_bin  <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
        end
    end

    // Read Pointer Logic
    wire [ADDR_WIDTH:0] rptr_bin_next = rptr_bin + (rinc & !rempty);
    assign rptr_gray_next = (rptr_bin_next >> 1) ^ rptr_bin_next;
    assign raddr = rptr_bin;

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= 0;
            rptr_gray <= 0;
        end else begin
            rptr_bin  <= rptr_bin_next;
            rptr_gray <= rptr_gray_next;
        end
    end

    // Status Flags (Full & Empty)
    assign rempty = (rptr_gray == rq2_wptr);
    assign wfull  = (wptr_gray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

endmodule
