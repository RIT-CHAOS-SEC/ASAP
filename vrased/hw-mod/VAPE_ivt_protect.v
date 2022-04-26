
module  VAPE_ivt_protect (
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

/////////////////////////////////////////////////////

parameter RESET_HANDLER = 16'h0000;
parameter RUN  = 1'b0, KILL = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             exec_ivt_protect;
//

initial
    begin
        state = KILL;
        exec_ivt_protect = 1'b1;
    end

wire cpu_protected_access = (data_addr >= IVT_min) && (data_addr < (IVT_max)) && data_en;
wire dma_protected_access = (dma_addr >= IVT_min) && (dma_addr < (IVT_max)) && dma_en;

wire violation1 = cpu_protected_access;
wire violation2 = dma_protected_access;

always @(posedge clk)
if( state == RUN && (violation1 || violation2))
    state <= KILL;
else if (state == KILL && pc == RESET_HANDLER && !violation1 && !violation2)
    state <= RUN;
else state <= state;

always @(posedge clk)
if (state == RUN && (violation1 || violation2))
    exec_ivt_protect <= 1'b0;
else if (state == KILL && pc == RESET_HANDLER && !violation1 && !violation2)
    exec_ivt_protect <= 1'b1;
else if (state == KILL)
    exec_ivt_protect <= 1'b0;
else if (state == RUN)
    exec_ivt_protect <= 1'b1;
else exec_ivt_protect <= 1'b1;

assign exec = exec_ivt_protect;

endmodule
