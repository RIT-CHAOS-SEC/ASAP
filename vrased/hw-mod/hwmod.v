`include "vrased.v"	
`include "vape.v"	

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module hwmod (
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,

    ER_min,
    ER_max,

    OR_min,
    OR_max,

    irq,
    
    puc,
    
    reset,
    
    exec1,
    exec2,
    exec3,
    exec4,
    exec5,
    exec
);
input           clk;
input   [15:0]  pc;
input           data_en;
input           data_wr;
input   [15:0]  data_addr;
input   [15:0]  dma_addr;
input           dma_en;
input   [15:0]  ER_min;
input   [15:0]  ER_max;
input   [15:0]  OR_min;
input   [15:0]  OR_max;
input           irq;
input           puc;
output          reset;
output          exec;
output          exec1;
output          exec2;
output          exec3;
output          exec4;
output          exec5;

// MACROS ///////////////////////////////////////////
//
parameter SMEM_BASE = 16'hA000;
parameter SMEM_SIZE = 16'h4000;
//

wire vrased_reset;
vrased #(
) vrased_0 (
    .clk        (clk),
    .pc         (pc),
    .data_en    (data_en),
    .data_wr    (data_wr),
    .data_addr  (data_addr),
    
    .dma_addr   (dma_addr),
    .dma_en     (dma_en),

    .irq        (irq),
    
    .reset      (vrased_reset)
);

wire vape_exec;

wire vape_exec1;
wire vape_exec2;
wire vape_exec3;
wire vape_exec4;
wire vape_exec5;

vape #( .SMEM_BASE (SMEM_BASE),
        .SMEM_SIZE (SMEM_SIZE)
         ) vape_0 (
    .clk        (clk),
    .pc         (pc),
    .data_en    (data_en),
    .data_wr    (data_wr),
    .data_addr  (data_addr),
    
    .dma_addr   (dma_addr),
    .dma_en     (dma_en),

    .ER_min     (ER_min),
    .ER_max     (ER_max),

    .OR_min     (OR_min),
    .OR_max     (OR_max),

    .puc        (puc),
    
    .exec1 (vape_exec1),
    .exec2 (vape_exec2),
    .exec3 (vape_exec3),
    .exec4 (vape_exec4),
    .exec5 (vape_exec5),
    .exec       (vape_exec)
);


assign reset = vrased_reset;

assign exec = vape_exec;

assign exec1 = vape_exec1;
assign exec2 = vape_exec2;
assign exec3 = vape_exec3;
assign exec4 = vape_exec4;
assign exec5 = vape_exec5;



endmodule
