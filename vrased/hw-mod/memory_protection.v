
module  memory_protection (
    clk,
    pc,
    data_addr,
    data_en,
	dma_addr,
    dma_en,
    ER_min,
    ER_max,
    IVT_min,
    IVT_max,
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
input   [15:0]  IVT_min;
input   [15:0]  IVT_max;
output          exec;

// State codes
parameter EXEC  = 1'b0, ABORT = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             exec_res;
//

initial
    begin
        state = ABORT;
        exec_res = 1'b0;
    end

wire is_write = data_en && (data_addr >= IVT_min && data_addr <= IVT_max);
wire is_write_DMA = dma_en && (dma_addr >= IVT_min && dma_addr <= IVT_max);
wire is_fst_ER = (pc == ER_min);


wire change = is_write || is_write_DMA; // || prev_ER_min != ER_min || prev_ER_max != ER_max;

always @(posedge clk)
if( state == EXEC && change) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER && !change)
    state <= EXEC;
else state <= state;

always @(posedge clk)
if (state == EXEC && change)
    exec_res <= 1'b0;
else if (state == ABORT && is_fst_ER && !change)
    exec_res <= 1'b1;
else if (state == ABORT)
    exec_res <= 1'b0;
else if (state == EXEC)
    exec_res <= 1'b1;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule

