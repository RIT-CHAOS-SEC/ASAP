
module  irq_detect (
    clk,
    pc,
    dma_addr,
    dma_en,
	irq,

    reset,
);
input           clk;
input   [15:0]  pc;
input   [15:0]  dma_addr;
input           dma_en;
input			irq;
output          reset;

// MACROS ///////////////////////////////////////////
parameter SMEM_BASE = 16'hE000;
parameter SMEM_SIZE = 16'h1000;
/////////////////////////////////////////////////////



parameter LAST_SMEM_ADDR = SMEM_BASE + SMEM_SIZE - 2;

parameter RESET_HANDLER = 16'h0000;
parameter RUN  = 1'b0, KILL = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             key_res;
//

initial
    begin
        state = KILL;
        key_res = 1'b1;
    end

wire is_in_mem = pc < SMEM_BASE && pc > LAST_SMEM_ADDR;

wire invalid_irq = irq && is_in_mem;

always @(*)
if( state == RUN && invalid_irq) 
    state <= KILL;
else if (state == KILL && pc == RESET_HANDLER && !invalid_irq)
    state <= RUN;
else state <= state;

always @(*)
if (state == RUN && invalid_irq)
    key_res <= 1'b1;
else if (state == KILL && pc == RESET_HANDLER && !invalid_irq)
    key_res <= 1'b0;
else if (state == KILL)
    key_res <= 1'b1;
else if (state == RUN)
    key_res <= 1'b0;
else key_res <= 1'b0;

assign reset = key_res;

endmodule
