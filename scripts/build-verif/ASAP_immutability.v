
module  ASAP_immutability (
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

// IVT region
parameter IVT_min = 16'hFFE0;
parameter IVT_max = 16'hFFFF;

initial
    begin
        state = ABORT;
        exec_res = 1'b0;
    end

wire is_write_CPU = data_en &&  ((data_addr >= ER_min && data_addr <= ER_max) 
                            || (data_addr >= IVT_min && data_addr <= IVT_max)
                            || (data_addr >= META_min && data_addr <= META_max));
                            
wire is_write_DMA = dma_en && ((dma_addr >= ER_min && dma_addr <= ER_max) 
                           || (dma_addr >= IVT_min && dma_addr <= IVT_max)
                           || (dma_addr >= META_min && dma_addr <= META_max));

wire is_fst_ER = (pc == ER_min);

wire mem_change = is_write_CPU || is_write_DMA;

always @(*)
if( state == EXEC && mem_change) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER && !mem_change)
    state <= EXEC;
else state <= state;

always @(*)
if (state == EXEC)
    exec_res <= !mem_change;
else if (state == ABORT)
    exec_res <= is_fst_ER && !mem_change;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule
