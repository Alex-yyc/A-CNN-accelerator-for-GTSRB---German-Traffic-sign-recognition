//================================================
// Auther:      N26111512           
// Filename:    CPU_Data.sv                            
// Description: Master 1 (DATA)                
// Version:     2 (HW3 change BurstLeng_W)
//================================================
module CPU_Data (
  input ACLK,
  input ARESETn,

  //CPU
  input DM_OE,
  input DATA_stall,
  input [3:0] DM_WEB,
  input [`InstAddrBus] DM_addr,
  input [`RegBus] DM_DI,
  output logic [`RegBus] DM_data,
  output logic DATA_DONE,

  //==============DATA READ=================
	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1,

  //==============DATA WRITE=================
  //WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1
);

	//burst
  parameter BurstLeng_R = 8'd0;   //1 
  parameter BurstSize_R = 3'b010; //4 WORD; 
  parameter BurstLeng_W = 8'd1;   //4
  parameter BurstSize_W = 3'b010; //1 WORD;
  parameter BurstType   = 2'd1;   //INCR 
  //FSM
  parameter IDLE       = 3'd0;
  parameter READ_ADDR  = 3'd1;
  parameter READ_WAIT  = 3'd6;
  parameter READ_DATA  = 3'd2;
  parameter WRITE_ADDR = 3'd3;
  parameter WRITE_DATA = 3'd4;
  // parameter WRITE_WAIT = 3'd7;
  parameter WRITE_DONE = 3'd5;

  logic [2:0] state, next_state;
  logic [7:0] burst_cnt;
  //reg
  logic [`InstAddrBus] DM_addr_reg;
  logic [`RegBus] DM_DI_reg, DM_data_reg;
  logic [3:0] WEB_reg;
 
  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
        DM_addr_reg <= 32'd0;
        DM_DI_reg   <= 32'd0;
	      DM_data_reg <= 32'd0;
        WEB_reg     <= 4'b1111;
      end else begin
        unique case (state)
          IDLE: begin
            DM_addr_reg <= DM_addr;
            DM_DI_reg   <= DM_DI;
	          DM_data_reg <= DM_data_reg;
						case(DM_WEB)
						~`AXI_STRB_BYTE: begin
							unique case (DM_addr[1:0])
		            2'b00:   WEB_reg <= 4'b1110;
		            2'b01:   WEB_reg <= 4'b1101;
		            2'b10:   WEB_reg <= 4'b1011;
		            2'b11:   WEB_reg <= 4'b0111;
		          endcase
						end
						~`AXI_STRB_HWORD: begin
							unique case (DM_addr[1:0])
		            2'b00, 2'b01: WEB_reg <= 4'b1100;
		            2'b10, 2'b11: WEB_reg <= 4'b0011;
							endcase
						end
						~`AXI_STRB_WORD: WEB_reg <= DM_WEB;
            default:         WEB_reg <= 4'b1111;
						endcase
          end
          READ_DATA: begin
            DM_addr_reg <= DM_addr_reg;
            DM_DI_reg   <= DM_DI_reg;
	          DM_data_reg <= RDATA_M1;
            WEB_reg     <= WEB_reg;
          end
          WRITE_DATA: begin
            DM_addr_reg <= DM_addr_reg;
            DM_DI_reg   <= DM_DI_reg;
	          DM_data_reg <= DM_data_reg;
            WEB_reg     <= WEB_reg;
          end
          default: begin
            DM_addr_reg <= DM_addr_reg;
            DM_DI_reg   <= DM_DI_reg;
	          DM_data_reg <= DM_data_reg;
            WEB_reg     <= WEB_reg;
          end
        endcase
      end
    end
    
    //FSM
    always_ff @( posedge ACLK or negedge ARESETn) begin
      if( !ARESETn ) state <= IDLE;
      else           state <= next_state;
    end

    always_comb begin 
      unique case (state)
        IDLE:       next_state = (DATA_stall) ? IDLE :
                                 (DM_OE) ? READ_ADDR :   // READ
                                 (DM_WEB != `MEM_NOWRITE) ? WRITE_ADDR : IDLE;  //WRITE
        READ_ADDR:  next_state = (ARREADY_M1) ? READ_DATA  : READ_ADDR;
	      //READ_WAIT:  next_state = READ_DATA;   //resolve cover 
        READ_DATA:  next_state = (RVALID_M1) ? IDLE       : READ_DATA;  // && RLAST_M1
        WRITE_ADDR: next_state = (AWREADY_M1) ? WRITE_DATA : WRITE_ADDR;
        WRITE_DATA: next_state = (WREADY_M1 && WLAST_M1) ? WRITE_DONE : WRITE_DATA;
	      // WRITE_WAIT: next_state = WRITE_DONE;   //resolve cover but RTL1,3 FAIL
        WRITE_DONE: next_state = (BVALID_M1)  ? IDLE       : WRITE_DONE;
        default:    next_state = IDLE;
      endcase
    end

    // burst counter
    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
        burst_cnt <= 4'd0;
      end else begin
        case (state)
          WRITE_DATA: burst_cnt <= (WREADY_M1) ? burst_cnt + 4'd1 : burst_cnt;
          default:    burst_cnt <= 4'd0;
        endcase
      end
    end

    //====================signal to AXI=====================
    always_comb begin 
      unique case (state)
        IDLE: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;
          AWBURST_M1 = 2'd0;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd0;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = 32'd0;
          ARLEN_M1   = 8'd0;
          ARSIZE_M1  = 3'd0;
          ARBURST_M1 = 2'd0;
          ARVALID_M1 = 1'd0;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
        READ_ADDR: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;
          AWBURST_M1 = 2'd0;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd0;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = DM_addr_reg;
          ARLEN_M1   = BurstLeng_R;
          ARSIZE_M1  = BurstSize_R;  
          ARBURST_M1 = BurstType; 
          ARVALID_M1 = 1'd1;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
        READ_DATA: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;
          AWBURST_M1 = 2'd0;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd0;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = DM_addr_reg;
          ARLEN_M1   = BurstLeng_R;
          ARSIZE_M1  = BurstSize_R;  
          ARBURST_M1 = BurstType; 
          ARVALID_M1 = 1'd1;
          //READ DATA1
          RREADY_M1  = 1'd1;
        end
        WRITE_ADDR: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = DM_addr_reg;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;  
          AWBURST_M1 = BurstType; 
          AWVALID_M1 = 1'd1;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd0;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = 32'd0;
          ARLEN_M1   = 8'd0;
          ARSIZE_M1  = 3'd0;
          ARBURST_M1 = 2'd0;
          ARVALID_M1 = 1'd0;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
        WRITE_DATA: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = BurstLeng_W;
          AWSIZE_M1  = BurstSize_W;
          AWBURST_M1 = BurstType;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = DM_DI_reg;
          WSTRB_M1   = WEB_reg;
          WLAST_M1   = (burst_cnt == BurstLeng_W) ? 1'd1 : 1'd0;
          WVALID_M1  = 1'd1;
          //WRITE RESPONSE
          BREADY_M1 = 1'd1;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = 32'd0;
          ARLEN_M1   = 8'd0;
          ARSIZE_M1  = 3'd0;
          ARBURST_M1 = 2'd0;
          ARVALID_M1 = 1'd0;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
	      // WRITE_WAIT: begin
        //   //WRITE ADDRESS
        //   AWID_M1    = 4'd0;
        //   AWADDR_M1  = 32'd0;
        //   AWLEN_M1   = 4'd0;
        //   AWSIZE_M1  = 3'd0;
        //   AWBURST_M1 = 2'd0;
        //   AWVALID_M1 = 1'd0;
        //   //WRITE DATA
        //   WDATA_M1   = DM_DI_reg;
        //   WSTRB_M1   = DM_WEB;
        //   WLAST_M1   = 1'd0;
        //   WVALID_M1  = 1'd1;
        //   //WRITE RESPONSE
        //   BREADY_M1 = 1'd0;
        //   //READ ADDRESS1
        //   ARID_M1 = 4'd0;
        //   ARADDR_M1 = 32'd0;
        //   ARLEN_M1 = 4'd0;
        //   ARSIZE_M1 = 3'd0;
        //   ARBURST_M1 = 2'd0;
        //   ARVALID_M1 = 1'd0;
        //   //READ DATA1
        //   RREADY_M1 = 1'd0;
        // end
        WRITE_DONE: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;
          AWBURST_M1 = 2'd0;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd1;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = 32'd0;
          ARLEN_M1   = 8'd0;
          ARSIZE_M1  = 3'd0;
          ARBURST_M1 = 2'd0;
          ARVALID_M1 = 1'd0;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
        default: begin
          //WRITE ADDRESS
          AWID_M1    = 4'd0;
          AWADDR_M1  = 32'd0;
          AWLEN_M1   = 8'd0;
          AWSIZE_M1  = 3'd0;
          AWBURST_M1 = 2'd0;
          AWVALID_M1 = 1'd0;
          //WRITE DATA
          WDATA_M1   = 32'd0;
          WSTRB_M1   = 4'd0;
          WLAST_M1   = 1'd0;
          WVALID_M1  = 1'd0;
          //WRITE RESPONSE
          BREADY_M1  = 1'd0;
          //READ ADDRESS1
          ARID_M1    = 4'd0;
          ARADDR_M1  = 32'd0;
          ARLEN_M1   = 8'd0;
          ARSIZE_M1  = 3'd0;
          ARBURST_M1 = 2'd0;
          ARVALID_M1 = 1'd0;
          //READ DATA1
          RREADY_M1  = 1'd0;
        end
      endcase
    end

    //====================signal to CPU=====================
    always_comb begin
      unique case (state)
        READ_DATA: begin
          DATA_DONE = (RVALID_M1) ? 1'b1 : 1'b0;
          DM_data   = RDATA_M1;
        end
        WRITE_DONE: begin
          DATA_DONE = (BVALID_M1) ? 1'b1 : 1'b0;
          DM_data   = 32'd0;
        end
        default: begin
          DATA_DONE	= 1'd0;
          DM_data   = DM_data_reg;
        end
      endcase
    end
endmodule
