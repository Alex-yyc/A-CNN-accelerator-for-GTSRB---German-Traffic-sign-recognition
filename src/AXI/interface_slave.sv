//*********************************************************
// Auther:      N26111512
// Filename:    interface_slave.sv [FINAL]
// Description: connect slaves and AXI (1slave 1fifo)
// Version:     5.0  (s0~s6)
// Date:        1/2/2024
//*********************************************************

module interface_slave (
  input  logic                      cpu_clk,
  input  logic                      axi_clk,
  input  logic                      rom_clk,
  input  logic                      dram_clk,
  input  logic                      sram_clk,
  input  logic                      cpu_rst,
  input  logic                      axi_rst,
  input  logic                      rom_rst,
  input  logic                      dram_rst,
  input  logic                      sram_rst, 

  //----- from/to slaves -----
  // S0
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S0_o,
  output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S0_o,
  output logic[`AXI_LEN_BITS-1:0]   ARLEN_S0_o,
  output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S0_o,
  output logic[1:0]                 ARBURST_S0_o,
  output logic                      ARVALID_S0_o,
  input  logic                      ARREADY_S0_i,
  input  logic[`AXI_IDS_BITS-1:0]   RID_S0_i,
  input  logic[`AXI_DATA_BITS-1:0]  RDATA_S0_i,
  input  logic[1:0]                 RRESP_S0_i,
  input  logic                      RLAST_S0_i,
  input  logic                      RVALID_S0_i,
  output logic                      RREADY_S0_o,
  // S1
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S1_o,
  output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S1_o,
  output logic[`AXI_LEN_BITS-1:0]   AWLEN_S1_o,
  output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S1_o,
  output logic[1:0]                 AWBURST_S1_o,
  output logic                      AWVALID_S1_o,
  input  logic                      AWREADY_S1_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S1_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S1_o,
  output logic                      WLAST_S1_o,
  output logic                      WVALID_S1_o,
  input  logic                      WREADY_S1_i,
  input  logic[`AXI_IDS_BITS-1:0]   BID_S1_i,
  input  logic[1:0]                 BRESP_S1_i,
  input  logic                      BVALID_S1_i,
  output logic                      BREADY_S1_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S1_o,
  output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S1_o,
  output logic[`AXI_LEN_BITS-1:0]   ARLEN_S1_o,
  output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S1_o,
  output logic[1:0]                 ARBURST_S1_o,
  output logic                      ARVALID_S1_o,
  input  logic                      ARREADY_S1_i,
  input  logic[`AXI_IDS_BITS-1:0]   RID_S1_i,
  input  logic[`AXI_DATA_BITS-1:0]  RDATA_S1_i,
  input  logic[1:0]                 RRESP_S1_i,
  input  logic                      RLAST_S1_i,
  input  logic                      RVALID_S1_i,
  output logic                      RREADY_S1_o,
  // S2
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S2_o,
  output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S2_o,
  output logic[`AXI_LEN_BITS-1:0]   AWLEN_S2_o,
  output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S2_o,
  output logic[1:0]                 AWBURST_S2_o,
  output logic                      AWVALID_S2_o,
  input  logic                      AWREADY_S2_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S2_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S2_o,
  output logic                      WLAST_S2_o,
  output logic                      WVALID_S2_o,
  input  logic                      WREADY_S2_i,
  input  logic [`AXI_IDS_BITS-1:0]  BID_S2_i,
  input  logic [1:0]                BRESP_S2_i,
  input  logic                      BVALID_S2_i,
  output logic                      BREADY_S2_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S2_o,
  output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S2_o,
  output logic[`AXI_LEN_BITS-1:0]   ARLEN_S2_o,
  output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S2_o,
  output logic [1:0]                ARBURST_S2_o,
  output logic                      ARVALID_S2_o,
  input  logic                      ARREADY_S2_i,
  input  logic[`AXI_IDS_BITS-1:0]   RID_S2_i,
  input  logic[`AXI_DATA_BITS-1:0]  RDATA_S2_i,
  input  logic[1:0]                 RRESP_S2_i,
  input  logic                      RLAST_S2_i,
  input  logic                      RVALID_S2_i,
  output logic                      RREADY_S2_o,
  // S3
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S3_o,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3_o,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S3_o,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3_o,
  output logic [1:0]                AWBURST_S3_o,
  output logic                      AWVALID_S3_o,
  input  logic                      AWREADY_S3_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S3_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S3_o,
  output logic                      WLAST_S3_o,
  output logic                      WVALID_S3_o,
  input  logic                      WREADY_S3_i,
  input  logic [`AXI_IDS_BITS-1:0]  BID_S3_i,
  input  logic [1:0]                BRESP_S3_i,
  input  logic                      BVALID_S3_i,
  output logic                      BREADY_S3_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S3_o,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3_o,
  output logic [`AXI_LEN_BITS-1:0]  ARLEN_S3_o,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3_o,
  output logic [1:0]                ARBURST_S3_o,
  output logic                      ARVALID_S3_o,
  input  logic                      ARREADY_S3_i,
  input  logic [`AXI_IDS_BITS-1:0]  RID_S3_i,
  input  logic [`AXI_DATA_BITS-1:0] RDATA_S3_i,
  input  logic [1:0]                RRESP_S3_i,
  input  logic                      RLAST_S3_i,
  input  logic                      RVALID_S3_i,
  output logic                      RREADY_S3_o,
  // S4
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S4_o,
  output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S4_o,
  output logic[`AXI_LEN_BITS-1:0]   AWLEN_S4_o,
  output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S4_o,
  output logic[1:0]                 AWBURST_S4_o,
  output logic                      AWVALID_S4_o,
  input  logic                      AWREADY_S4_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S4_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S4_o,
  output logic                      WLAST_S4_o,
  output logic                      WVALID_S4_o,
  input  logic                      WREADY_S4_i,
  input  logic[`AXI_IDS_BITS-1:0]   BID_S4_i,
  input  logic[1:0]                 BRESP_S4_i,
  input  logic                      BVALID_S4_i,
  output logic                      BREADY_S4_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S4_o,
  output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S4_o,
  output logic[`AXI_LEN_BITS-1:0]   ARLEN_S4_o,
  output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S4_o,
  output logic[1:0]                 ARBURST_S4_o,
  output logic                      ARVALID_S4_o,
  input  logic                      ARREADY_S4_i,
  input  logic[`AXI_IDS_BITS-1:0]   RID_S4_i,
  input  logic[`AXI_DATA_BITS-1:0]  RDATA_S4_i,
  input  logic[1:0]                 RRESP_S4_i,
  input  logic                      RLAST_S4_i,
  input  logic                      RVALID_S4_i,
  output logic                      RREADY_S4_o,
  // S5
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S5_o,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5_o,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S5_o,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5_o,
  output logic [1:0]                AWBURST_S5_o,
  output logic                      AWVALID_S5_o,
  input  logic                      AWREADY_S5_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S5_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S5_o,
  output logic                      WLAST_S5_o,
  output logic                      WVALID_S5_o,
  input  logic                      WREADY_S5_i,
  input  logic [`AXI_IDS_BITS-1:0]  BID_S5_i,
  input logic [1:0]                 BRESP_S5_i,
  input logic                       BVALID_S5_i,
  output logic                      BREADY_S5_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S5_o,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5_o,
  output logic [`AXI_LEN_BITS-1:0]  ARLEN_S5_o,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5_o,
  output logic [1:0]                ARBURST_S5_o,
  output logic                      ARVALID_S5_o,
  input  logic                      ARREADY_S5_i,
  input  logic [`AXI_IDS_BITS-1:0]  RID_S5_i,
  input  logic [`AXI_DATA_BITS-1:0] RDATA_S5_i,
  input  logic [1:0]                RRESP_S5_i,
  input  logic                      RLAST_S5_i,
  input  logic                      RVALID_S5_i,
  output logic                      RREADY_S5_o,
  // S6
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S6_o,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S6_o,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S6_o,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S6_o,
  output logic [1:0]                AWBURST_S6_o,
  output logic                      AWVALID_S6_o,
  input  logic                      AWREADY_S6_i,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S6_o,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S6_o,
  output logic                      WLAST_S6_o,
  output logic                      WVALID_S6_o,
  input  logic                      WREADY_S6_i,
  input  logic [`AXI_IDS_BITS-1:0]  BID_S6_i,
  input logic [1:0]                 BRESP_S6_i,
  input logic                       BVALID_S6_i,
  output logic                      BREADY_S6_o,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S6_o,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_S6_o,
  output logic [`AXI_LEN_BITS-1:0]  ARLEN_S6_o,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S6_o,
  output logic [1:0]                ARBURST_S6_o,
  output logic                      ARVALID_S6_o,
  input  logic                      ARREADY_S6_i,
  input  logic [`AXI_IDS_BITS-1:0]  RID_S6_i,
  input  logic [`AXI_DATA_BITS-1:0] RDATA_S6_i,
  input  logic [1:0]                RRESP_S6_i,
  input  logic                      RLAST_S6_i,
  input  logic                      RVALID_S6_i,
  output logic                      RREADY_S6_o,

  //----- from/to AXI -----
  input [2:0] read_sel,
  input [2:0] write_sel,

	//READ ADDRESS
	input [`AXI_ID_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	//READ DATA
	output logic [`AXI_ID_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S,
  //WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S,
	input AWVALID_S,
	output logic AWREADY_S,
  //WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input WLAST_S,
	input WVALID_S,
	output logic WREADY_S,
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input BREADY_S
 
);

  logic AR_wpush_s0,  AR_wpush_s1,  AR_wpush_s2,  AR_wpush_s3,  AR_wpush_s4,  AR_wpush_s5, AR_wpush_s6,
        AR_wfull_s0,  AR_wfull_s1,  AR_wfull_s2,  AR_wfull_s3,  AR_wfull_s4,  AR_wfull_s5, AR_wfull_s6,
        AR_rempty_s0, AR_rempty_s1, AR_rempty_s2, AR_rempty_s3, AR_rempty_s4, AR_rempty_s5, AR_rempty_s6;
  logic [`ARFIFO_DATASIZE-1:0] AR_wdata, AR_rdata_s0, AR_rdata_s1, AR_rdata_s2, AR_rdata_s3, AR_rdata_s4, AR_rdata_s5, AR_rdata_s6;

  logic R_rpop_s0,   R_rpop_s1,   R_rpop_s2,   R_rpop_s3,   R_rpop_s4,   R_rpop_s5, R_rpop_s6,
        R_rempty_s0, R_rempty_s1, R_rempty_s2, R_rempty_s3, R_rempty_s4, R_rempty_s5, R_rempty_s6;
  logic [`RFIFO_DATASIZE-1 :0]  R_rdata_s0, R_rdata_s1, R_rdata_s2, R_rdata_s3, R_rdata_s4, R_rdata_s5, R_rdata_s6;

  logic AW_wpush_s1,  AW_wpush_s2,  AW_wpush_s3,  AW_wpush_s4,  AW_wpush_s5, AW_wpush_s6,
        AW_wfull_s1,  AW_wfull_s2,  AW_wfull_s3,  AW_wfull_s4,  AW_wfull_s5, AW_wfull_s6,
        AW_rempty_s1, AW_rempty_s2, AW_rempty_s3, AW_rempty_s4, AW_rempty_s5, AW_rempty_s6;
  logic [`AWFIFO_DATASIZE-1:0] AW_wdata, AW_rdata_s1, AW_rdata_s2, AW_rdata_s3, AW_rdata_s4, AW_rdata_s5, AW_rdata_s6;

  logic W_wpush_s1,  W_wpush_s2,  W_wpush_s3,  W_wpush_s4,  W_wpush_s5, W_wpush_s6,
        W_wfull_s1,  W_wfull_s2,  W_wfull_s3,  W_wfull_s4,  W_wfull_s5, W_wfull_s6,
        W_rempty_s1, W_rempty_s2, W_rempty_s3, W_rempty_s4, W_rempty_s5, W_rempty_s6;
  logic [`WFIFO_DATASIZE-1 :0]  W_wdata, W_rdata_s1,  W_rdata_s2,  W_rdata_s3,  W_rdata_s4,  W_rdata_s5, W_rdata_s6;

  logic B_rpop_s1,   B_rpop_s2,   B_rpop_s3,   B_rpop_s4,   B_rpop_s5, B_rpop_s6,  
        B_rempty_s1, B_rempty_s2, B_rempty_s3, B_rempty_s4, B_rempty_s5, B_rempty_s6;
  logic [`BFIFO_DATASIZE-1 :0] B_rdata_s1, B_rdata_s2, B_rdata_s3, B_rdata_s4, B_rdata_s5, B_rdata_s6;


//----------------------- AR FIFO -------------------------
  // in
  assign AR_wpush_s0 = (read_sel == 3'd0) ? ARVALID_S : 1'b0;
  assign AR_wpush_s1 = (read_sel == 3'd1) ? ARVALID_S : 1'b0;
  assign AR_wpush_s2 = (read_sel == 3'd2) ? ARVALID_S : 1'b0;
  assign AR_wpush_s3 = (read_sel == 3'd3) ? ARVALID_S : 1'b0;
  assign AR_wpush_s4 = (read_sel == 3'd4) ? ARVALID_S : 1'b0;
  assign AR_wpush_s5 = (read_sel == 3'd5) ? ARVALID_S : 1'b0;
  assign AR_wpush_s6 = (read_sel == 3'd6) ? ARVALID_S : 1'b0;
  assign AR_wdata = {ARID_S, ARADDR_S, ARLEN_S, ARSIZE_S, ARBURST_S};

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s0 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s0),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s0),
    .rclk  (rom_clk),
    .rrst  (rom_rst), 
    .rpop  (ARREADY_S0_i),
    .rdata (AR_rdata_s0),
    .rempty(AR_rempty_s0)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s1 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s1),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s1),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (ARREADY_S1_i),
    .rdata (AR_rdata_s1),
    .rempty(AR_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s2 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s2),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s2),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (ARREADY_S2_i),
    .rdata (AR_rdata_s2),
    .rempty(AR_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s3 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s3),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s3),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (ARREADY_S3_i),
    .rdata (AR_rdata_s3),
    .rempty(AR_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s4 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s4),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s4),
    .rclk  (dram_clk),
    .rrst  (dram_rst), 
    .rpop  (ARREADY_S4_i),
    .rdata (AR_rdata_s4),
    .rempty(AR_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s5 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s5),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s5),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (ARREADY_S5_i),
    .rdata (AR_rdata_s5),
    .rempty(AR_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_s6 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AR_wpush_s6),
    .wdata (AR_wdata), 
    .wfull (AR_wfull_s6),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (ARREADY_S6_i),
    .rdata (AR_rdata_s6),
    .rempty(AR_rempty_s6)
  );

  // out
  //axi
  assign ARREADY_S = AR_wfull_s0 | AR_wfull_s1 | AR_wfull_s2 | AR_wfull_s3 | AR_wfull_s4 | AR_wfull_s5 | AR_wfull_s6;
  assign {ARID_S0_o, ARADDR_S0_o, ARLEN_S0_o, ARSIZE_S0_o, ARBURST_S0_o} = {4'd0, AR_rdata_s0};
  assign {ARID_S1_o, ARADDR_S1_o, ARLEN_S1_o, ARSIZE_S1_o, ARBURST_S1_o} = {4'd0, AR_rdata_s1};
  assign {ARID_S2_o, ARADDR_S2_o, ARLEN_S2_o, ARSIZE_S2_o, ARBURST_S2_o} = {4'd0, AR_rdata_s2};
  assign {ARID_S3_o, ARADDR_S3_o, ARLEN_S3_o, ARSIZE_S3_o, ARBURST_S3_o} = {4'd0, AR_rdata_s3};
  assign {ARID_S4_o, ARADDR_S4_o, ARLEN_S4_o, ARSIZE_S4_o, ARBURST_S4_o} = {4'd0, AR_rdata_s4};
  assign {ARID_S5_o, ARADDR_S5_o, ARLEN_S5_o, ARSIZE_S5_o, ARBURST_S5_o} = {4'd0, AR_rdata_s5};
  assign {ARID_S6_o, ARADDR_S6_o, ARLEN_S6_o, ARSIZE_S6_o, ARBURST_S6_o} = {4'd0, AR_rdata_s6};
  //cpu
  assign ARVALID_S0_o = ~AR_rempty_s0;
  assign ARVALID_S1_o = ~AR_rempty_s1;
  assign ARVALID_S2_o = ~AR_rempty_s2;
  assign ARVALID_S3_o = ~AR_rempty_s3;
  assign ARVALID_S4_o = ~AR_rempty_s4;
  assign ARVALID_S5_o = ~AR_rempty_s5;
  assign ARVALID_S6_o = ~AR_rempty_s6;


//----------------------- R  FIFO -------------------------
  // in
  assign R_rpop_s0 = (read_sel == 3'd0) ? RREADY_S : 1'b0;
  assign R_rpop_s1 = (read_sel == 3'd1) ? RREADY_S : 1'b0;
  assign R_rpop_s2 = (read_sel == 3'd2) ? RREADY_S : 1'b0;
  assign R_rpop_s3 = (read_sel == 3'd3) ? RREADY_S : 1'b0;
  assign R_rpop_s4 = (read_sel == 3'd4) ? RREADY_S : 1'b0;
  assign R_rpop_s5 = (read_sel == 3'd5) ? RREADY_S : 1'b0;
  assign R_rpop_s6 = (read_sel == 3'd6) ? RREADY_S : 1'b0;


  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s0 (
    .wclk  (rom_clk),
    .wrst  (rom_rst),
    .wpush (RVALID_S0_i),
    .wdata ({RID_S0_i[3:0], RDATA_S0_i, RLAST_S0_i}), 
    .wfull (RREADY_S0_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s0),
    .rdata (R_rdata_s0),
    .rempty(R_rempty_s0)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s1 (
    .wclk  (sram_clk),
    .wrst  (sram_rst),
    .wpush (RVALID_S1_i),
    .wdata ({RID_S1_i[3:0], RDATA_S1_i, RLAST_S1_i}), 
    .wfull (RREADY_S1_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s1),
    .rdata (R_rdata_s1),
    .rempty(R_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s2 (
    .wclk  (sram_clk),
    .wrst  (sram_rst),
    .wpush (RVALID_S2_i),
    .wdata ({RID_S2_i[3:0], RDATA_S2_i, RLAST_S2_i}), 
    .wfull (RREADY_S2_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s2),
    .rdata (R_rdata_s2),
    .rempty(R_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s3 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (RVALID_S3_i),
    .wdata ({RID_S3_i[3:0], RDATA_S3_i, RLAST_S3_i}), 
    .wfull (RREADY_S3_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s3),
    .rdata (R_rdata_s3),
    .rempty(R_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s4 (
    .wclk  (dram_clk),
    .wrst  (dram_rst),
    .wpush (RVALID_S4_i),
    .wdata ({RID_S4_i[3:0], RDATA_S4_i, RLAST_S4_i}), 
    .wfull (RREADY_S4_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s4),
    .rdata (R_rdata_s4),
    .rempty(R_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s5 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (RVALID_S5_i),
    .wdata ({RID_S5_i[3:0], RDATA_S5_i, RLAST_S5_i}), 
    .wfull (RREADY_S5_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s5),
    .rdata (R_rdata_s5),
    .rempty(R_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_s6 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (RVALID_S6_i),
    .wdata ({RID_S6_i[3:0], RDATA_S6_i, RLAST_S6_i}), 
    .wfull (RREADY_S6_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (R_rpop_s6),
    .rdata (R_rdata_s6),
    .rempty(R_rempty_s6)
  );

  // output
  // AXI
  assign RVALID_S = ~R_rempty_s0 | ~R_rempty_s1 | ~R_rempty_s2 | ~R_rempty_s3 | ~R_rempty_s4 | ~R_rempty_s5 | ~R_rempty_s6;
  always_comb begin
    case (read_sel)
      3'd0:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s0;
      3'd1:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s1;
      3'd2:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s2;
      3'd3:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s3;
      3'd4:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s4;
      3'd5:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s5;
      3'd6:    {RID_S, RDATA_S, RLAST_S} = R_rdata_s6;
      default: {RID_S, RDATA_S, RLAST_S} = `RFIFO_DATASIZE'd0;
    endcase
  end

//----------------------- AW FIFO -------------------------
  // in
  assign AW_wpush_s1 = (write_sel == 3'd1) ? AWVALID_S : 1'b0;
  assign AW_wpush_s2 = (write_sel == 3'd2) ? AWVALID_S : 1'b0;
  assign AW_wpush_s3 = (write_sel == 3'd3) ? AWVALID_S : 1'b0;
  assign AW_wpush_s4 = (write_sel == 3'd4) ? AWVALID_S : 1'b0;
  assign AW_wpush_s5 = (write_sel == 3'd5) ? AWVALID_S : 1'b0;
  assign AW_wpush_s6 = (write_sel == 3'd6) ? AWVALID_S : 1'b0;
  assign AW_wdata = {AWID_S, AWADDR_S, AWLEN_S, AWSIZE_S, AWBURST_S};

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s1 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s1),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s1),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (AWREADY_S1_i),
    .rdata (AW_rdata_s1),
    .rempty(AW_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s2 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s2),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s2),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (AWREADY_S2_i),
    .rdata (AW_rdata_s2),
    .rempty(AW_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s3 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s3),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s3),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (AWREADY_S3_i),
    .rdata (AW_rdata_s3),
    .rempty(AW_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s4 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s4),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s4),
    .rclk  (dram_clk),
    .rrst  (dram_rst), 
    .rpop  (AWREADY_S4_i),
    .rdata (AW_rdata_s4),
    .rempty(AW_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s5 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s5),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s5),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (AWREADY_S5_i),
    .rdata (AW_rdata_s5),
    .rempty(AW_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_s6 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (AW_wpush_s6),
    .wdata (AW_wdata), 
    .wfull (AW_wfull_s6),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (AWREADY_S6_i),
    .rdata (AW_rdata_s6),
    .rempty(AW_rempty_s6)
  );

  // out
  //axi
  assign AWREADY_S = AW_wfull_s1 | AW_wfull_s2 | AW_wfull_s3 | AW_wfull_s4 | AW_wfull_s5 | AW_wfull_s6;
  assign {AWID_S1_o, AWADDR_S1_o, AWLEN_S1_o, AWSIZE_S1_o, AWBURST_S1_o} = {4'd0, AW_rdata_s1};
  assign {AWID_S2_o, AWADDR_S2_o, AWLEN_S2_o, AWSIZE_S2_o, AWBURST_S2_o} = {4'd0, AW_rdata_s2};
  assign {AWID_S3_o, AWADDR_S3_o, AWLEN_S3_o, AWSIZE_S3_o, AWBURST_S3_o} = {4'd0, AW_rdata_s3};
  assign {AWID_S4_o, AWADDR_S4_o, AWLEN_S4_o, AWSIZE_S4_o, AWBURST_S4_o} = {4'd0, AW_rdata_s4};
  assign {AWID_S5_o, AWADDR_S5_o, AWLEN_S5_o, AWSIZE_S5_o, AWBURST_S5_o} = {4'd0, AW_rdata_s5};
  assign {AWID_S6_o, AWADDR_S6_o, AWLEN_S6_o, AWSIZE_S6_o, AWBURST_S6_o} = {4'd0, AW_rdata_s6};
  //cpu
  assign AWVALID_S1_o = ~AW_rempty_s1;
  assign AWVALID_S2_o = ~AW_rempty_s2;
  assign AWVALID_S3_o = ~AW_rempty_s3;
  assign AWVALID_S4_o = ~AW_rempty_s4;
  assign AWVALID_S5_o = ~AW_rempty_s5;
  assign AWVALID_S6_o = ~AW_rempty_s6;

// new(v7)
//----------------------- W  FIFO -------------------------
  // in
  logic sync_wready_s1, sync_wready_temp_s1, wready_s1;
  logic sync_wready_s2, sync_wready_temp_s2, wready_s2;
  logic sync_wready_s3, sync_wready_temp_s3, wready_s3;
  logic sync_wready_s4, sync_wready_temp_s4, wready_s4;
  logic sync_wready_s5, sync_wready_temp_s5, wready_s5;
  logic sync_wready_s6, sync_wready_temp_s6, wready_s6;

  assign W_wpush_s1 = (write_sel == 3'd1 && sync_wready_s1) ? WVALID_S : 1'b0;
  assign W_wpush_s2 = (write_sel == 3'd2 && sync_wready_s2) ? WVALID_S : 1'b0;
  assign W_wpush_s3 = (write_sel == 3'd3 && sync_wready_s3) ? WVALID_S : 1'b0;
  assign W_wpush_s4 = (write_sel == 3'd4 && sync_wready_s4) ? WVALID_S : 1'b0;
  assign W_wpush_s5 = (write_sel == 3'd5 && sync_wready_s5) ? WVALID_S : 1'b0;
  assign W_wpush_s6 = (write_sel == 3'd6 && sync_wready_s6) ? WVALID_S : 1'b0;
  assign W_wdata = {WDATA_S, WSTRB_S, WLAST_S};


  // sync wready from slaves
  always_ff @(posedge sram_clk or posedge sram_rst) begin
    if(sram_rst) wready_s1 <= 2'd0;
    else 	       wready_s1 <= WREADY_S1_i;
  end
  always_ff @(posedge sram_clk or posedge sram_rst) begin
    if(sram_rst) wready_s2 <= 2'd0;
    else 	       wready_s2 <= WREADY_S2_i;
  end
  always_ff @(posedge cpu_clk or posedge cpu_rst) begin
    if(cpu_rst) wready_s3 <= 2'd0;
    else 	      wready_s3 <= WREADY_S3_i;
  end
  always_ff @(posedge dram_clk or posedge dram_rst) begin
    if(dram_rst) wready_s4 <= 2'd0;
    else 	       wready_s4 <= WREADY_S4_i;
  end
  always_ff @(posedge cpu_clk or posedge cpu_rst) begin
    if(cpu_rst) wready_s5 <= 2'd0;
    else 	      wready_s5 <= WREADY_S5_i;
  end
  always_ff @(posedge cpu_clk or posedge cpu_rst) begin
    if(cpu_rst) wready_s6 <= 2'd0;
    else 	      wready_s6 <= WREADY_S6_i;
  end

	always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) begin
      {sync_wready_s1, sync_wready_temp_s1} <= 2'd0;
      {sync_wready_s2, sync_wready_temp_s2} <= 2'd0;
      {sync_wready_s3, sync_wready_temp_s3} <= 2'd0;
      {sync_wready_s4, sync_wready_temp_s4} <= 2'd0;
      {sync_wready_s5, sync_wready_temp_s5} <= 2'd0;
      {sync_wready_s6, sync_wready_temp_s6} <= 2'd0;
    end
    else begin
      {sync_wready_s1, sync_wready_temp_s1} <= {sync_wready_temp_s1, wready_s1};
      {sync_wready_s2, sync_wready_temp_s2} <= {sync_wready_temp_s2, wready_s2};
      {sync_wready_s3, sync_wready_temp_s3} <= {sync_wready_temp_s3, wready_s3};
      {sync_wready_s4, sync_wready_temp_s4} <= {sync_wready_temp_s4, wready_s4};
      {sync_wready_s5, sync_wready_temp_s5} <= {sync_wready_temp_s5, wready_s5};
      {sync_wready_s6, sync_wready_temp_s6} <= {sync_wready_temp_s6, wready_s6};
    end
  end

	
  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s1 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s1),
    .wdata (W_wdata), 
    .wfull (W_wfull_s1),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (WREADY_S1_i & ~W_rempty_s1),
    .rdata (W_rdata_s1),
    .rempty(W_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s2 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s2),
    .wdata (W_wdata), 
    .wfull (W_wfull_s2),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (WREADY_S2_i & ~W_rempty_s2),
    .rdata (W_rdata_s2),
    .rempty(W_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s3 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s3),
    .wdata (W_wdata), 
    .wfull (W_wfull_s3),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S3_i & ~W_rempty_s3),
    .rdata (W_rdata_s3),
    .rempty(W_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s4 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s4),
    .wdata (W_wdata), 
    .wfull (W_wfull_s4),
    .rclk  (dram_clk),
    .rrst  (dram_rst), 
    .rpop  (WREADY_S4_i & ~W_rempty_s4),
    .rdata (W_rdata_s4),
    .rempty(W_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s5 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s5),
    .wdata (W_wdata), 
    .wfull (W_wfull_s5),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S5_i & ~W_rempty_s5),
    .rdata (W_rdata_s5),
    .rempty(W_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s6 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s6),
    .wdata (W_wdata), 
    .wfull (W_wfull_s6),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S6_i & ~W_rempty_s6),
    .rdata (W_rdata_s6),
    .rempty(W_rempty_s6)
  );

  // out
  //axi
  assign WREADY_S = W_wfull_s1 | W_wfull_s2 | W_wfull_s3 | W_wfull_s4 | W_wfull_s5 | W_wfull_s6;
  assign {WDATA_S1_o, WSTRB_S1_o, WLAST_S1_o} = W_rdata_s1;
  assign {WDATA_S2_o, WSTRB_S2_o, WLAST_S2_o} = W_rdata_s2;
  assign {WDATA_S3_o, WSTRB_S3_o, WLAST_S3_o} = W_rdata_s3;
  assign {WDATA_S4_o, WSTRB_S4_o, WLAST_S4_o} = W_rdata_s4;
  assign {WDATA_S5_o, WSTRB_S5_o, WLAST_S5_o} = W_rdata_s5;
  assign {WDATA_S6_o, WSTRB_S6_o, WLAST_S6_o} = W_rdata_s6;
  //cpu
  assign WVALID_S1_o = ~W_rempty_s1;
  assign WVALID_S2_o = ~W_rempty_s2;
  assign WVALID_S3_o = ~W_rempty_s3;
  assign WVALID_S4_o = ~W_rempty_s4;
  assign WVALID_S5_o = ~W_rempty_s5;
  assign WVALID_S6_o = ~W_rempty_s6;

// old (v6)  
  /*
//----------------------- W  FIFO -------------------------
  // in
  assign W_wpush_s1 = (write_sel == 3'd1 && WREADY_S1_i) ? WVALID_S : 1'b0;
  assign W_wpush_s2 = (write_sel == 3'd2 && WREADY_S2_i) ? WVALID_S : 1'b0;
  assign W_wpush_s3 = (write_sel == 3'd3 && WREADY_S3_i) ? WVALID_S : 1'b0;
  assign W_wpush_s4 = (write_sel == 3'd4 && WREADY_S4_i) ? WVALID_S : 1'b0;
  assign W_wpush_s5 = (write_sel == 3'd5 && WREADY_S5_i) ? WVALID_S : 1'b0;
  assign W_wpush_s6 = (write_sel == 3'd6 && WREADY_S6_i) ? WVALID_S : 1'b0;
  assign W_wdata = {WDATA_S, WSTRB_S, WLAST_S};

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s1 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s1),
    .wdata (W_wdata), 
    .wfull (W_wfull_s1),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (WREADY_S1_i & ~W_rempty_s1),
    .rdata (W_rdata_s1),
    .rempty(W_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s2 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s2),
    .wdata (W_wdata), 
    .wfull (W_wfull_s2),
    .rclk  (sram_clk),
    .rrst  (sram_rst), 
    .rpop  (WREADY_S2_i & ~W_rempty_s2),
    .rdata (W_rdata_s2),
    .rempty(W_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s3 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s3),
    .wdata (W_wdata), 
    .wfull (W_wfull_s3),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S3_i & ~W_rempty_s3),
    .rdata (W_rdata_s3),
    .rempty(W_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s4 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s4),
    .wdata (W_wdata), 
    .wfull (W_wfull_s4),
    .rclk  (dram_clk),
    .rrst  (dram_rst), 
    .rpop  (WREADY_S4_i & ~W_rempty_s4),
    .rdata (W_rdata_s4),
    .rempty(W_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s5 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s5),
    .wdata (W_wdata), 
    .wfull (W_wfull_s5),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S5_i & ~W_rempty_s5),
    .rdata (W_rdata_s5),
    .rempty(W_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_s6 (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (W_wpush_s6),
    .wdata (W_wdata), 
    .wfull (W_wfull_s6),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst), 
    .rpop  (WREADY_S6_i & ~W_rempty_s6),
    .rdata (W_rdata_s6),
    .rempty(W_rempty_s6)
  );

  // out
  //axi
  assign WREADY_S = W_wfull_s1 | W_wfull_s2 | W_wfull_s3 | W_wfull_s4 | W_wfull_s5 | W_wfull_s6;
  assign {WDATA_S1_o, WSTRB_S1_o, WLAST_S1_o} = W_rdata_s1;
  assign {WDATA_S2_o, WSTRB_S2_o, WLAST_S2_o} = W_rdata_s2;
  assign {WDATA_S3_o, WSTRB_S3_o, WLAST_S3_o} = W_rdata_s3;
  assign {WDATA_S4_o, WSTRB_S4_o, WLAST_S4_o} = W_rdata_s4;
  assign {WDATA_S5_o, WSTRB_S5_o, WLAST_S5_o} = W_rdata_s5;
  assign {WDATA_S6_o, WSTRB_S6_o, WLAST_S6_o} = W_rdata_s6;
  //cpu
  assign WVALID_S1_o = ~W_rempty_s1;
  assign WVALID_S2_o = ~W_rempty_s2;
  assign WVALID_S3_o = ~W_rempty_s3;
  assign WVALID_S4_o = ~W_rempty_s4;
  assign WVALID_S5_o = ~W_rempty_s5;
  assign WVALID_S6_o = ~W_rempty_s6;

  */

//----------------------- B  FIFO -------------------------
  // in
  assign B_rpop_s1 = (write_sel == 3'd1) ? BREADY_S : 1'b0;
  assign B_rpop_s2 = (write_sel == 3'd2) ? BREADY_S : 1'b0;
  assign B_rpop_s3 = (write_sel == 3'd3) ? BREADY_S : 1'b0;
  assign B_rpop_s4 = (write_sel == 3'd4) ? BREADY_S : 1'b0;
  assign B_rpop_s5 = (write_sel == 3'd5) ? BREADY_S : 1'b0;
  assign B_rpop_s6 = (write_sel == 3'd6) ? BREADY_S : 1'b0;

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s1 (
    .wclk  (sram_clk),
    .wrst  (sram_rst),
    .wpush (BVALID_S1_i),
    .wdata ({BID_S1_i[3:0], BRESP_S1_i}), 
    .wfull (BREADY_S1_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s1),
    .rdata (B_rdata_s1),
    .rempty(B_rempty_s1)
  );

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s2 (
    .wclk  (sram_clk),
    .wrst  (sram_rst),
    .wpush (BVALID_S2_i),
    .wdata ({BID_S2_i[3:0], BRESP_S2_i}), 
    .wfull (BREADY_S2_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s2),
    .rdata (B_rdata_s2),
    .rempty(B_rempty_s2)
  );

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s3 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (BVALID_S3_i),
    .wdata ({BID_S3_i[3:0], BRESP_S3_i}), 
    .wfull (BREADY_S3_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s3),
    .rdata (B_rdata_s3),
    .rempty(B_rempty_s3)
  );

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s4 (
    .wclk  (dram_clk),
    .wrst  (dram_rst),
    .wpush (BVALID_S4_i),
    .wdata ({BID_S4_i[3:0], BRESP_S4_i}), 
    .wfull (BREADY_S4_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s4),
    .rdata (B_rdata_s4),
    .rempty(B_rempty_s4)
  );

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s5 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (BVALID_S5_i),
    .wdata ({BID_S5_i[3:0], BRESP_S5_i}), 
    .wfull (BREADY_S5_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s5),
    .rdata (B_rdata_s5),
    .rempty(B_rempty_s5)
  );

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_s6 (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (BVALID_S6_i),
    .wdata ({BID_S6_i[3:0], BRESP_S6_i}), 
    .wfull (BREADY_S6_o),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (B_rpop_s6),
    .rdata (B_rdata_s6),
    .rempty(B_rempty_s6)
  );

  // output
  // AXI
  assign BVALID_S = ~B_rempty_s1 | ~B_rempty_s2 | ~B_rempty_s3 | ~B_rempty_s4 | ~B_rempty_s5 | ~B_rempty_s6;
  always_comb begin
    case (read_sel)
      3'd1:    {BID_S, BRESP_S} = B_rdata_s1;
      3'd2:    {BID_S, BRESP_S} = B_rdata_s2;
      3'd3:    {BID_S, BRESP_S} = B_rdata_s3;
      3'd4:    {BID_S, BRESP_S} = B_rdata_s4;
      3'd5:    {BID_S, BRESP_S} = B_rdata_s5;
      3'd6:    {BID_S, BRESP_S} = B_rdata_s6;
      default: {BID_S, BRESP_S} = `BFIFO_DATASIZE'd0;
    endcase
  end

endmodule
