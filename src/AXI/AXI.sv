//*********************************************************
// Auther:      N26111512
// Filename:    AXI.sv [FINAL]
// Description: Top module of AXI 
// Version:     7.0  (FSM 3 stage)
// Date:        1/9
// Note:        add state to reset wready
//*********************************************************

`include "interface_master.sv"
`include "interface_slave.sv"
`include "../CDC/async_fifo.sv"
//`include "../CDC/sync2ff.sv"

module AXI(
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
  //MASTER INTERFACE
  // M0
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M0_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M0_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_i,
  input  logic [1:0]                ARBURST_M0_i,
  input  logic                      ARVALID_M0_i,
  output logic                      ARREADY_M0_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M0_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M0_o,
  output logic [1:0]                RRESP_M0_o,
  output logic                      RLAST_M0_o,
  output logic                      RVALID_M0_o,
  input  logic                      RREADY_M0_i,
  // M1
  // WRITE
  input  logic[`AXI_ID_BITS-1:0]    AWID_M1_i,
  input  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M1_i,
  input  logic[`AXI_LEN_BITS-1:0]   AWLEN_M1_i,
  input  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M1_i,
  input  logic[1:0]                 AWBURST_M1_i,
  input  logic                      AWVALID_M1_i,
  output logic                      AWREADY_M1_o,
  input  logic [`AXI_DATA_BITS-1:0] WDATA_M1_i,
  input  logic [`AXI_STRB_BITS-1:0] WSTRB_M1_i,
  input  logic                      WLAST_M1_i,
  input  logic                      WVALID_M1_i,
  output logic                      WREADY_M1_o,
  output logic [`AXI_ID_BITS-1:0]   BID_M1_o,
  output logic [1:0]                BRESP_M1_o,
  output logic                      BVALID_M1_o,
  input  logic                      BREADY_M1_i,
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M1_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M1_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_i,
  input  logic [1:0]                ARBURST_M1_i,
  input  logic                      ARVALID_M1_i,
  output logic                      ARREADY_M1_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M1_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M1_o,
  output logic [1:0]                RRESP_M1_o,
  output logic                      RLAST_M1_o,
  output logic                      RVALID_M1_o,
  input  logic                      RREADY_M1_i,
  // M2
  // WRITE
  input  logic[`AXI_ID_BITS-1:0]    AWID_M2_i,
  input  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M2_i,
  input  logic[`AXI_LEN_BITS-1:0]   AWLEN_M2_i,
  input  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M2_i,
  input  logic[1:0]                 AWBURST_M2_i,
  input  logic                      AWVALID_M2_i,
  output logic                      AWREADY_M2_o,
  input  logic [`AXI_DATA_BITS-1:0] WDATA_M2_i,
  input  logic [`AXI_STRB_BITS-1:0] WSTRB_M2_i,
  input  logic                      WLAST_M2_i,
  input  logic                      WVALID_M2_i,
  output logic                      WREADY_M2_o,
  output logic [`AXI_ID_BITS-1:0]   BID_M2_o,
  output logic [1:0]                BRESP_M2_o,
  output logic                      BVALID_M2_o,
  input  logic                      BREADY_M2_i,
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M2_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M2_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M2_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M2_i,
  input  logic [1:0]                ARBURST_M2_i,
  input  logic                      ARVALID_M2_i,
  output logic                      ARREADY_M2_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M2_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M2_o,
  output logic [1:0]                RRESP_M2_o,
  output logic                      RLAST_M2_o,
  output logic                      RVALID_M2_o,
  input  logic                      RREADY_M2_i,

  //SLAVE INTERFACE
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
  output logic                      RREADY_S6_o
    
);

  // Slave configuration
  localparam S0_START = 32'h0000_0000;  localparam S0_END = 32'h0000_3fff;  //ROM
  localparam S1_START = 32'h0001_0000;  localparam S1_END = 32'h0001_ffff;  //IM
  localparam S2_START = 32'h0002_0000;  localparam S2_END = 32'h0002_ffff;  //DM
  localparam S3_START = 32'h1000_0000;  localparam S3_END = 32'h1000_03ff;  //sensor ctrl
  localparam S4_START = 32'h2000_0000;  localparam S4_END = 32'h207f_ffff;  //DRAM
  localparam S5_START = 32'h3fff_ffff;  localparam S5_END = 32'h4001_0000;  //DMA
  localparam S6_START = 32'h4fff_ffff;  localparam S6_END = 32'h8fff_ffff;  //EPU


//================= Sync. AXI signal ==================
  //MASTER INTERFACE
  //READ ADDRESS
  logic [`AXI_ID_BITS-1:0] ARID_M;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_M;
  logic [`AXI_LEN_BITS-1:0] ARLEN_M;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M;
  logic [1:0] ARBURST_M;
  logic ARVALID_M, ARREADY_M;
  //READ DATA
	logic [`AXI_ID_BITS-1:0] RID_M;
	logic [`AXI_DATA_BITS-1:0] RDATA_M;
	logic [1:0] RRESP_M;
	logic RLAST_M;
  logic RVALID_M, RREADY_M;
  //WRITE ADDRESS
  logic [`AXI_ID_BITS-1:0] AWID_M;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_M;
  logic [`AXI_LEN_BITS-1:0] AWLEN_M;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M;
  logic [1:0] AWBURST_M;
  logic AWVALID_M, AWREADY_M;
  //WRITE DATA
  logic [`AXI_DATA_BITS-1:0] WDATA_M;
  logic [`AXI_STRB_BITS-1:0] WSTRB_M;
  logic WLAST_M;
  logic WVALID_M, WREADY_M;
  //WRITE RESPONSE
	logic [`AXI_ID_BITS-1:0] BID_M;
	logic [1:0] BRESP_M;
  logic BVALID_M, BREADY_M;

  //SLAVE INTERFACE
  //WRITE ADDRESS
  logic [`AXI_ID_BITS-1:0] AWID_S;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_S;
  logic [`AXI_LEN_BITS-1:0] AWLEN_S;
  logic [`AXI_SIZE_BITS-1:0] AWSIZE_S;
  logic [1:0] AWBURST_S;
  logic AWVALID_S;
  logic AWREADY_S;
  //WRITE DATA
  logic [`AXI_DATA_BITS-1:0] WDATA_S;
  logic [`AXI_STRB_BITS-1:0] WSTRB_S;
  logic WLAST_S;
  logic WVALID_S;
  logic WREADY_S;
  //WRITE RESPONSE
  logic [`AXI_ID_BITS-1:0] BID_S;
  logic [1:0] BRESP_S;
  logic BVALID_S;
  logic BREADY_S;
  //READ ADDRESS
  logic [`AXI_ID_BITS-1:0] ARID_S;
  logic [`AXI_ADDR_BITS-1:0] ARADDR_S;
  logic [`AXI_LEN_BITS-1:0] ARLEN_S;
  logic [`AXI_SIZE_BITS-1:0] ARSIZE_S;
  logic [1:0] ARBURST_S;
  logic ARVALID_S;
  logic ARREADY_S;
  //READ DATA
  logic [`AXI_ID_BITS-1:0] RID_S;
  logic [`AXI_DATA_BITS-1:0] RDATA_S;
  logic [1:0] RRESP_S;
  logic RLAST_S;
  logic RVALID_S;
  logic RREADY_S;

  //logic rslave_clk, rslave_rst;
  //logic wslave_clk, wslave_rst;
  logic [2:0] write_sel, read_sel;

  // CDC AXI 
  interface_master interface_m (
    .*
  );
  interface_slave interface_s (
    .*
  );

//================= Handshake Signal ==================
  // read handshake
  logic read_handshake;
  assign read_handshake = RREADY_M & RVALID_S;

  // write handshake
  logic W_handshake, B_handshake;
  assign W_handshake = WREADY_S & WVALID_M;
  assign B_handshake = BREADY_M & BVALID_S;


  // handshake finish check
  logic READ_FINISH, WRITE_FINISH;
  assign READ_FINISH  = RLAST_S && read_handshake;
  assign WRITE_FINISH = B_handshake;

//================= FSM ==================
  // localparam IDLE       = 3'd0;
  // localparam READ       = 3'd1;
  // localparam WRITE      = 3'd3;
  // localparam READ_WRITE = 3'd4;
  // logic [2:0] state, next_state;
  typedef enum logic [2:0] {
    IDLE       = 3'd0,
    READ       = 3'd1,
    WRITE      = 3'd3,
    READ_WRITE = 3'd4,
    // final new state 
    WRITE_WAIT = 3'd5,   // clear w_ch signal 
    RW_WAITW   = 3'd6,   // clear w_ch signal wait next waddr
		RW_WAITR   = 3'd7    // r_ch done wait w_ch
  } axi_state_t;
  axi_state_t state, next_state;

  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) state <= IDLE;
    else        state <= next_state;
  end

  always_comb begin
    unique case (state)
      IDLE: begin
        if(ARVALID_M && AWVALID_M) next_state = READ_WRITE; 
        else if        (ARVALID_M) next_state = READ;
        else if        (AWVALID_M) next_state = WRITE;
        else                       next_state = IDLE;
      end 
			READ: begin
				if(AWVALID_M) next_state = READ_WRITE;
				else if(READ_FINISH) next_state = IDLE;
				else next_state = READ;
			end
			WRITE: begin
        if     (W_handshake)  next_state = (WLAST_M) ? WRITE : WRITE_WAIT;
				else if(ARVALID_M)    next_state = READ_WRITE;
				else if(WRITE_FINISH) next_state = IDLE;
				else                  next_state = WRITE;
			end
      READ_WRITE: begin
				if(read_handshake && ~RLAST_S)       next_state = RW_WAITR;
        else if(W_handshake)                 next_state = RW_WAITW;
        else if(READ_FINISH && WRITE_FINISH) next_state = IDLE;
        else if(WRITE_FINISH)                next_state = READ;
        else if(READ_FINISH)                 next_state = WRITE;
        else                                 next_state = READ_WRITE;
      end
      WRITE_WAIT: next_state = (WREADY_S)    ? WRITE_WAIT : WRITE;
      RW_WAITW: 	next_state = (WREADY_S)    ? RW_WAITW   : READ_WRITE;
      RW_WAITR: begin
        if(RLAST_S) next_state = READ_WRITE;
        else if(W_handshake) next_state = (WLAST_M)? IDLE : RW_WAITW;
        else  next_state = RW_WAITR;
      end
      default: 		next_state = IDLE;
    endcase
  end

//================= sel signal ==================
  // read slave select
  // always_comb begin
  //   if     ((ARADDR_M >= S0_START) && (ARADDR_M <= S0_END)) read_sel = 3'd0;
  //   else if((ARADDR_M >= S1_START) && (ARADDR_M <= S1_END)) read_sel = 3'd1;
  //   else if((ARADDR_M >= S2_START) && (ARADDR_M <= S2_END)) read_sel = 3'd2;
  //   else if((ARADDR_M >= S3_START) && (ARADDR_M <= S3_END)) read_sel = 3'd3;
  //   else if((ARADDR_M >= S4_START) && (ARADDR_M <= S4_END)) read_sel = 3'd4;
  //   else if((ARADDR_M >= S5_START) && (ARADDR_M <= S5_END)) read_sel = 3'd5;
  //   else if((ARADDR_M >= S6_START) && (ARADDR_M <= S6_END)) read_sel = 3'd6;
  //   else                                                    read_sel = 3'd7;
  // end
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) read_sel <= 3'd0;
    else begin
      if     ((ARADDR_M >= S0_START) && (ARADDR_M <= S0_END)) read_sel <= 3'd0;
      else if((ARADDR_M >= S1_START) && (ARADDR_M <= S1_END)) read_sel <= 3'd1;
      else if((ARADDR_M >= S2_START) && (ARADDR_M <= S2_END)) read_sel <= 3'd2;
      else if((ARADDR_M >= S3_START) && (ARADDR_M <= S3_END)) read_sel <= 3'd3;
      else if((ARADDR_M >= S4_START) && (ARADDR_M <= S4_END)) read_sel <= 3'd4;
      else if((ARADDR_M >= S5_START) && (ARADDR_M <= S5_END)) read_sel <= 3'd5;
      else if((ARADDR_M >= S6_START) && (ARADDR_M <= S6_END)) read_sel <= 3'd6;
      else                                                    read_sel <= 3'd7;
    end
  end
  

  // write slave select
  // always_comb begin
  //   if     ((AWADDR_M >= S0_START) && (AWADDR_M <= S0_END)) write_sel = 3'd0;
  //   else if((AWADDR_M >= S1_START) && (AWADDR_M <= S1_END)) write_sel = 3'd1;
  //   else if((AWADDR_M >= S2_START) && (AWADDR_M <= S2_END)) write_sel = 3'd2;
  //   else if((AWADDR_M >= S3_START) && (AWADDR_M <= S3_END)) write_sel = 3'd3;
  //   else if((AWADDR_M >= S4_START) && (AWADDR_M <= S4_END)) write_sel = 3'd4;
  //   else if((AWADDR_M >= S5_START) && (AWADDR_M <= S5_END)) write_sel = 3'd5;
  //   else if((AWADDR_M >= S6_START) && (AWADDR_M <= S6_END)) write_sel = 3'd6;
  //   else                                                    write_sel = 3'd7;
  // end
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) write_sel <= 3'd0;
    else begin
      if     ((AWADDR_M >= S0_START) && (AWADDR_M <= S0_END)) write_sel <= 3'd0;
      else if((AWADDR_M >= S1_START) && (AWADDR_M <= S1_END)) write_sel <= 3'd1;
      else if((AWADDR_M >= S2_START) && (AWADDR_M <= S2_END)) write_sel <= 3'd2;
      else if((AWADDR_M >= S3_START) && (AWADDR_M <= S3_END)) write_sel <= 3'd3;
      else if((AWADDR_M >= S4_START) && (AWADDR_M <= S4_END)) write_sel <= 3'd4;
      else if((AWADDR_M >= S5_START) && (AWADDR_M <= S5_END)) write_sel <= 3'd5;
      else if((AWADDR_M >= S6_START) && (AWADDR_M <= S6_END)) write_sel <= 3'd6;
      else                                                    write_sel <= 3'd7;
    end
  end

//================= AXI signal ==================
  // AR Channel
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if (axi_rst) begin
      //master READ ADDRESS0  
      ARREADY_M <= 1'b0;
          
      //slave READ ADDRESS
      ARID_S    <= 4'd0;
      ARADDR_S  <= 32'd0;
      ARLEN_S   <= 8'd0;
      ARSIZE_S  <= 3'd0;
      ARBURST_S <= 2'b01;
      ARVALID_S <= 1'b0;
    end
    else begin 
      unique case (state)
        IDLE: begin
          //master READ ADDRESS0
          ARREADY_M <= 1'b0;
          
          //slave READ ADDRESS
          ARID_S    <= 4'd0;
          ARADDR_S  <= 32'd0;
          ARLEN_S   <= 8'd0;
          ARSIZE_S  <= 3'd0;
          ARBURST_S <= 2'b01;
          ARVALID_S <= 1'b0;
        end
        READ, READ_WRITE: begin
          //master READ ADDRESS0
          ARREADY_M <= ARREADY_S;
          
          //slave READ ADDRESS
          ARID_S    <= ARID_M;
          ARADDR_S  <= ARADDR_M;
          ARLEN_S   <= ARLEN_M;
          ARSIZE_S  <= ARSIZE_M;
          ARBURST_S <= ARBURST_M;
          ARVALID_S <= ARVALID_M;
        end
        default: begin
          //master READ ADDRESS0
          ARREADY_M <= 1'b0;
          
          //slave READ ADDRESS
          ARID_S    <= 4'd0;
          ARADDR_S  <= 32'd0;
          ARLEN_S   <= 8'd0;
          ARSIZE_S  <= 3'd0;
          ARBURST_S <= 2'b01;
          ARVALID_S <= 1'b0;
        end
      endcase
    end
  end

  // R Channel
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) begin
      //READ DATA0
      RID_M     <= 4'd0;
      RDATA_M   <= 32'd0;
      RRESP_M   <= 2'b00;
      RLAST_M   <= 1'b0;
      RVALID_M  <= 1'b0;

      //READ DATA0
      RREADY_S  <= 1'b0;
    end
    else begin
        case (state)
          IDLE: begin
            //READ DATA0
            RID_M     <= 4'd0;
            RDATA_M   <= 32'd0;
            RRESP_M   <= 2'b00;
            RLAST_M   <= 1'b0;
            RVALID_M  <= 1'b0;

            //READ DATA0
            RREADY_S  <= 1'b0;
          end
          READ, READ_WRITE: begin
            //READ DATA0
            RID_M     <= RID_S;
            RDATA_M   <= RDATA_S;
            RRESP_M   <= RRESP_S;
            RLAST_M   <= RLAST_S;
            RVALID_M  <= RVALID_S;

            //READ DATA0
            RREADY_S  <= RREADY_M;
          end
          default: begin
            //READ DATA0
            RID_M     <= 4'd0;
            RDATA_M   <= 32'd0;
            RRESP_M   <= 2'b00;
            RLAST_M   <= 1'b0;
            RVALID_M  <= 1'b0;

            //READ DATA0
            RREADY_S  <= 1'b0;
          end
        endcase
      end
    end

    // AW Channel
    always_ff @(posedge axi_clk or posedge axi_rst) begin
      if(axi_rst) begin
        //WRITE ADDRESS
        AWREADY_M <= 1'b0;
      
        //WRITE ADDRESS1
        AWID_S    <= 4'd0;;
        AWADDR_S  <= 32'd0;
        AWLEN_S   <= 8'd0;
        AWSIZE_S  <= 3'd0;
        AWBURST_S <= 2'b01;
        AWVALID_S <= 1'b0;
      end
      else begin
        case (state)
          IDLE: begin
            //WRITE ADDRESS
            AWREADY_M <= 1'b0;
      
            //WRITE ADDRESS1
            AWID_S    <= 4'd0;;
            AWADDR_S  <= 32'd0;
            AWLEN_S   <= 8'd0;
            AWSIZE_S  <= 3'd0;
            AWBURST_S <= 2'b01;
            AWVALID_S <= 1'b0;
          end
          WRITE, READ_WRITE, RW_WAITR: begin
            //WRITE ADDRESS
            AWREADY_M <= AWREADY_S;
      
            //WRITE ADDRESS1
            AWID_S    <= AWID_M;
            AWADDR_S  <= AWADDR_M;
            AWLEN_S   <= AWLEN_M;
            AWSIZE_S  <= AWSIZE_M;
            AWBURST_S <= AWBURST_M;
            AWVALID_S <= AWVALID_M;
          end 
          default: begin
            //WRITE ADDRESS
            AWREADY_M <= 1'b0;
      
            //WRITE ADDRESS1
            AWID_S    <= 4'd0;;
            AWADDR_S  <= 32'd0;
            AWLEN_S   <= 8'd0;
            AWSIZE_S  <= 3'd0;
            AWBURST_S <= 2'b01;
            AWVALID_S <= 1'b0;
          end
        endcase
      end
    end

  // W Channel
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) begin
      //WRITE DATA
      WREADY_M  <= 1'b0;
    
      //WRITE DATA1
      WDATA_S   <= 32'd0;
      WSTRB_S   <= 4'b1111;
      WLAST_S   <= 1'b0;
      WVALID_S  <= 1'b0;
    end
    else begin
      case (state)
        IDLE: begin
          //WRITE DATA
          WREADY_M  <= 1'b0;
      
          //WRITE DATA1
          WDATA_S   <= 32'd0;
          WSTRB_S   <= 4'b1111;
          WLAST_S   <= 1'b0;
          WVALID_S  <= 1'b0;
        end
        WRITE, READ_WRITE, RW_WAITR: begin
          //WRITE DATA
          WREADY_M  <= WREADY_S;
    
          //WRITE DATA1
          WDATA_S   <= WDATA_M;
          WSTRB_S   <= WSTRB_M;
          WLAST_S   <= WLAST_M;
          WVALID_S  <= WVALID_M;
        end 
        default: begin
          //WRITE DATA
          WREADY_M  <= 1'b0;
    
          //WRITE DATA1
          WDATA_S   <= 32'd0;
          WSTRB_S   <= 4'b1111;
          WLAST_S   <= 1'b0;
          WVALID_S  <= 1'b0;
        end
      endcase
    end
  end

  // B Channel
  always_ff @(posedge axi_clk or posedge axi_rst) begin
    if(axi_rst) begin
      //WRITE RESPONSE
      BID_M     <= 4'd0;
      BRESP_M   <= 2'b00;
      BVALID_M  <= 1'b0;

      //WRITE RESPONSE1
      BREADY_S  <= 1'b0;
    end
    else begin
      case (state)
        IDLE: begin
          //WRITE RESPONSE
          BID_M     <= 4'd0;
          BRESP_M   <= 2'b00;
          BVALID_M  <= 1'b0;
    
          //WRITE RESPONSE1
          BREADY_S  <= 1'b0;
        end
        WRITE, READ_WRITE, RW_WAITR: begin
          //WRITE RESPONSE
          BID_M     <= BID_S;
          BRESP_M   <= BRESP_S;
          BVALID_M  <= BVALID_S;
    
          //WRITE RESPONSE1
          BREADY_S  <= BREADY_M;
        end 
        default: begin
          //WRITE RESPONSE
          BID_M     <= 4'd0;
          BRESP_M   <= 2'b00;
          BVALID_M  <= 1'b0;
    
          //WRITE RESPONSE1
          BREADY_S  <= 1'b0;
        end
      endcase
    end
  end


endmodule
