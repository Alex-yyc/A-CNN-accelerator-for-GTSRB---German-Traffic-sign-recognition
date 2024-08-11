//================================================
// Auther:      N26111512           
// Filename:    CPU_Inst.sv                            
// Description: Master 0 (INST) - READ ONLY           
// Version:     2 (HW3 for reduce cycle)
//================================================
module CPU_Inst (
  input ACLK,
	input ARESETn,

  //CPU
  input IM_OE,
  input [`InstAddrBus] IM_addr,
  output logic [`InstBus] IM_data,
  input INST_stall,
  output logic INST_done,

  //READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,   
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0, 
 	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
  //READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0

);
  //burst
  parameter BurstLeng_R = 8'd0;   //1 
  parameter BurstSize_R = 3'b010; //4 WORD;
  parameter BurstType   = 2'd1;   //INCR 
  //FSM
  parameter IDLE      = 2'd0;
  parameter READ_ADDR = 2'd1;
  parameter READ_DATA = 2'd2;
  parameter READ_WAIT = 2'd3;
  //parameter SAVE_DATA = 2'd3;  // for IM_data reg
  logic [1:0] state, next_state;
  //reg
	logic [`InstAddrBus] IM_addr_reg;
  logic [`InstBus] IM_data_reg;


  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
    always_ff @(posedge ACLK or negedge ARESETn) begin
		if(!ARESETn) begin
			IM_addr_reg <= 32'd0;
      IM_data_reg <= 32'd0;
    end else 
      unique case (state) 
      IDLE: begin
        IM_addr_reg <= IM_addr;
        IM_data_reg <= IM_data_reg;
      end		
      READ_DATA: begin
        IM_addr_reg <= IM_addr_reg;
        IM_data_reg <= RDATA_M0;
      end
      default: begin
        IM_addr_reg <= IM_addr_reg;
        IM_data_reg <= IM_data_reg;
      end
      endcase 
    end
	
    //FSM
    always_ff @( posedge ACLK or negedge ARESETn) begin
      if(!ARESETn) state <= IDLE;
      else         state <= next_state;
    end

    /* HW2
    always_comb begin
      unique case (state)
        IDLE:      next_state = (IM_OE && !INST_stall) ? READ_ADDR : IDLE;
        READ_ADDR: next_state = (ARREADY_M0) ? READ_DATA : READ_ADDR;
	      READ_WAIT: next_state = READ_DATA;   //resolve cover 
        READ_DATA: next_state = (RVALID_M0 && RLAST_M0) ? IDLE : READ_DATA;
        //default:   next_state = IDLE;
      endcase
    end
    */

    // HW3
	  always_comb begin
      unique case (state)
        IDLE:      next_state = (!INST_stall) ? READ_DATA : IDLE;
        READ_ADDR: next_state = (ARREADY_M0) ? READ_DATA : READ_ADDR;
	      READ_WAIT: next_state = READ_DATA;   // no use
        READ_DATA: next_state = (RVALID_M0) ? IDLE : READ_DATA;  // && RLAST_M0
        //default:   next_state = IDLE;
      endcase
    end

    //signal to AXI
    always_comb begin
      unique case (state)
        IDLE: begin
        if(!INST_stall) begin
        //READ ADDRESS0
            ARID_M0    = 4'd0;
            ARADDR_M0  = IM_addr;
            ARLEN_M0   = BurstLeng_R; 
            ARSIZE_M0  = BurstSize_R;
            ARBURST_M0 = BurstType; 
            ARVALID_M0 = 1'd1;
            //READ DATA0
            RREADY_M0  = 1'd0;
        end else begin
          //READ ADDRESS0
            ARID_M0    = 4'd0;
            ARADDR_M0  = 32'd0;
            ARLEN_M0   = 8'd0;
            ARSIZE_M0  = 3'd0;
            ARBURST_M0 = 2'd0;
            ARVALID_M0 = 1'd0;
            //READ DATA0
            RREADY_M0  = 1'd0;
        end
        /* HW2
          //READ ADDRESS0
          ARID_M0    = 4'd0;
          ARADDR_M0  = 32'd0;
          ARLEN_M0   = 4'd0;
          ARSIZE_M0  = 3'd0;
          ARBURST_M0 = 2'd0;
          ARVALID_M0 = 1'd0;
          //READ DATA0
          RREADY_M0  = 1'd0;
        */
        end
        READ_ADDR: begin  // no use
          //READ ADDRESS0
          ARID_M0    = 4'd0;
          ARADDR_M0  = IM_addr_reg;
          ARLEN_M0   = BurstLeng_R; 
          ARSIZE_M0  = BurstSize_R;
          ARBURST_M0 = BurstType; 
          ARVALID_M0 = 1'd1;
          //READ DATA0
          RREADY_M0  = 1'd0;
        end
        READ_DATA: begin
          //READ ADDRESS0
          ARID_M0    = 4'd0;
          ARADDR_M0  = IM_addr_reg;
          ARLEN_M0   = BurstLeng_R; 
          ARSIZE_M0  = BurstSize_R;
          ARBURST_M0 = BurstType; 
          ARVALID_M0 = 1'd1;
          //READ DATA0
          RREADY_M0  = 1'd1;
        end
        default: begin
          //READ ADDRESS0
          ARID_M0    = 4'd0;
          ARADDR_M0  = 32'd0;
          ARLEN_M0   = 8'd0;
          ARSIZE_M0  = 3'd0;
          ARBURST_M0 = 2'd0;
          ARVALID_M0 = 1'd0;
          //READ DATA0
          RREADY_M0  = 1'd0;
        end
      endcase
    end
	
    //signal to CPU 
    always_comb begin
      unique case (state)
          READ_DATA : begin
            INST_done	= (RVALID_M0) ? 1'b1:1'b0;   //&& RLAST_M0
            IM_data   = RDATA_M0;
          end
          default: begin
            INST_done	= 1'd0;
            IM_data   = IM_data_reg;
          end
      endcase 
    end


endmodule
