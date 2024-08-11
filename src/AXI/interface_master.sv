//*********************************************************
// Auther:      N26111512
// Filename:    interface_master.sv [FINAL]
// Description: connect masters and AXI
// Version:     5.0 (m0~m2)
// Date:        1/2/2024
//*********************************************************

module interface_master (
  input cpu_clk,
  input cpu_rst,
  input axi_clk,
  input axi_rst,

  //------ from Master -----
  // M0
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M0_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M0_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_i,
  input  logic [1:0]                ARBURST_M0_i,
  input  logic                      ARVALID_M0_i,

  input  logic                      RREADY_M0_i,

  // M1
  // WRITE
  input  logic[`AXI_ID_BITS-1:0]    AWID_M1_i,
  input  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M1_i,
  input  logic[`AXI_LEN_BITS-1:0]   AWLEN_M1_i,
  input  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M1_i,
  input  logic[1:0]                 AWBURST_M1_i,
  input  logic                      AWVALID_M1_i,

  input  logic [`AXI_DATA_BITS-1:0] WDATA_M1_i,
  input  logic [`AXI_STRB_BITS-1:0] WSTRB_M1_i,
  input  logic                      WLAST_M1_i,
  input  logic                      WVALID_M1_i,

  input  logic                      BREADY_M1_i,
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M1_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M1_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_i,
  input  logic [1:0]                ARBURST_M1_i,
  input  logic                      ARVALID_M1_i,

  input  logic                      RREADY_M1_i,

  // M2
  // WRITE
  input  logic[`AXI_ID_BITS-1:0]    AWID_M2_i,
  input  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M2_i,
  input  logic[`AXI_LEN_BITS-1:0]   AWLEN_M2_i,
  input  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M2_i,
  input  logic[1:0]                 AWBURST_M2_i,
  input  logic                      AWVALID_M2_i,

  input  logic [`AXI_DATA_BITS-1:0] WDATA_M2_i,
  input  logic [`AXI_STRB_BITS-1:0] WSTRB_M2_i,
  input  logic                      WLAST_M2_i,
  input  logic                      WVALID_M2_i,

  input  logic                      BREADY_M2_i,
  // READ
  input  logic [`AXI_ID_BITS-1:0]   ARID_M2_i,
  input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M2_i,
  input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M2_i,
  input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M2_i,
  input  logic [1:0]                ARBURST_M2_i,
  input  logic                      ARVALID_M2_i,

  input  logic                      RREADY_M2_i,


  //----- from AXI -----
	//READ ADDRESS1
	input ARREADY_M,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M,
	input [`AXI_DATA_BITS-1:0] RDATA_M,
	input [1:0] RRESP_M,
	input RLAST_M,
	input RVALID_M,
  //WRITE ADDRESS
	input AWREADY_M,
	//WRITE DATA
	input WREADY_M,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M,
	input [1:0] BRESP_M,
	input BVALID_M,

  //----- to AXI -----
  //READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output logic [1:0] ARBURST_M,
	output logic ARVALID_M,
	//READ DATA1
	output logic RREADY_M,

  //WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID_M,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output logic [1:0] AWBURST_M,
	output logic AWVALID_M,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	output logic WLAST_M,
	output logic WVALID_M,
	//WRITE RESPONSE
	output logic BREADY_M,

  //----- to Master -----
  // M0
  // READ
  output logic                      ARREADY_M0_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M0_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M0_o,
  output logic [1:0]                RRESP_M0_o,
  output logic                      RLAST_M0_o,
  output logic                      RVALID_M0_o,
  // M1
  // WRITE
  output logic                      AWREADY_M1_o,
  output logic                      WREADY_M1_o,
  output logic [`AXI_ID_BITS-1:0]   BID_M1_o,
  output logic [1:0]                BRESP_M1_o,
  output logic                      BVALID_M1_o,
  // READ
  output logic                      ARREADY_M1_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M1_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M1_o,
  output logic [1:0]                RRESP_M1_o,
  output logic                      RLAST_M1_o,
  output logic                      RVALID_M1_o,
  // M2
  // WRITE
  output logic                      AWREADY_M2_o,
  output logic                      WREADY_M2_o,
  output logic [`AXI_ID_BITS-1:0]   BID_M2_o,
  output logic [1:0]                BRESP_M2_o,
  output logic                      BVALID_M2_o,
  // READ
  output logic                      ARREADY_M2_o, 
  output logic [`AXI_ID_BITS-1:0]   RID_M2_o,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M2_o,
  output logic [1:0]                RRESP_M2_o,
  output logic                      RLAST_M2_o,
  output logic                      RVALID_M2_o
);

  logic AR_wpush, AR_rpop, AR_wfull, AR_rempty;
  logic R_wpush,   R_rpop,  R_wfull,  R_rempty;
  logic AW_wpush, AW_rpop, AW_wfull, AW_rempty;
  logic W_wpush,   W_rpop,  W_wfull,  W_rempty;
  logic B_wpush,   B_rpop,  B_wfull,  B_rempty;
  
  logic [`ARFIFO_DATASIZE-1:0] AR_wdata, AR_rdata;
  logic [`RFIFO_DATASIZE-1 :0]  R_wdata, R_rdata;
  logic [`AWFIFO_DATASIZE-1:0] AW_wdata, AW_rdata;
  logic [`WFIFO_DATASIZE-1 :0]  W_wdata, W_rdata;
  logic [`BFIFO_DATASIZE-1 :0]  B_wdata, B_rdata;
  
  logic [1:0] master_sel;   // 0:M0 1:M1 2:M2
  logic master_sel_write;   // 0:M1 1:M2


  //----------------------- AR FIFO -------------------------
  always_comb begin
    if     (ARVALID_M1_i || RREADY_M1_i) master_sel = 2'd1;
    else if(ARVALID_M2_i || RREADY_M2_i) master_sel = 2'd2;
    else                                 master_sel = 2'd0;
  end
  // in
  //assign AR_wpush = (master_sel) ? ARVALID_M1_i : ARVALID_M0_i;
  always_comb begin
    unique case (master_sel)
      2'd0:    AR_wpush = ARVALID_M0_i;
      2'd1:    AR_wpush = ARVALID_M1_i;
      2'd2:    AR_wpush = ARVALID_M2_i;
      default: AR_wpush = ARVALID_M0_i;
    endcase
  end
  assign AR_rpop  = ARREADY_M;
  always_comb begin
    unique case (master_sel)
      2'd0:    AR_wdata = {ARID_M0_i, ARADDR_M0_i, ARLEN_M0_i, ARSIZE_M0_i, ARBURST_M0_i};
      2'd1:    AR_wdata = {ARID_M1_i, ARADDR_M1_i, ARLEN_M1_i, ARSIZE_M1_i, ARBURST_M1_i};
      2'd2:    AR_wdata = {ARID_M2_i, ARADDR_M2_i, ARLEN_M2_i, ARSIZE_M2_i, ARBURST_M2_i};
      default: AR_wdata = {ARID_M0_i, ARADDR_M0_i, ARLEN_M0_i, ARSIZE_M0_i, ARBURST_M0_i};
    endcase
  end
  // assign AR_wdata = (master_sel) ? {ARID_M1_i, ARADDR_M1_i, ARLEN_M1_i, ARSIZE_M1_i, ARBURST_M1_i} : 
                                  //  {ARID_M0_i, ARADDR_M0_i, ARLEN_M0_i, ARSIZE_M0_i, ARBURST_M0_i};
  
  async_fifo #(
    .FIFO_DATASIZE(`ARFIFO_DATASIZE)
  ) arfifo_m (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (AR_wpush),
    .wdata (AR_wdata), 
    .wfull (AR_wfull),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (AR_rpop),
    .rdata (AR_rdata),
    .rempty(AR_rempty)
  );

  // out
  //cpu
  always_comb begin
    unique case (master_sel)
      2'd0: begin
        ARREADY_M0_o = AR_wfull;
        ARREADY_M1_o = 1'd0; 
        ARREADY_M2_o = 1'd0; 
      end   
      2'd1: begin
        ARREADY_M0_o = 1'd0;
        ARREADY_M1_o = AR_wfull;
        ARREADY_M2_o = 1'd0; 
      end
      2'd2: begin
        ARREADY_M0_o = 1'd0;
        ARREADY_M1_o = 1'd0;
        ARREADY_M2_o = AR_wfull; 
      end
      default: begin
        ARREADY_M0_o = 1'd0;
        ARREADY_M1_o = 1'd0;
        ARREADY_M2_o = 1'd0; 
      end
    endcase
  end
  // always_comb begin
  //   if(master_sel) begin
  //     ARREADY_M0_o = 1'd0;
  //     ARREADY_M1_o = AR_wfull;
  //   end
  //   else begin
  //     ARREADY_M0_o = AR_wfull;
  //     ARREADY_M1_o = 1'd0; 
  //   end
  // end

  //AXI
  assign ARVALID_M = ~AR_rempty;
  always_comb begin
    ARID_M    = AR_rdata[`ARFIFO_ID_BITS];
    ARADDR_M  = AR_rdata[`ARFIFO_ADDR_BITS];
    ARLEN_M   = AR_rdata[`ARFIFO_LEN_BITS];
    ARSIZE_M  = AR_rdata[`ARFIFO_SIZE_BITS];
    ARBURST_M = AR_rdata[`ARFIFO_BURST_BITS];
  end

  //----------------------- R  FIFO -------------------------
  // in
  assign R_wpush = RVALID_M;
  assign R_wdata = {RID_M, RDATA_M, RLAST_M};
  always_comb begin
    if(R_rempty) R_rpop = 1'd0;
    else case (master_sel)
      2'd0:    R_rpop = RREADY_M0_i;
      2'd1:    R_rpop = RREADY_M1_i;
      2'd2:    R_rpop = RREADY_M2_i; 
      default: R_rpop = RREADY_M0_i;
    endcase
  end
  // assign R_rpop  = (R_rempty) ? 1'd0 :
	// 								 (master_sel) ? RREADY_M1_i : RREADY_M0_i;
  
  async_fifo #(
    .FIFO_DATASIZE(`RFIFO_DATASIZE)
  ) rfifo_m (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (R_wpush),
    .wdata (R_wdata), 
    .wfull (R_wfull),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst),
    .rpop  (R_rpop),
    .rdata (R_rdata),
    .rempty(R_rempty)
  );

  // out
  //AXI
	assign RREADY_M = R_wfull;

  //cpu
  // always_comb begin
  //   if(master_sel) begin
  //     RVALID_M0_o = 1'd0;
  //     RVALID_M1_o = ~R_rempty;
  //   end
  //   else begin
  //     RVALID_M0_o = ~R_rempty;
  //     RVALID_M1_o = 1'd0;
  //   end
  // end
  assign RVALID_M0_o = (master_sel == 2'd0) ? ~R_rempty : 1'd0;
  assign RVALID_M1_o = (master_sel == 2'd1) ? ~R_rempty : 1'd0;
  assign RVALID_M2_o = (master_sel == 2'd2) ? ~R_rempty : 1'd0;

  always_comb begin
    if(master_sel == 2'd1) begin
      RID_M0_o   = 4'd0;
      RDATA_M0_o = 32'd0;
      RLAST_M0_o = 1'd0;

      RID_M1_o   = R_rdata[`RFIFO_ID_BITS];
      RDATA_M1_o = R_rdata[`RFIFO_DATA_BITS];
      RLAST_M1_o = R_rdata[`RFIFO_LAST_BITS];

      RID_M2_o   = 4'd0;
      RDATA_M2_o = 32'd0;
      RLAST_M2_o = 1'd0;
    end
    else if(master_sel == 2'd2) begin
      RID_M0_o   = 4'd0;
      RDATA_M0_o = 32'd0;
      RLAST_M0_o = 1'd0;

      RID_M1_o   = 4'd0;
      RDATA_M1_o = 32'd0;
      RLAST_M1_o = 1'd0;

      RID_M2_o   = R_rdata[`RFIFO_ID_BITS];
      RDATA_M2_o = R_rdata[`RFIFO_DATA_BITS];
      RLAST_M2_o = R_rdata[`RFIFO_LAST_BITS];
    end
    else begin
      RID_M0_o   = R_rdata[`RFIFO_ID_BITS];
      RDATA_M0_o = R_rdata[`RFIFO_DATA_BITS];
      RLAST_M0_o = R_rdata[`RFIFO_LAST_BITS];

      RID_M1_o   = 4'd0;
      RDATA_M1_o = 32'd0;
      RLAST_M1_o = 1'd0;

      RID_M2_o   = 4'd0;
      RDATA_M2_o = 32'd0;
      RLAST_M2_o = 1'd0;
    end
  end

  //----------------------- AW FIFO -------------------------
  assign master_sel_write = (AWVALID_M2_i | WVALID_M2_i | BREADY_M2_i);

  assign AW_wpush = (master_sel_write) ? AWVALID_M2_i : AWVALID_M1_i;
  assign AW_rpop  = AWREADY_M;
  assign AW_wdata = (master_sel_write) ? {AWID_M2_i, AWADDR_M2_i, AWLEN_M2_i, AWSIZE_M2_i, AWBURST_M2_i} :
                                         {AWID_M1_i, AWADDR_M1_i, AWLEN_M1_i, AWSIZE_M1_i, AWBURST_M1_i};

  async_fifo #(
    .FIFO_DATASIZE(`AWFIFO_DATASIZE)
  ) awfifo_m (
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (AW_wpush),
    .wdata (AW_wdata), 
    .wfull (AW_wfull),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (AW_rpop),
    .rdata (AW_rdata),
    .rempty(AW_rempty)
  );

  // out 
  //axi
  assign AWVALID_M = ~AW_rempty;
  always_comb begin
    AWID_M    = AW_rdata[`AWFIFO_ID_BITS];
    AWADDR_M  = AW_rdata[`AWFIFO_ADDR_BITS];
    AWLEN_M   = AW_rdata[`AWFIFO_LEN_BITS];
    AWSIZE_M  = AW_rdata[`AWFIFO_SIZE_BITS];
    AWBURST_M = AW_rdata[`AWFIFO_BURST_BITS];
  end

  //cpu
  assign AWREADY_M1_o = (master_sel_write == 1'd0) ? AW_wfull : 1'd0;
  assign AWREADY_M2_o = (master_sel_write == 1'd1) ? AW_wfull : 1'd0;

  //----------------------- W  FIFO -------------------------
  assign W_wpush = (W_wfull) ? 1'd0 : (master_sel_write) ? WVALID_M2_i : WVALID_M1_i;
  assign W_rpop  = WREADY_M & ~W_rempty;
  assign W_wdata = (master_sel_write) ? {WDATA_M2_i, WSTRB_M2_i, WLAST_M2_i}:
                                        {WDATA_M1_i, WSTRB_M1_i, 1'd1}; 

  async_fifo #(
    .FIFO_DATASIZE(`WFIFO_DATASIZE)
  ) wfifo_m(
    .wclk  (cpu_clk),
    .wrst  (cpu_rst),
    .wpush (W_wpush),
    .wdata (W_wdata), 
    .wfull (W_wfull),
    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (W_rpop),
    .rdata (W_rdata),
    .rempty(W_rempty)
  );

  //out 
  //axi
  assign WVALID_M = ~W_rempty;
  always_comb begin
    WDATA_M = W_rdata[`WFIFO_DATA_BITS];
    WSTRB_M = W_rdata[`WFIFO_WSTRB_BITS];
    WLAST_M = W_rdata[`WFIFO_WLAST_BITS];
  end

  //cpu
  assign WREADY_M1_o = (master_sel_write == 1'd0) ? W_wfull : 1'd0;
  assign WREADY_M2_o = (master_sel_write == 1'd1) ? W_wfull : 1'd0;

  //----------------------- B  FIFO -------------------------
  assign B_wpush = BVALID_M;
  assign B_wdata = {BID_M, BRESP_M};
  assign B_rpop = (B_rempty) ? 1'd0 : 
                  (master_sel_write) ? BREADY_M2_i : BREADY_M1_i;

  async_fifo #(
    .FIFO_DATASIZE(`BFIFO_DATASIZE)
  ) bfifo_m (
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (B_wpush),
    .wdata (B_wdata), 
    .wfull (B_wfull),
    .rclk  (cpu_clk),
    .rrst  (cpu_rst),
    .rpop  (B_rpop),
    .rdata (B_rdata),
    .rempty(B_rempty)
  );

  // out 
  //cpu
  assign BVALID_M1_o = (master_sel_write == 1'd0) ? ~B_rempty : 1'd0;
  assign BVALID_M2_o = (master_sel_write == 1'd1) ? ~B_rempty : 1'd0; 

  assign BID_M1_o    = (master_sel_write == 1'd0) ? B_rdata[`BFIFO_ID_BITS] : 4'd0;
  assign BRESP_M1_o  = (master_sel_write == 1'd1) ? B_rdata[`BFIFO_RESP_BITS] : 2'd0;
  assign BID_M2_o    = (master_sel_write == 1'd0) ? B_rdata[`BFIFO_ID_BITS] : 4'd0;
  assign BRESP_M2_o  = (master_sel_write == 1'd1) ? B_rdata[`BFIFO_RESP_BITS] : 2'd0;

  //axi
  assign BREADY_M = B_wfull;  

  
endmodule
