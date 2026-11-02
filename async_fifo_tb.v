`timescale 1ns/1ps

module async_fifo_tb;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg wclk, wrst_n, winc;
    reg [DATA_WIDTH-1:0] wdata;
    wire wfull;

    reg rclk, rrst_n, rinc;
    wire [DATA_WIDTH-1:0] rdata;
    wire rempty;

    async_fifo #(DATA_WIDTH, ADDR_WIDTH) uut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty)
    );

    // Clocks generation
    always #5   wclk = ~wclk;   // 100MHz
    always #12.5 rclk = ~rclk;  // 40MHz

    // Safety timeout to prevent infinite loops / hang
    initial begin
        #2000;
        $display("Simulation Timed Out Safety Limit Reached.");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, async_fifo_tb);

        // Initialize signals
        wclk = 0; wrst_n = 0; winc = 0; wdata = 0;
        rclk = 0; rrst_n = 0; rinc = 0;

        // Apply Reset
        #30;
        wrst_n = 1;
        rrst_n = 1;
        #20;

        // Write Operations (10 values)
        repeat(10) begin
            @(posedge wclk);
            if (!wfull) begin
                winc  <= 1;
                wdata <= $random;
            end
        end
        @(posedge wclk);
        winc <= 0;

        // Read Operations (10 values)
        repeat(10) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc <= 1;
            end
        end
        @(posedge rclk);
        rinc <= 0;

        #100;
        $display("----------------------------------------");
        $display("Simulation Completed Successfully!");
        $display("----------------------------------------");
        $finish;
    end
endmodule
