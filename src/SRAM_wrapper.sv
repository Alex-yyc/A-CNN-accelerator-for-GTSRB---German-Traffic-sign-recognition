//================================================
// Auther:      N26111512           
// Filename:    SRAM_wrapper.sv                            
// Description: Top module of SRAM wrapper                 
// Version:     4 [FINAL]
//================================================
`include "../include/AXI_define.svh"
`include "../include/define.svh"
module SRAM_wrapper (
  input ACLK,
  input ARESETn,

  //WRITE ADDRESS
  input [`AXI_IDS_BITS-1:0] AWID,
  input [`AXI_ADDR_BITS-1:0] AWADDR,
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
  // parameter READ_ADDR  = 3'd1;
  parameter READ_DATA  = 3'd2;
  // parameter READ_DONE  = 3'd3;
  // parameter WRITE_ADDR = 3'd4;
  parameter WRITE_DATA = 3'd5;
  parameter WRITE_DONE = 3'd6;

  logic CS;
  logic OE;
  logic [3:0] WEB;
  logic [13:0] A;
  logic [31:0] DI;
  logic [31:0] DO;
	
	logic WVALID_reg;
  logic [`AXI_IDS_BITS-1:0] AWID_reg, ARID_reg;
  logic [`AXI_ADDR_BITS-1:0] AWADDR_reg, ARADDR_reg;
  logic [`AXI_LEN_BITS-1:0] LEN_reg, burst_cnt;

  logic [2:0] state, next_state;

  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (ACLK  ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

  //================== reg ==================
  // data reg
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      AWID_reg   <= 8'd0;
      AWADDR_reg <= 32'd0;
      ARID_reg   <= 8'd0;
      ARADDR_reg <= 32'd0;
      LEN_reg    <= 8'd0;
    end else begin
      case (state)
        IDLE : begin
          if(ARVALID)begin
                AWID_reg   <= AWID_reg;
                AWADDR_reg <= AWADDR_reg;
                ARID_reg   <= ARID;         //
                ARADDR_reg <= ARADDR;       //
                LEN_reg    <= ARLEN;        //
          end
          else if(AWVALID)begin
                AWID_reg   <= AWID;         //
                AWADDR_reg <= AWADDR;       //
                ARID_reg   <= ARID_reg;
                ARADDR_reg <= ARADDR_reg;
                LEN_reg    <= AWLEN;        //
          end
          else begin
                AWID_reg   <= AWID_reg;
                AWADDR_reg <= AWADDR_reg;
                ARID_reg   <= ARID_reg;
                ARADDR_reg <= ARADDR_reg;
                LEN_reg    <= LEN_reg;
          end
		    end
		    // READ_ADDR: begin
          // AWID_reg   <= AWID_reg;
          // AWADDR_reg <= AWADDR_reg;
          // ARID_reg   <= ARID;         //
          // ARADDR_reg <= ARADDR;       //
          // LEN_reg    <= ARLEN;        //
        // end
        READ_DATA: begin
          AWID_reg   <= AWID_reg;
          AWADDR_reg <= AWADDR_reg;
          ARID_reg   <= ARID_reg;
          ARADDR_reg <= ARADDR_reg;
          LEN_reg    <= LEN_reg;
        end 
        WRITE_DATA: begin
          AWID_reg   <= AWID_reg;         //
          AWADDR_reg <= (WVALID & ~WVALID_reg) ? (AWADDR_reg + 32'd4) : AWADDR_reg;       //
          ARID_reg   <= ARID_reg;
          ARADDR_reg <= ARADDR_reg;
          LEN_reg    <= AWLEN;        //
        end
        default: begin
          AWID_reg   <= AWID_reg;
          AWADDR_reg <= AWADDR_reg;
          ARID_reg   <= ARID_reg;
          ARADDR_reg <= ARADDR_reg;
          LEN_reg    <= LEN_reg;
        end
      endcase
    end
  end

  // burst counter
  // always_ff @(posedge ACLK or negedge ARESETn) begin
    // if (!ARESETn)   burst_cnt <= 4'd0;
    // else begin
      // case (state)
        // READ_DATA:  burst_cnt <= (RVALID) ? burst_cnt + 4'd1 : burst_cnt;
        // WRITE_DATA: burst_cnt <= (WVALID) ? burst_cnt + 4'd1 : burst_cnt;
        // default:    burst_cnt <= 4'd0;
      // endcase
    // end
  // end
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      burst_cnt <= `AXI_LEN_BITS'd0;
      WVALID_reg <= 1'd0;
    end  
    else begin
      case (state)
        READ_DATA: burst_cnt <= (RVALID) ? burst_cnt + `AXI_LEN_BITS'd1 : burst_cnt;
        WRITE_DATA: begin
          if(WVALID) begin
            burst_cnt <= (!WVALID_reg) ? burst_cnt + `AXI_LEN_BITS'd1 : burst_cnt;
            WVALID_reg <= WVALID;
          end
					else begin
						burst_cnt <= burst_cnt;
						WVALID_reg <= 1'd0;
					end
        end 
        default: begin
          burst_cnt <= `AXI_LEN_BITS'd0;
          WVALID_reg <= 1'd0;
        end  
      endcase
    end
  end

  // FSM
  always_ff @( posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) state <= IDLE;
    else         state <= next_state;
  end

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

  //====================signal to AXI=====================
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
        //WRITE ADDRESS
        // AWREADY = 1'd0;
        //WRITE DATA
        // WREADY = 1'd0;
        //WRITE RESPONSE0
        // BID = 8'd0;
        // BRESP = 2'd0;
        // BVALID = 1'd0;
        //READ ADDRESS
        // ARREADY = 1'd0;
        //READ DATA
        // RID = 8'd0;
        // RDATA = 32'd0;
        // RRESP = 2'd0;
        // RLAST = 1'd0;
        // RVALID = 1'd0;
      end
      // READ_ADDR: begin
        //WRITE ADDRESS
        // AWREADY = 1'd0;
        //WRITE DATA
        // WREADY = 1'd0;
        //WRITE RESPONSE0
        // BID = 8'd0;
        // BRESP = 2'd0;
        // BVALID = 1'd0;
        //READ ADDRESS
        // ARREADY = 1'd1;  // 
        //READ DATA
        // RID = 8'd0;
        // RDATA = 32'd0;
        // RRESP = 2'd0;
        // RLAST = 1'd0;
        // RVALID = 1'd0;
      // end
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
        RDATA = DO;//(RREADY) ? DO : DO_reg; // (LEN_reg != 4'd0) ? DO : 32'd0;//vip pass but rtl fail
        RRESP = 2'd0;
        RLAST = (LEN_reg == `AXI_LEN_BITS'd0 || burst_cnt == LEN_reg) ? 1'd1 : 1'd0;//
        RVALID = (LEN_reg == `AXI_LEN_BITS'd0 || burst_cnt == LEN_reg) ? 1'd1 : 1'd0; //
      end
      // WRITE_ADDR: begin
        // WRITE ADDRESS
        // AWREADY = 1'd1;  //
        // WRITE DATA
        // WREADY = 1'd0;
        // WRITE RESPONSE0
        // BID = 8'd0;
        // BRESP = 2'd0;
        // BVALID = 1'd0;
        // READ ADDRESS
        // ARREADY = 1'd0;
        // READ DATA
        // RID = 8'd0;
        // RDATA = 32'd0;
        // RRESP = 2'd0;
        // RLAST = 1'd0;
        // RVALID = 1'd0;
      // end
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

  //====================to SRAM=====================
  assign CS = 1'd1;

  always_comb begin
    unique case (state)
      IDLE : begin
	    if(ARVALID)begin
		  OE = 1'd1;
          WEB = `MEM_NOWRITE;
          A = ARADDR[15:2];
          DI = 32'd0;
		end
		else if(AWVALID)begin
		  OE = 1'd0;
          WEB = `MEM_NOWRITE;
          A = 14'd0;
          DI = 32'd0;
		end
		else begin
		  OE = 1'd0;
          WEB = `MEM_NOWRITE;
          A = 14'd0;
          DI = 32'd0;
		end
	  end
	  // READ_ADDR: begin
        // OE = 1'd1;
        // WEB = `MEM_NOWRITE;
        // A = ARADDR[15:2];
        // DI = 32'd0;
      // end
      READ_DATA: begin
        OE = 1'd1;
        WEB = `MEM_NOWRITE;
        A = ARADDR_reg[15:2];
        DI = 32'd0;
      end
      // WRITE_ADDR: begin
        // OE = 1'd0;
        // WEB = `MEM_NOWRITE;
        // A = 14'd0;
        // DI = 32'd0;
      // end
      WRITE_DATA: begin
        OE = 1'd0;
        // WEB = `MEM_WRITE;
        A = AWADDR_reg[15:2];
        // A = (AWADDR_reg[15:2] + (burst_cnt)); // burst_cnt - `AXI_LEN_BITS'd1
        DI = WDATA;
        WEB = WSTRB;
        /*
        unique case (burst_cnt)
          4'd0:    WEB = 4'b1110;
          4'd1:    WEB = 4'b1101;
          4'd2:    WEB = 4'b1011;
          4'd3:    WEB = 4'b0111;
          default: WEB = `MEM_NOWRITE;
        endcase
        */
      end
      WRITE_DONE: begin
        OE = 1'd0;
        WEB = `MEM_NOWRITE;
        A = 14'd0;
        DI = 32'd0;
      end
      default: begin
        OE = 1'd0;
        WEB = `MEM_NOWRITE;
        A = 14'd0;
        DI = 32'd0;
      end
    endcase
  end

endmodule
