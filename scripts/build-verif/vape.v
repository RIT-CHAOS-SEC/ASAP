`include "ASAP_immutability.v"
`include "VAPE_atomicity.v"
`include "VAPE_output_protection.v"
`include "VAPE_EXEC_flag.v"
`include "VAPE_boundary.v"
`include "VAPE_reset.v"
`include "VAPE_irq_dma.v"
`include "VAPE_ivt_protect.v"

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module vape (
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

    puc,
    
    exec1,
    exec2,
    exec3,
    exec4,
    exec5,
    exec6,
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
input           puc;
//
output          exec;
output          exec1;
output          exec2;
output          exec3;
output          exec4;
output          exec5;
output          exec6;

// MACROS ///////////////////////////////////////////
parameter RESET_HANDLER = 16'h0000;
//
parameter SMEM_BASE = 16'hA000;
parameter SMEM_SIZE = 16'h4000;
//

wire   asap_immutability;
ASAP_immutability #() 
ASAP_immutability_0 (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .data_en    (data_wr),
    .dma_addr   (dma_addr),
    .dma_en     (dma_en),
    .ER_min     (ER_min),
    .ER_max     (ER_max),
    .exec      (asap_immutability)
);

wire    vape_atomicity;
VAPE_atomicity #(   
        .SMEM_BASE (SMEM_BASE),
        .SMEM_SIZE (SMEM_SIZE)
) 
VAPE_atomicity_0 (
    .clk        (clk),
    .pc         (pc),
    .ER_min	(ER_min),
    .ER_max	(ER_max),
    .exec      (vape_atomicity)
);

wire   vape_output_protection;
VAPE_output_protection #(RESET_HANDLER) 
VAPE_output_protection_0 (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .data_en    (data_wr),
    .dma_addr   (dma_addr),
    .dma_en     (dma_en),
    .ER_min     (ER_min),
    .ER_max     (ER_max),
    .OR_min     (OR_min),
    .OR_max     (OR_max),
    .exec      (vape_output_protection) 
);

//wire   vape_boundary_protection;
//VAPE_boundary #() 
//VAPE_boundary_0 (
//    .clk        (clk),
//    .pc         (pc),
//    .data_addr  (data_addr),
//    .data_en    (data_wr),
//    .dma_addr   (dma_addr),
//    .dma_en     (dma_en),
//    .ER_min     (ER_min),
//    .ER_max     (ER_max),
//    .exec      (vape_boundary_protection) 
//);

wire   vape_irq;
irq_dma #(
) 
irq_dma_0 (
    .clk        (clk),
    .pc         (pc),
    .dma_en     (dma_en),
    .ER_min     (ER_min),
    .ER_max     (ER_max),
    .exec      (vape_irq) 
);

wire vape_flip_or_reset_check;
VAPE_reset #(
) 
VAPE_reset_0 (
    .clk        (clk),
    .pc         (pc),

    .ER_min     (ER_min),
    .ER_max     (ER_max),

    .OR_min     (OR_min),
    .OR_max     (OR_max),

    .reset      (puc),

    .exec      (vape_flip_or_reset_check)
);

assign exec = vape_atomicity & asap_immutability & vape_output_protection & asap_immutability & vape_irq & vape_flip_or_reset_check;

assign exec1 = asap_immutability & 1'b1;
assign exec2 = vape_atomicity & vape_irq;
assign exec3 = vape_flip_or_reset_check & 1'b1;
assign exec4 = vape_output_protection & 1'b1;
assign exec5 = asap_immutability & 1'b1;

endmodule
