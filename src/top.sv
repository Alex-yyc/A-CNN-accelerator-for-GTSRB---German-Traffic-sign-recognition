`include "../include/define.svh"
`include "../include/AXI_define.svh"
`include "../include/FIFO_define.svh"
`include "../include/CPU_def.svh"
`include "../include/AXI_define.svh"
`include "./Interface/inf_Slave.sv"
`include "./Interface/inf_Master.sv"
`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "AXI/AXI.sv"
`include "ROM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "SCtrl_wrapper.sv"
// `include "WDT_wrapper.sv"
`include "./DMA.sv"
`include "./EPU_wrapper.sv"

module top(
  input  logic           cpu_clk,
  input  logic           axi_clk,
  input  logic           rom_clk,
  input  logic           dram_clk,
  input  logic           sram_clk,
  input  logic           cpu_rst,
  input  logic           axi_rst,
  input  logic           rom_rst,
  input  logic           dram_rst,
  input  logic           sram_rst,
  input  logic           sensor_ready,
  input  logic [   31:0] sensor_out,
  output logic           sensor_en,
  input  logic [   31:0] ROM_out,
  input  logic [   31:0] DRAM_Q,
  output logic           ROM_read,
  output logic           ROM_enable,
  output logic [   11:0] ROM_address,
  output logic           DRAM_CSn,
  output logic [    3:0] DRAM_WEn,
  output logic           DRAM_RASn,
  output logic           DRAM_CASn,
  output logic [   10:0] DRAM_A,
  output logic [   31:0] DRAM_D,
  input  logic           DRAM_valid
);

  //MASTER INTERFACE
  // M0
  // READ
  logic [`AXI_ID_BITS-1:0]   ARID_M0_i;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_i;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_M0_i;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_i;
  logic [1:0]                ARBURST_M0_i;
  logic                      ARVALID_M0_i;
  logic                      ARREADY_M0_o;
  logic [`AXI_ID_BITS-1:0]   RID_M0_o;
  logic [`AXI_DATA_BITS-1:0] RDATA_M0_o;
  logic [1:0]                RRESP_M0_o;
  logic                      RLAST_M0_o;
  logic                      RVALID_M0_o;
  logic                      RREADY_M0_i;
  // M1
  // WRITE
  logic[`AXI_ID_BITS-1:0]    AWID_M1_i;
  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M1_i;
  logic[`AXI_LEN_BITS-1:0]   AWLEN_M1_i;
  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M1_i;
  logic[1:0]                 AWBURST_M1_i;
  logic                      AWVALID_M1_i;
  logic                      AWREADY_M1_o;
  logic [`AXI_DATA_BITS-1:0] WDATA_M1_i;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M1_i;
  logic                      WLAST_M1_i;
  logic                      WVALID_M1_i;
  logic                      WREADY_M1_o;
  logic [`AXI_ID_BITS-1:0]   BID_M1_o;
  logic [1:0]                BRESP_M1_o;
  logic                      BVALID_M1_o;
  logic                      BREADY_M1_i;
  // READ
  logic [`AXI_ID_BITS-1:0]   ARID_M1_i;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_i;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_M1_i;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_i;
  logic [1:0]                ARBURST_M1_i;
  logic                      ARVALID_M1_i;
  logic                      ARREADY_M1_o;
  logic [`AXI_ID_BITS-1:0]   RID_M1_o;
  logic [`AXI_DATA_BITS-1:0] RDATA_M1_o;
  logic [1:0]                RRESP_M1_o;
  logic                      RLAST_M1_o;
  logic                      RVALID_M1_o;
  logic                      RREADY_M1_i;
  // M2
  // WRITE
  logic[`AXI_ID_BITS-1:0]    AWID_M2_i;
  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M2_i;
  logic[`AXI_LEN_BITS-1:0]   AWLEN_M2_i;
  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M2_i;
  logic[1:0]                 AWBURST_M2_i;
  logic                      AWVALID_M2_i;
  logic                      AWREADY_M2_o;
  logic [`AXI_DATA_BITS-1:0] WDATA_M2_i;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M2_i;
  logic                      WLAST_M2_i;
  logic                      WVALID_M2_i;
  logic                      WREADY_M2_o;
  logic [`AXI_ID_BITS-1:0]   BID_M2_o;
  logic [1:0]                BRESP_M2_o;
  logic                      BVALID_M2_o;
  logic                      BREADY_M2_i;
  // READ
  logic [`AXI_ID_BITS-1:0]   ARID_M2_i;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M2_i;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_M2_i;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M2_i;
  logic [1:0]                ARBURST_M2_i;
  logic                      ARVALID_M2_i;
  logic                      ARREADY_M2_o;
  logic [`AXI_ID_BITS-1:0]   RID_M2_o;
  logic [`AXI_DATA_BITS-1:0] RDATA_M2_o;
  logic [1:0]                RRESP_M2_o;
  logic                      RLAST_M2_o;
  logic                      RVALID_M2_o;
  logic                      RREADY_M2_i;
  //SLAVE INTERFACE
  // S0
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S0_o;
  logic[`AXI_ADDR_BITS-1:0]  ARADDR_S0_o;
  logic[`AXI_LEN_BITS-1:0]   ARLEN_S0_o;
  logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S0_o;
  logic[1:0]                 ARBURST_S0_o;
  logic                      ARVALID_S0_o;
  logic                      ARREADY_S0_i;
  logic[`AXI_IDS_BITS-1:0]   RID_S0_i;
  logic[`AXI_DATA_BITS-1:0]  RDATA_S0_i;
  logic[1:0]                 RRESP_S0_i;
  logic                      RLAST_S0_i;
  logic                      RVALID_S0_i;
  logic                      RREADY_S0_o;
  // S1
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S1_o;
  logic[`AXI_ADDR_BITS-1:0]  AWADDR_S1_o;
  logic[`AXI_LEN_BITS-1:0]   AWLEN_S1_o;
  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S1_o;
  logic[1:0]                 AWBURST_S1_o;
  logic                      AWVALID_S1_o;
  logic                      AWREADY_S1_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S1_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S1_o;
  logic                      WLAST_S1_o;
  logic                      WVALID_S1_o;
  logic                      WREADY_S1_i;
  logic[`AXI_IDS_BITS-1:0]   BID_S1_i;
  logic[1:0]                 BRESP_S1_i;
  logic                      BVALID_S1_i;
  logic                      BREADY_S1_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S1_o;
  logic[`AXI_ADDR_BITS-1:0]  ARADDR_S1_o;
  logic[`AXI_LEN_BITS-1:0]   ARLEN_S1_o;
  logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S1_o;
  logic[1:0]                 ARBURST_S1_o;
  logic                      ARVALID_S1_o;
  logic                      ARREADY_S1_i;
  logic[`AXI_IDS_BITS-1:0]   RID_S1_i;
  logic[`AXI_DATA_BITS-1:0]  RDATA_S1_i;
  logic[1:0]                 RRESP_S1_i;
  logic                      RLAST_S1_i;
  logic                      RVALID_S1_i;
  logic                      RREADY_S1_o;
  // S2
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S2_o;
  logic[`AXI_ADDR_BITS-1:0]  AWADDR_S2_o;
  logic[`AXI_LEN_BITS-1:0]   AWLEN_S2_o;
  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S2_o;
  logic[1:0]                 AWBURST_S2_o;
  logic                      AWVALID_S2_o;
  logic                      AWREADY_S2_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S2_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S2_o;
  logic                      WLAST_S2_o;
  logic                      WVALID_S2_o;
  logic                      WREADY_S2_i;
  logic [`AXI_IDS_BITS-1:0]  BID_S2_i;
  logic [1:0]                BRESP_S2_i;
  logic                      BVALID_S2_i;
  logic                      BREADY_S2_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S2_o;
  logic[`AXI_ADDR_BITS-1:0]  ARADDR_S2_o;
  logic[`AXI_LEN_BITS-1:0]   ARLEN_S2_o;
  logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S2_o;
  logic [1:0]                ARBURST_S2_o;
  logic                      ARVALID_S2_o;
  logic                      ARREADY_S2_i;
  logic[`AXI_IDS_BITS-1:0]   RID_S2_i;
  logic[`AXI_DATA_BITS-1:0]  RDATA_S2_i;
  logic[1:0]                 RRESP_S2_i;
  logic                      RLAST_S2_i;
  logic                      RVALID_S2_i;
  logic                      RREADY_S2_o;
  // S3
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S3_o;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S3_o;
  logic [`AXI_LEN_BITS-1:0]  AWLEN_S3_o;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3_o;
  logic [1:0]                AWBURST_S3_o;
  logic                      AWVALID_S3_o;
  logic                      AWREADY_S3_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S3_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S3_o;
  logic                      WLAST_S3_o;
  logic                      WVALID_S3_o;
  logic                      WREADY_S3_i;
  logic [`AXI_IDS_BITS-1:0]  BID_S3_i;
  logic [1:0]                BRESP_S3_i;
  logic                      BVALID_S3_i;
  logic                      BREADY_S3_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S3_o;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S3_o;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_S3_o;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3_o;
  logic [1:0]                ARBURST_S3_o;
  logic                      ARVALID_S3_o;
  logic                      ARREADY_S3_i;
  logic [`AXI_IDS_BITS-1:0]  RID_S3_i;
  logic [`AXI_DATA_BITS-1:0] RDATA_S3_i;
  logic [1:0]                RRESP_S3_i;
  logic                      RLAST_S3_i;
  logic                      RVALID_S3_i;
  logic                      RREADY_S3_o;
  // S4
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S4_o;
  logic[`AXI_ADDR_BITS-1:0]  AWADDR_S4_o;
  logic[`AXI_LEN_BITS-1:0]   AWLEN_S4_o;
  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S4_o;
  logic[1:0]                 AWBURST_S4_o;
  logic                      AWVALID_S4_o;
  logic                      AWREADY_S4_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S4_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S4_o;
  logic                      WLAST_S4_o;
  logic                      WVALID_S4_o;
  logic                      WREADY_S4_i;
  logic[`AXI_IDS_BITS-1:0]   BID_S4_i;
  logic[1:0]                 BRESP_S4_i;
  logic                      BVALID_S4_i;
  logic                      BREADY_S4_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S4_o;
  logic[`AXI_ADDR_BITS-1:0]  ARADDR_S4_o;
  logic[`AXI_LEN_BITS-1:0]   ARLEN_S4_o;
  logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S4_o;
  logic[1:0]                 ARBURST_S4_o;
  logic                      ARVALID_S4_o;
  logic                      ARREADY_S4_i;
  logic[`AXI_IDS_BITS-1:0]   RID_S4_i;
  logic[`AXI_DATA_BITS-1:0]  RDATA_S4_i;
  logic[1:0]                 RRESP_S4_i;
  logic                      RLAST_S4_i;
  logic                      RVALID_S4_i;
  logic                      RREADY_S4_o;
  // S5
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S5_o;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S5_o;
  logic [`AXI_LEN_BITS-1:0]  AWLEN_S5_o;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5_o;
  logic [1:0]                AWBURST_S5_o;
  logic                      AWVALID_S5_o;
  logic                      AWREADY_S5_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S5_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S5_o;
  logic                      WLAST_S5_o;
  logic                      WVALID_S5_o;
  logic                      WREADY_S5_i;
  logic [`AXI_IDS_BITS-1:0]  BID_S5_i;
  logic [1:0]                BRESP_S5_i;
  logic                      BVALID_S5_i;
  logic                      BREADY_S5_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S5_o;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S5_o;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_S5_o;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5_o;
  logic [1:0]                ARBURST_S5_o;
  logic                      ARVALID_S5_o;
  logic                      ARREADY_S5_i;
  logic [`AXI_IDS_BITS-1:0]  RID_S5_i;
  logic [`AXI_DATA_BITS-1:0] RDATA_S5_i;
  logic [1:0]                RRESP_S5_i;
  logic                      RLAST_S5_i;
  logic                      RVALID_S5_i;
  logic                      RREADY_S5_o;
  // S6
  // WRITE
  logic [`AXI_IDS_BITS-1:0]  AWID_S6_o;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S6_o;
  logic [`AXI_LEN_BITS-1:0]  AWLEN_S6_o;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S6_o;
  logic [1:0]                AWBURST_S6_o;
  logic                      AWVALID_S6_o;
  logic                      AWREADY_S6_i;
  logic [`AXI_DATA_BITS-1:0] WDATA_S6_o;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S6_o;
  logic                      WLAST_S6_o;
  logic                      WVALID_S6_o;
  logic                      WREADY_S6_i;
  logic [`AXI_IDS_BITS-1:0]  BID_S6_i;
  logic [1:0]                BRESP_S6_i;
  logic                      BVALID_S6_i;
  logic                      BREADY_S6_o;
  // READ
  logic [`AXI_IDS_BITS-1:0]  ARID_S6_o;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S6_o;
  logic [`AXI_LEN_BITS-1:0]  ARLEN_S6_o;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S6_o;
  logic [1:0]                ARBURST_S6_o;
  logic                      ARVALID_S6_o;
  logic                      ARREADY_S6_i;
  logic [`AXI_IDS_BITS-1:0]  RID_S6_i;
  logic [`AXI_DATA_BITS-1:0] RDATA_S6_i;
  logic [1:0]                RRESP_S6_i;
  logic                      RLAST_S6_i;
  logic                      RVALID_S6_i;
  logic                      RREADY_S6_o;
  // S7
  // WRITE
  // logic [`AXI_IDS_BITS-1:0]  AWID_S7_o;
  // logic [`AXI_ADDR_BITS-1:0] AWADDR_S7_o;
  // logic [`AXI_LEN_BITS-1:0]  AWLEN_S7_o;
  // logic [`AXI_SIZE_BITS-1:0] AWSIZE_S7_o;
  // logic [1:0]                AWBURST_S7_o;
  // logic                      AWVALID_S7_o;
  // logic                      AWREADY_S7_i;
  // logic [`AXI_DATA_BITS-1:0] WDATA_S7_o;
  // logic [`AXI_STRB_BITS-1:0] WSTRB_S7_o;
  // logic                      WLAST_S7_o;
  // logic                      WVALID_S7_o;
  // logic                      WREADY_S7_i;
  // logic [`AXI_IDS_BITS-1:0]  BID_S7_i;
  // logic [1:0]                BRESP_S7_i;
  // logic                      BVALID_S7_i;
  // logic                      BREADY_S7_o;
  // READ
  // logic [`AXI_IDS_BITS-1:0]  ARID_S7_o;
  // logic [`AXI_ADDR_BITS-1:0] ARADDR_S7_o;
  // logic [`AXI_LEN_BITS-1:0]  ARLEN_S7_o;
  // logic [`AXI_SIZE_BITS-1:0] ARSIZE_S7_o;
  // logic [1:0]                ARBURST_S7_o;
  // logic                      ARVALID_S7_o;
  // logic                      ARREADY_S7_i;
  // logic [`AXI_IDS_BITS-1:0]  RID_S7_i;
  // logic [`AXI_DATA_BITS-1:0] RDATA_S7_i;
  // logic [1:0]                RRESP_S7_i;
  // logic                      RLAST_S7_i;
  // logic                      RVALID_S7_i;
  // logic                      RREADY_S7_o;
  
  inf_Master master2 ();
  inf_Slave slave5 ();
  inf_Slave slave6 ();
  
  // assign ARREADY_S4_i = 1'b0;
  // assign RID_S4_i     = 8'd0;
  // assign RDATA_S4_i   = 32'd0;
  // assign RRESP_S4_i   = 2'b00;
  // assign RLAST_S4_i   = 1'b0;
  // assign RVALID_S4_i  = 1'b0;
  
  // interrupt
  logic interrupt;
  logic WDT_interrupt;  
	logic m1_done, m2_start;
  logic int_sctrl;
  logic [1:0] int_dma;
  logic int_epu, interrupt_dma_epu;
	
  assign interrupt = int_sctrl;
  // assign interrupt_dma_epu = int_epu | int_dma[1];
	assign m2_start = int_dma[0];

  always_ff @( posedge cpu_clk or posedge cpu_rst ) begin 
    if(cpu_rst) interrupt_dma_epu <= 1'd0;
    else if( int_epu | int_dma[1]) interrupt_dma_epu <= 1'd1;
    else interrupt_dma_epu <= 1'd0;
  end

  
  CPU_wrapper CPU1(
    .ACLK            (cpu_clk),
	  .ARESETn         (~cpu_rst),
	  .interrupt       (interrupt),
    .interrupt_dma_epu(interrupt_dma_epu),
	  // .WDT_interrupt   (WDT_interrupt),
	  .m2_start        (m2_start),
	  .m_done				 (m1_done),
    //READ ADDRESS0
	  .ARID_M0         (ARID_M0_i),
	  .ARADDR_M0       (ARADDR_M0_i),
	  .ARLEN_M0        (ARLEN_M0_i),
	  .ARSIZE_M0       (ARSIZE_M0_i),
	  .ARBURST_M0      (ARBURST_M0_i),
	  .ARVALID_M0      (ARVALID_M0_i),
	  .ARREADY_M0      (ARREADY_M0_o),
      //READ DATA0
	  .RID_M0          (RID_M0_o),
	  .RDATA_M0        (RDATA_M0_o),
	  .RRESP_M0        (RRESP_M0_o),
	  .RLAST_M0        (RLAST_M0_o),
	  .RVALID_M0       (RVALID_M0_o),
	  .RREADY_M0       (RREADY_M0_i),
      //READ ADDRESS1
	  .ARID_M1         (ARID_M1_i),
	  .ARADDR_M1       (ARADDR_M1_i),
	  .ARLEN_M1        (ARLEN_M1_i),
	  .ARSIZE_M1       (ARSIZE_M1_i),
	  .ARBURST_M1      (ARBURST_M1_i),
	  .ARVALID_M1      (ARVALID_M1_i),
	  .ARREADY_M1      (ARREADY_M1_o),
	  //READ DATA1
	  .RID_M1          (RID_M1_o),
	  .RDATA_M1        (RDATA_M1_o),
	  .RRESP_M1        (RRESP_M1_o),
	  .RLAST_M1        (RLAST_M1_o),
	  .RVALID_M1       (RVALID_M1_o),
	  .RREADY_M1       (RREADY_M1_i),
      //WRITE ADDRESS
	  .AWID_M1         (AWID_M1_i),
	  .AWADDR_M1       (AWADDR_M1_i),
	  .AWLEN_M1        (AWLEN_M1_i),
	  .AWSIZE_M1       (AWSIZE_M1_i),
	  .AWBURST_M1      (AWBURST_M1_i),
	  .AWVALID_M1      (AWVALID_M1_i),
	  .AWREADY_M1      (AWREADY_M1_o),
	  //WRITE DATA
	  .WDATA_M1        (WDATA_M1_i),
	  .WSTRB_M1        (WSTRB_M1_i),
	  .WLAST_M1        (WLAST_M1_i),
	  .WVALID_M1       (WVALID_M1_i),
	  .WREADY_M1       (WREADY_M1_o),
	  //WRITE RESPONSE
	  .BID_M1          (BID_M1_o),
	  .BRESP_M1        (BRESP_M1_o),
	  .BVALID_M1       (BVALID_M1_o),
	  .BREADY_M1       (BREADY_M1_i)
  );
  
  AXI AXI1(
      .AWID_M2_i         (master2.awid),
    .AWADDR_M2_i       (master2.awaddr),
    .AWLEN_M2_i        (master2.awlen),
    .AWSIZE_M2_i       (master2.awsize),
    .AWBURST_M2_i      (master2.awburst),
    .AWVALID_M2_i      (master2.awvalid),
    .AWREADY_M2_o      (master2.awready),
    .WDATA_M2_i        (master2.wdata),
    .WSTRB_M2_i        (master2.wstrb),
    .WLAST_M2_i        (master2.wlast),
    .WVALID_M2_i       (master2.wvalid),
    .WREADY_M2_o       (master2.wready),
    .BID_M2_o          (master2.bid),
    .BRESP_M2_o        (master2.bresp),
    .BVALID_M2_o       (master2.bvalid),
    .BREADY_M2_i       (master2.bready),

    .ARID_M2_i         (master2.arid),
    .ARADDR_M2_i       (master2.araddr),
    .ARLEN_M2_i        (master2.arlen),
    .ARSIZE_M2_i       (master2.arsize),
    .ARBURST_M2_i      (master2.arburst),
    .ARVALID_M2_i      (master2.arvalid),
    .ARREADY_M2_o      (master2.arready),
    .RID_M2_o          (master2.rid),
    .RDATA_M2_o        (master2.rdata),
    .RRESP_M2_o        (master2.rresp),
    .RLAST_M2_o        (master2.rlast),
    .RVALID_M2_o       (master2.rvalid),
    .RREADY_M2_i       (master2.rready),
  
    .AWID_S6_o         (slave6.awid),
    .AWADDR_S6_o       (slave6.awaddr),
    .AWLEN_S6_o        (slave6.awlen),
    .AWSIZE_S6_o       (slave6.awsize),
    .AWBURST_S6_o      (slave6.awburst),
    .AWVALID_S6_o      (slave6.awvalid),
    .AWREADY_S6_i      (slave6.awready),
    .WDATA_S6_o        (slave6.wdata),
    .WSTRB_S6_o        (slave6.wstrb),
    .WLAST_S6_o        (slave6.wlast),
    .WVALID_S6_o       (slave6.wvalid),
    .WREADY_S6_i       (slave6.wready),
    .BID_S6_i          (slave6.bid),
    .BRESP_S6_i        (slave6.bresp),
    .BVALID_S6_i       (slave6.bvalid),
    .BREADY_S6_o       (slave6.bready),

    .ARID_S6_o         (slave6.arid),
    .ARADDR_S6_o       (slave6.araddr),
    .ARLEN_S6_o        (slave6.arlen),
    .ARSIZE_S6_o       (slave6.arsize),
    .ARBURST_S6_o      (slave6.arburst),
    .ARVALID_S6_o      (slave6.arvalid),
    .ARREADY_S6_i      (slave6.arready),
    .RID_S6_i          (slave6.rid),
    .RDATA_S6_i        (slave6.rdata),
    .RRESP_S6_i        (slave6.rresp),
    .RLAST_S6_i        (slave6.rlast),
    .RVALID_S6_i       (slave6.rvalid),
    .RREADY_S6_o       (slave6.rready),
  
    .AWID_S5_o         (slave5.awid),
    .AWADDR_S5_o       (slave5.awaddr),
    .AWLEN_S5_o        (slave5.awlen),
    .AWSIZE_S5_o       (slave5.awsize),
    .AWBURST_S5_o      (slave5.awburst),
    .AWVALID_S5_o      (slave5.awvalid),
    .AWREADY_S5_i      (slave5.awready),
    .WDATA_S5_o        (slave5.wdata),
    .WSTRB_S5_o        (slave5.wstrb),
    .WLAST_S5_o        (slave5.wlast),
    .WVALID_S5_o       (slave5.wvalid),
    .WREADY_S5_i       (slave5.wready),
    .BID_S5_i          (slave5.bid),
    .BRESP_S5_i        (slave5.bresp),
    .BVALID_S5_i       (slave5.bvalid),
    .BREADY_S5_o       (slave5.bready),

    .ARID_S5_o         (slave5.arid),
    .ARADDR_S5_o       (slave5.araddr),
    .ARLEN_S5_o        (slave5.arlen),
    .ARSIZE_S5_o       (slave5.arsize),
    .ARBURST_S5_o      (slave5.arburst),
    .ARVALID_S5_o      (slave5.arvalid),
    .ARREADY_S5_i      (slave5.arready),
    .RID_S5_i          (slave5.rid),
    .RDATA_S5_i        (slave5.rdata),
    .RRESP_S5_i        (slave5.rresp),
    .RLAST_S5_i        (slave5.rlast),
    .RVALID_S5_i       (slave5.rvalid),
    .RREADY_S5_o       (slave5.rready),
      .*
    );
  
  //S0
  ROM_wrapper ROM1(
    .ACLK            (rom_clk),
	.ARESETn         (~rom_rst),
	//AR
	.ARID            (ARID_S0_o),
	.ARADDR          (ARADDR_S0_o),
	.ARLEN           (ARLEN_S0_o),
	.ARSIZE          (ARSIZE_S0_o),
	.ARBURST         (ARBURST_S0_o), 
	.ARVALID         (ARVALID_S0_o),
	.ARREADY         (ARREADY_S0_i),	
	//R
	.RID             (RID_S0_i),
	.RDATA           (RDATA_S0_i),
	.RRESP           (RRESP_S0_i), 
	.RLAST           (RLAST_S0_i),
	.RVALID          (RVALID_S0_i),
	.RREADY          (RREADY_S0_o),
    //ROM
    .DO              (ROM_out),
    .OE              (ROM_read),
    .CS              (ROM_enable),
    .A               (ROM_address)	
  );
  
  //S1
  SRAM_wrapper IM1(
    .ACLK            (sram_clk),
    .ARESETn         (~sram_rst),
    //WRITE ADDRESS
    .AWID            (AWID_S1_o),
    .AWADDR          (AWADDR_S1_o),
    .AWLEN           (AWLEN_S1_o),
    .AWSIZE          (AWSIZE_S1_o),
    .AWBURST         (AWBURST_S1_o),
    .AWVALID         (AWVALID_S1_o),
    .AWREADY         (AWREADY_S1_i),
    //WRITE DATA
    .WDATA           (WDATA_S1_o),
    .WSTRB           (WSTRB_S1_o),
    .WLAST           (WLAST_S1_o),
    .WVALID          (WVALID_S1_o),
    .WREADY          (WREADY_S1_i),
    //WRITE RESPONSE0
    .BID             (BID_S1_i),
    .BRESP           (BRESP_S1_i),
    .BVALID          (BVALID_S1_i),
    .BREADY          (BREADY_S1_o),
    //READ ADDRESS
	.ARID            (ARID_S1_o),
	.ARADDR          (ARADDR_S1_o),
	.ARLEN           (ARLEN_S1_o),
	.ARSIZE          (ARSIZE_S1_o),
	.ARBURST         (ARBURST_S1_o),
	.ARVALID         (ARVALID_S1_o),
	.ARREADY         (ARREADY_S1_i),
    //READ DATA
 	.RID             (RID_S1_i),
	.RDATA           (RDATA_S1_i),
	.RRESP           (RRESP_S1_i),
	.RLAST           (RLAST_S1_i),
	.RVALID          (RVALID_S1_i),
	.RREADY          (RREADY_S1_o)
  );
  
  //S2
  SRAM_wrapper DM1(
    .ACLK            (sram_clk),
    .ARESETn         (~sram_rst),
    //WRITE ADDRESS
    .AWID            (AWID_S2_o),
    .AWADDR          (AWADDR_S2_o),
    .AWLEN           (AWLEN_S2_o),
    .AWSIZE          (AWSIZE_S2_o),
    .AWBURST         (AWBURST_S2_o),
    .AWVALID         (AWVALID_S2_o),
    .AWREADY         (AWREADY_S2_i),
    //WRITE DATA
    .WDATA           (WDATA_S2_o),
    .WSTRB           (WSTRB_S2_o),
    .WLAST           (WLAST_S2_o),
    .WVALID          (WVALID_S2_o),
    .WREADY          (WREADY_S2_i),
    //WRITE RESPONSE0
    .BID             (BID_S2_i),
    .BRESP           (BRESP_S2_i),
    .BVALID          (BVALID_S2_i),
    .BREADY          (BREADY_S2_o),
    //READ ADDRESS
	.ARID            (ARID_S2_o),
	.ARADDR          (ARADDR_S2_o),
	.ARLEN           (ARLEN_S2_o),
	.ARSIZE          (ARSIZE_S2_o),
	.ARBURST         (ARBURST_S2_o),
	.ARVALID         (ARVALID_S2_o),
	.ARREADY         (ARREADY_S2_i),
    //READ DATA
 	.RID             (RID_S2_i),
	.RDATA           (RDATA_S2_i),
	.RRESP           (RRESP_S2_i),
	.RLAST           (RLAST_S2_i),
	.RVALID          (RVALID_S2_i),
	.RREADY          (RREADY_S2_o)
  );
  
  //S3
  SCtrl_wrapper sensor_ctrl1(
    .ACLK            (cpu_clk), 
    .ARESETn         (~cpu_rst),
    //sensor control
    .sensor_ready    (sensor_ready),
    .sensor_out      (sensor_out),
    .sensor_en       (sensor_en),
    .sctrl_interrupt (int_sctrl),
    //WRITE ADDRESS
    .AWID            (AWID_S3_o),
    .AWADDR          (AWADDR_S3_o),
    .AWLEN           (AWLEN_S3_o),
    .AWSIZE          (AWSIZE_S3_o),
    .AWBURST         (AWBURST_S3_o),
    .AWVALID         (AWVALID_S3_o),
    .AWREADY         (AWREADY_S3_i),
    //WRITE DATA
    .WDATA           (WDATA_S3_o),
    .WSTRB           (WSTRB_S3_o),
    .WLAST           (WLAST_S3_o),
    .WVALID          (WVALID_S3_o),
    .WREADY          (WREADY_S3_i),
    //WRITE RESPONSE0
    .BID             (BID_S3_i),
    .BRESP           (BRESP_S3_i),
    .BVALID          (BVALID_S3_i),
    .BREADY          (BREADY_S3_o),
    //READ ADDRESS
	.ARID            (ARID_S3_o),
	.ARADDR          (ARADDR_S3_o),
	.ARLEN           (ARLEN_S3_o),
	.ARSIZE          (ARSIZE_S3_o),
	.ARBURST         (ARBURST_S3_o),
	.ARVALID         (ARVALID_S3_o),
	.ARREADY         (ARREADY_S3_i),
    //READ DATA
 	.RID             (RID_S3_i),
	.RDATA           (RDATA_S3_i),
	.RRESP           (RRESP_S3_i),
	.RLAST           (RLAST_S3_i),
	.RVALID          (RVALID_S3_i),
	.RREADY          (RREADY_S3_o)
  );

  //S4
  // WDT_wrapper WDT1(
    // .ACLK            (cpu_clk),  
    // .ARESETn         (~cpu_rst),
    // .clk2            (cpu_clk),   
    // .rst2            (cpu_rst),
    // .WDT_interrupt   (WDT_interrupt),
    // WRITE ADDRESS
    // .AWID            (AWID_S4_o),
    // .AWADDR          (AWADDR_S4_o),
    // .AWLEN           (AWLEN_S4_o),
    // .AWSIZE          (AWSIZE_S4_o),
    // .AWBURST         (AWBURST_S4_o),
    // .AWVALID         (AWVALID_S4_o),
    // .AWREADY         (AWREADY_S4_i),
    // WRITE DATA
    // .WDATA           (WDATA_S4_o),
    // .WSTRB           (WSTRB_S4_o),
    // .WLAST           (WLAST_S4_o),
    // .WVALID          (WVALID_S4_o),
    // .WREADY          (WREADY_S4_i),
    // WRITE RESPONSE
    // .BID             (BID_S4_i),
    // .BRESP           (BRESP_S4_i),
    // .BVALID          (BVALID_S4_i),
	// .BREADY          (BREADY_S4_o) 
  // );
  
  //S5
  DRAM_wrapper DRAM1(
    .ACLK            (dram_clk),
	.ARESETn         (~dram_rst),
	//WRITE ADDRESS
	.AWID            (AWID_S4_o), 
	.AWADDR          (AWADDR_S4_o),
	.AWLEN           (AWLEN_S4_o),
	.AWSIZE          (AWSIZE_S4_o),
	.AWBURST         (AWBURST_S4_o), 
	.AWVALID         (AWVALID_S4_o),
	.AWREADY         (AWREADY_S4_i),
	//WRITE DATA
	.WDATA           (WDATA_S4_o),
	.WSTRB           (WSTRB_S4_o),
	.WLAST           (WLAST_S4_o),
	.WVALID          (WVALID_S4_o),
	.WREADY          (WREADY_S4_i),
	//WRITE RESPONSE
	.BID             (BID_S4_i),
	.BRESP           (BRESP_S4_i), 
	.BVALID          (BVALID_S4_i),
	.BREADY          (BREADY_S4_o),
	//READ ADDRESS0
	.ARID            (ARID_S4_o),
	.ARADDR          (ARADDR_S4_o),
	.ARLEN           (ARLEN_S4_o),
	.ARSIZE          (ARSIZE_S4_o),
	.ARBURST         (ARBURST_S4_o), 
	.ARVALID         (ARVALID_S4_o),
	.ARREADY         (ARREADY_S4_i),	
	//READ DATA0
	.RID             (RID_S4_i),
	.RDATA           (RDATA_S4_i),
	.RRESP           (RRESP_S4_i), 
	.RLAST           (RLAST_S4_i),
	.RVALID          (RVALID_S4_i),
	.RREADY          (RREADY_S4_o),
    //DRAM
    .Q               (DRAM_Q),
    .CSn             (DRAM_CSn),      
    .WEn             (DRAM_WEn),
    .RASn            (DRAM_RASn),  
    .CASn            (DRAM_CASn),   
    .A               (DRAM_A), 
    .D               (DRAM_D),  
    .VALID           (DRAM_valid)	
  );
  
  //M2 S6
  DMA i_dma (
    .clk             (cpu_clk),
    .rst             (cpu_rst),
		.m1_done				 (m1_done),
    .m2axi_i         (master2.M2AXIin),
    .m2axi_o         (master2.M2AXIout),
    .s2axi_i         (slave5.S2AXIin),
    .s2axi_o         (slave5.S2AXIout),
    .int_o           (int_dma)
  );

  //S7
  EPU_wrapper epu_wrapper (
    .clk             (cpu_clk),
    .rst             (cpu_rst),
    .s2axi_i         (slave6.S2AXIin),
    .s2axi_o         (slave6.S2AXIout),
    .epuint_o        (int_epu)
  );
  
endmodule


