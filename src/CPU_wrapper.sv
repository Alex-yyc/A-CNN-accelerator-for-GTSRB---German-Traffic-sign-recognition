//*********************************************************
// Auther:      N26111512           
// Filename:    CPU_wrapper.sv                            
// Description: Top module of CPU Wrapper                  
// Version:     3 [FINAL]
//*********************************************************
`include "../include/AXI_define.svh"
`include "../include/define.svh"
`include "def.svh"
`include "CPU/CPU.sv"
`include "CPU_Inst.sv"
`include "CPU_Data.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module CPU_wrapper (
  input ACLK,
	input ARESETn,
	
	input interrupt,
	// input WDT_interrupt,
	input interrupt_dma_epu,
	input m2_start,
	output logic m_done,
	
  //==============INST READ=================
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
	output logic RREADY_M0, 

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

  ////////////////////////////////
  // Variables
  //
    //CPU
    logic IM_OE, DM_OE, CPU_STALL, INST_stall, DATA_stall, CPUrst;
    logic [3:0] DM_WEB;
    logic [`InstAddrBus] IM_addr, DM_addr;
    logic [`RegBus] IM_data, DM_data, DM_DI; 

    //FSM
    parameter IDLE     = 2'd0;
    parameter READ_M0  = 2'd1;
    parameter READ_M1  = 2'd2;
    parameter WRTIE_M1 = 2'd3;

    logic [1:0] state, next_state;
    logic M0_Done, M1_Done;
	
	//I cache
	logic I_core_req;
    logic [`DATA_BITS-1:0] I_out;
    // logic I_wait;
    logic I_core_wait;
    logic I_req;
    logic [`DATA_BITS-1:0] I_addr;
	logic I_write;
    logic [`DATA_BITS-1:0] I_in;
    logic [`CACHE_TYPE_BITS-1:0] I_type;
	
	//D cache
	logic D_core_req;
    logic core_write;
    logic [`CACHE_TYPE_BITS-1:0] core_type;
    logic [`DATA_BITS-1:0] D_out;
    // logic D_wait;
    logic D_core_wait;
    logic D_req;
    logic [`DATA_BITS-1:0] D_addr;
    logic D_write;
    logic [`DATA_BITS-1:0] D_in;
    logic [`CACHE_TYPE_BITS-1:0] D_type;

  ////////////////////////////////
  // Module Body//
	// assign core_write = (DM_WEB != `MEM_NOWRITE) ? 1'b1 : 1'b0;
	assign m_done = M1_Done;

  // m0 read 4 times
  logic [1:0] m0done_cnt;
  always_ff @(posedge ACLK  or negedge ARESETn) begin 
    if(!ARESETn) m0done_cnt <= 2'd0;
    // else if(m0done_cnt == 2'd3 && state == IDLE) m0done_cnt <= 2'd0;
    else if(state == READ_M0 && M0_Done) m0done_cnt <= m0done_cnt + 2'd1;
  end
	
	always_comb begin
        case(DM_WEB)
		    4'b1110 : core_type = 3'b000; //byte
			4'b1100 : core_type = 3'b001; //half world
			4'b0000 : core_type = 3'b010; //world
            default : core_type = 3'b010;
		endcase
    end
	
	//assign CPUrst = !ARESETn | WDT_interrupt;  // rst
    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) CPUrst <= 1'b1;
	//   else if(WDT_interrupt) CPUrst <= 1'b1;
      else          CPUrst <= 1'b0;
    end

    always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) state <= IDLE;
      else          state <= next_state;
    end
		
		// repetitive addr
	logic repet;
	logic [`InstAddrBus] repet_waddr; 
	always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) repet_waddr <= 32'd0;
      else if(state == WRTIE_M1) repet_waddr <= DM_addr;
    end
		
		assign repet = (repet_waddr == DM_addr) & ((DM_WEB == `MEM_WRITE));
		
    always_comb begin
      unique case (state)
        //IDLE: next_state = (I_req) ? READ_M0 : IDLE;
        IDLE: begin
					if (m2_start) next_state = IDLE;
          else if (I_req) next_state = READ_M0;
          else if (D_req) next_state = READ_M1;
          else if (D_write && ~repet) next_state = WRTIE_M1;    // 
          else next_state = IDLE;
        end 
        READ_M0: begin
          if (M0_Done) begin // 
            if (D_req) 
              next_state = READ_M1;
            else if (D_write && (m0done_cnt == 2'd3)) 
              next_state = WRTIE_M1;
            else
              next_state = IDLE; 
          end else 
            next_state = READ_M0;
        end 
        READ_M1:  next_state = (M1_Done) ? IDLE : READ_M1;
        WRTIE_M1: next_state = (M1_Done) ? IDLE : WRTIE_M1;
        //default: next_state = IDLE;
      endcase
    end

    always_comb begin
      unique case (state)
        IDLE:begin
          CPU_STALL = (m2_start) ? 1'b1 : 1'b0;
          INST_stall = 1'b1;
          DATA_stall = 1'b1;
        end

        READ_M0: begin
          CPU_STALL = 1'b1;
          INST_stall = 1'b0;
          DATA_stall = 1'b1;
        end
        READ_M1: begin
          CPU_STALL = 1'b1;
          INST_stall = 1'b1;
          DATA_stall = 1'b0;
        end
        WRTIE_M1: begin
          CPU_STALL = 1'b1;
          INST_stall = 1'b1;
          DATA_stall = 1'b0;
        end
      endcase
    end

    CPU myCPU(
      .clk       (ACLK), 
      .rst       (CPUrst),
	  .interrupt (interrupt),
	  .interrupt_dma_epu(interrupt_dma_epu),
      .CPU_STALL (I_core_wait || D_core_wait),
      .IM_data   (IM_data),
      .DM_DO     (DM_data),
      .IM_addr   (IM_addr),
      .DM_A      (DM_addr),
      .DM_DI     (DM_DI),
      .DM_WEB    (DM_WEB),
      .IM_OE     (IM_OE),
      .DM_OE     (DM_OE)
    );

    CPU_Inst M0(
      .ACLK       (ACLK),
      .ARESETn    (ARESETn),
      //CPU
      .IM_OE      (I_req),
      .IM_addr    (I_addr),
      .IM_data    (I_out),
      .INST_stall (INST_stall),
      .INST_done  (M0_Done),
      .*
    );

    CPU_Data M1(
      .ACLK       (ACLK),
      .ARESETn    (ARESETn),
      //CPU
      .DM_OE      (D_req),
      .DM_WEB     (DM_WEB),
      .DM_addr    (D_addr),
      .DM_DI      (D_in),
      .DM_data    (D_out),
      .DATA_stall (DATA_stall),
      .DATA_DONE  (M1_Done),
      .*
    );
	
	L1C_inst cacheI1(
      .clk        (ACLK),
      .rst        (~ARESETn),

      // Core to CPU wrapper
      .core_addr  (IM_addr),
      .core_req   (I_core_req),
      .core_write (1'd0),
      .core_in    (32'd0),
      .core_type  (3'b010),
      // Mem to CPU wrapper
      .I_out      (I_out),
      .I_wait     (~M0_Done),
      // CPU wrapper to core
      .core_out   (IM_data),
      .core_wait  (I_core_wait),
      // CPU wrapper to Mem
      .I_req      (I_req),
      .I_addr     (I_addr),
      .I_write    (I_write), //
      .I_in       (I_in), //
      .I_type     (I_type) //
    );
	
	L1C_data cacheD1(
      .clk        (ACLK),
      .rst        (~ARESETn),
	  .m2_start   (m2_start),
      // Core to CPU wrapper
      .core_addr  (DM_addr),
      .core_req   (D_core_req),
      .core_write (core_write),
      .core_in    (DM_DI),
      .core_type  (core_type),
      // Mem to CPU wrapper
      .D_out      (D_out),
      .D_wait     (~M1_Done),
      // CPU wrapper to core
      .core_out   (DM_data),
      .core_wait  (D_core_wait),
      // CPU wrapper to Mem
      .D_req      (D_req),
      .D_addr     (D_addr), 
      .D_write    (D_write), 
      .D_in       (D_in), //
      .D_type     (D_type) //
    );
	
	logic [1:0] current_state_C;
	logic [1:0] next_state_C;
	
	always_ff@(posedge ACLK or negedge ARESETn) begin
	    if(!ARESETn)begin
		    current_state_C <= 2'd0;
		end
		else begin
		    current_state_C <= next_state_C;
		end
	end
	
	always_comb begin
	    case(current_state_C)
		    2'd0 : begin
				if(m2_start || repet)begin
				    next_state_C = 2'd0;
				end
			    else if(IM_OE)begin
				    next_state_C = 2'd1;
				end
				else if(DM_OE || (DM_WEB != `MEM_NOWRITE))begin
				    next_state_C = 2'd2;
				end
				else begin
				    next_state_C = 2'd0;
				end
			end
			2'd1 : begin
			    if(DM_OE || (DM_WEB != `MEM_NOWRITE))begin
				    next_state_C = 2'd3;
				end
				else if(!I_core_wait && !D_core_wait)begin
				    next_state_C = 2'd0;
				end
				else begin
				    next_state_C = 2'd1;
				end
			end
			2'd2 : begin
			    if(IM_OE)begin
				    next_state_C = 2'd3;
				end
				else if(!I_core_wait && !D_core_wait)begin
				    next_state_C = 2'd0;
				end
				else begin
				    next_state_C = 2'd2;
				end
			end
			2'd3 : begin
			    if(!I_core_wait && !D_core_wait)begin
				    next_state_C = 2'd0;
				end
				else begin
				    next_state_C = 2'd3;
				end
			end
		endcase
	end
	
	always_comb begin
	    case(current_state_C)
		    2'd0 : begin
			    if(m2_start)begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
				else if(IM_OE)begin
				    I_core_req = 1'b1;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
				else if(DM_OE)begin
				    I_core_req = 1'b0;
					D_core_req = 1'b1;
					core_write = 1'b0;
				end
				else if(DM_WEB != `MEM_NOWRITE)begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b1;
				end
				else begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
			end
			2'd1 : begin
			    if(DM_OE)begin
				    I_core_req = 1'b0;
					D_core_req = 1'b1;
					core_write = 1'b0;
				end
				else if(DM_WEB != `MEM_NOWRITE)begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b1;
				end
				else if(!I_core_wait && !D_core_wait)begin
				    I_core_req = 1'b1;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
				else begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
			end
			2'd2 : begin
			    if(IM_OE)begin
				    I_core_req = 1'b1;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
				else if(!I_core_wait && !D_core_wait)begin
				    I_core_req = 1'b1;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
				else begin
				    I_core_req = 1'b0;
					D_core_req = 1'b0;
					core_write = 1'b0;
				end
			end
			2'd3 : begin
                if(!I_core_wait && !D_core_wait)begin
				    I_core_req = 1'b1;
			        D_core_req = 1'b0;
    				core_write = 1'b0;
				end
				else begin
				    I_core_req = 1'b0;
    			    D_core_req = 1'b0;
    				core_write = 1'b0;
				end
			    //I_core_req = 1'b0;
			    //D_core_req = 1'b0;
				//core_write = 1'b0;
			end
		endcase
	end

endmodule
