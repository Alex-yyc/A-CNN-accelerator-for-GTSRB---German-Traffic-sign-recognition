//*********************************************************
// Auther:      N26111512                                      
// Description: sensor control Wrapper (S3)                 
// Version:     2 (WDATA_reg)
//*********************************************************
`include "sensor_ctrl.sv"  

module SCtrl_wrapper (
  input ACLK, 
  input ARESETn,

  // to cpu //
  //sensor control
  input sensor_ready,
  input [`DataBus-1:0] sensor_out,
  output logic sensor_en,
  output logic sctrl_interrupt,

  // to AXI //
  //WRITE ADDRESS
  input [`AXI_IDS_BITS-1:0]AWID,
  input [`AXI_ADDR_BITS-1:0]AWADDR,
  input [`AXI_LEN_BITS-1:0] AWLEN,
  input [`AXI_SIZE_BITS-1:0] AWSIZE,
  input [1:0] AWBURST,
  input AWVALID,
  output logic AWREADY,
  //WRITE DATA
  input [`AXI_DATA_BITS-1:0] WDATA,
  input [`AXI_STRB_BITS-1:0] WSTRB,
  input WLAST,
  input WVALID,
  output logic WREADY,
  //WRITE RESPONSE0
  output logic [`AXI_IDS_BITS-1:0] BID,
  output logic [1:0] BRESP,
  output logic BVALID,
  input BREADY,
  //READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
  //READ DATA
  input RREADY,
 	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID

);

  parameter IDLE       = 3'd0;
  parameter READ_ADDR  = 3'd1;
  parameter READ_DATA  = 3'd2;
  parameter WRITE_ADDR = 3'd3;
  parameter WRITE_DATA = 3'd4;
  parameter WRITE_DONE = 3'd5;

  logic [`AXI_IDS_BITS-1:0] AWID_reg, ARID_reg;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_reg, ARADDR_reg;
  logic [`AXI_DATA_BITS-1:0] WDATA_reg;

  logic [3:0] burst_cnt;
  logic [2:0] state, next_state;

  logic sctrl_en, sctrl_clear;
  logic [5:0] sctrl_addr;
  logic [`DataBus-1:0] sctrl_out;

  
  sensor_ctrl sctrl(
    .clk(ACLK),
    .rst(~ARESETn), 

    .sctrl_en(sctrl_en),           //0x1000_0100
    .sctrl_clear(sctrl_clear),     //0x1000_0200
    .sctrl_addr(sctrl_addr),       // to sensor
    // Sensor inputs
    .sensor_ready(sensor_ready),   //tb in
    .sensor_out(sensor_out),       //tb in 
    // Core outputs
    .sctrl_interrupt(sctrl_interrupt), //sensor out
    .sctrl_out(sctrl_out),             //sensor out
    // Sensor outputs
    .sensor_en(sensor_en)          // in tb
  );

  //================= to SCrtl ==================
  // addr
  always_comb begin
    unique case (state)
      READ_DATA: sctrl_addr = ARADDR_reg[7:2];
      default:   sctrl_addr = 6'd0;
    endcase
  end
  // sctrl_en
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) sctrl_en <= 1'd0; 
    else if ((AWADDR_reg == 32'h1000_0100) /*&& (WDATA_reg != 32'd0) */) sctrl_en <= 1'd1;
    //else sctrl_en = 1'd0;
  end
  // sctrl_clear
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) sctrl_clear <= 1'd0;
    else if ((AWADDR_reg == 32'h1000_0200) && (WDATA_reg != 32'd0)) sctrl_clear <= 1'd1;
    else sctrl_clear <= 1'd0;
  end

  //================== FSM ==================
  always_ff @( posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) state <= IDLE;
    else         state <= next_state;
  end
	
/* HW3
  always_comb begin 
    unique case (state)
      IDLE:       next_state = (ARVALID) ? READ_ADDR  :            //READ
                               (AWVALID) ? WRITE_ADDR : IDLE;      //WRITE
      READ_ADDR:  next_state = READ_DATA;
      READ_DATA:  next_state = (RREADY && RLAST)  ? IDLE       : READ_DATA;
      WRITE_ADDR: next_state = WRITE_DATA;
      WRITE_DATA: next_state = (WVALID && WLAST)  ? WRITE_DONE : WRITE_DATA;
      WRITE_DONE: next_state = (BREADY)  ? IDLE       : WRITE_DONE;
      default:    next_state = IDLE;
    endcase
  end
*/

  always_comb begin 
    unique case (state)
      IDLE:       next_state = (ARVALID) ? READ_DATA  :            //READ
                               (AWVALID) ? WRITE_DATA : IDLE;      //WRITE
      // READ_ADDR:  next_state = READ_DATA;
      READ_DATA:  next_state = (RREADY && RLAST)  ? IDLE       : READ_DATA;
      // WRITE_ADDR: next_state = WRITE_DATA;
      WRITE_DATA: next_state = (WVALID && WLAST)  ? WRITE_DONE : WRITE_DATA;
      WRITE_DONE: next_state = (BREADY)  ? IDLE       : WRITE_DONE;
      default:    next_state = IDLE;
    endcase
  end

  //================== reg ==================
  // data reg
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      AWID_reg   <= 8'd0;
      AWADDR_reg <= 32'd0;
      ARID_reg   <= 8'd0;
      ARADDR_reg <= 32'd0;
      WDATA_reg  <= 32'd0;
    end else begin
      case (state)
				IDLE: begin
					if(ARVALID) begin 
		        AWID_reg   <= AWID_reg;
		        AWADDR_reg <= AWADDR_reg;
		        ARID_reg   <= ARID;         //
		        ARADDR_reg <= ARADDR;       //
		        WDATA_reg  <= WDATA_reg;
					end
					else if(AWVALID) begin 
		        AWID_reg   <= AWID;         //
		        AWADDR_reg <= AWADDR;       //
		        ARID_reg   <= ARID_reg;
		        ARADDR_reg <= ARADDR_reg;
		        WDATA_reg  <= WDATA_reg;
					end else begin
		        AWID_reg   <= AWID_reg;
		        AWADDR_reg <= AWADDR_reg;
		        ARID_reg   <= ARID_reg;
		        ARADDR_reg <= ARADDR_reg;
		        WDATA_reg  <= WDATA_reg;
					end
				end
        WRITE_DATA: begin
          AWID_reg   <= AWID_reg;
          AWADDR_reg <= AWADDR_reg;
          ARID_reg   <= ARID_reg;
          ARADDR_reg <= ARADDR_reg;
          WDATA_reg  <= WDATA;        //
        end
        default: begin
          AWID_reg   <= AWID_reg;
          AWADDR_reg <= AWADDR_reg;
          ARID_reg   <= ARID_reg;
          ARADDR_reg <= ARADDR_reg;
          WDATA_reg  <= WDATA_reg;
        end
      endcase
    end
  end

  //====================signal to AXI=====================

/* HW3
  always_comb begin
    unique case (state)
      IDLE: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      READ_ADDR: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd1;  // 
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      READ_DATA: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;  
        //READ DATA
        RID = ARID_reg;
        RDATA = sctrl_out;
        RRESP = 2'd0;
        RLAST = 1'd1; 
        RVALID = 1'd1; 
      end
      WRITE_ADDR: begin
        //WRITE ADDRESS
        AWREADY = 1'd1;  //
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      WRITE_DATA: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd1;  //
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      WRITE_DONE: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = AWID_reg;
        BRESP = 2'd0;
        BVALID = 1'd1;   //
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      default: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
    endcase
  end
*/


  always_comb begin
    unique case (state)
      IDLE: begin
        if(ARVALID)begin
        //WRITE ADDRESS
            AWREADY = 1'd0;
            //WRITE DATA
            WREADY = 1'd0;
            //WRITE RESPONSE0
            BID = 8'd0;
            BRESP = 2'd0;
            BVALID = 1'd0;
            //READ ADDRESS
            ARREADY = 1'd1;  // 
            //READ DATA
            RID = 8'd0;
            RDATA = 32'd0;
            RRESP = 2'd0;
            RLAST = 1'd0;
            RVALID = 1'd0;
      end
      else if(AWVALID)begin
        //WRITE ADDRESS
            AWREADY = 1'd1;  //
            //WRITE DATA
            WREADY = 1'd0;
            //WRITE RESPONSE0
            BID = 8'd0;
            BRESP = 2'd0;
            BVALID = 1'd0;
            //READ ADDRESS
            ARREADY = 1'd0;
            //READ DATA
            RID = 8'd0;
            RDATA = 32'd0;
            RRESP = 2'd0;
            RLAST = 1'd0;
            RVALID = 1'd0;
      end
      else begin
        //WRITE ADDRESS
            AWREADY = 1'd0;
            //WRITE DATA
            WREADY = 1'd0;
            //WRITE RESPONSE0
            BID = 8'd0;
            BRESP = 2'd0;
            BVALID = 1'd0;
            //READ ADDRESS
            ARREADY = 1'd0;
            //READ DATA
            RID = 8'd0;
            RDATA = 32'd0;
            RRESP = 2'd0;
            RLAST = 1'd0;
            RVALID = 1'd0;
      end
      end
      READ_DATA: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd1;  // 
        //READ DATA
        RID = ARID_reg;
        RDATA = sctrl_out;
        RRESP = 2'd0;
        RLAST = 1'd1;//
        RVALID = 1'd1; //
      end
      WRITE_DATA: begin
        //WRITE ADDRESS
        AWREADY = 1'd1; //
        //WRITE DATA
        WREADY = 1'd1;  //
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      WRITE_DONE: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = AWID_reg;
        BRESP = 2'd0;
        BVALID = 1'd1;   //
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
      default: begin
        //WRITE ADDRESS
        AWREADY = 1'd0;
        //WRITE DATA
        WREADY = 1'd0;
        //WRITE RESPONSE0
        BID = 8'd0;
        BRESP = 2'd0;
        BVALID = 1'd0;
        //READ ADDRESS
        ARREADY = 1'd0;
        //READ DATA
        RID = 8'd0;
        RDATA = 32'd0;
        RRESP = 2'd0;
        RLAST = 1'd0;
        RVALID = 1'd0;
      end
    endcase
  end

endmodule

