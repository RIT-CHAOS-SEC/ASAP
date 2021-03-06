
module  VAPE_boundary (
    clk,
    //
    pc,
    //
    data_addr,
    data_en,
    //
    dma_addr,
    dma_en,
    //
    ER_min,
    ER_max,
    //
    exec
);

input		clk;
input   [15:0]  pc;
input   [15:0]  data_addr;
input           data_en;
input   [15:0]  dma_addr;
input           dma_en;
input   [15:0]  ER_min;
input   [15:0]  ER_max;
output          exec;

// State codes
parameter EXEC  = 1'b0, ABORT = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             exec_res;
//

// METADATA Region
parameter META_min = 16'h0140;
parameter META_max = 16'h0140 + 16'h002A;

initial
    begin
        state = ABORT;
        exec_res = 1'b0;
    end

wire is_write_META = data_en && (data_addr >= META_min && data_addr <= META_max);
wire is_write_DMA_META = dma_en && (dma_addr >= META_min && dma_addr <= META_max);
wire is_fst_ER = (pc == ER_min);


wire META_change = is_write_META || is_write_DMA_META;

always @(*)
if( state == EXEC && META_change) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER && !META_change)
    state <= EXEC;
else state <= state;

always @(*)
if (state == EXEC && META_change)
    exec_res <= 1'b0;
else if (state == ABORT && is_fst_ER && !META_change)
    exec_res <= 1'b1;
else if (state == ABORT)
    exec_res <= 1'b0;
else if (state == EXEC)
    exec_res <= 1'b1;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule
