`include "../include/AXI_define.svh"

module DRAM_wrapper
// #(
    // parameter IDLE           = 5'd0,
	// READ
	// parameter ADDR_TRANS_R   = 5'd1,
	// parameter ACT_R          = 5'd2,
	// parameter ACT_R_delay    = 5'd3,
	// parameter READ_DATA      = 5'd4,
	// parameter DATA_TRANS_1   = 5'd5,
	// parameter DATA_TRANS_2   = 5'd6,
	// parameter Detect_R       = 5'd7,
	// parameter Detect_R_L     = 5'd8,
	// parameter Detect_R_delay = 5'd9,
	// parameter PRE_R          = 5'd10,
	// parameter PRE_R_delay    = 5'd11,
	
	// WRITE
	// parameter ADDR_TRANS_W   = 5'd12,
	// parameter ACT_W          = 5'd13,
	// parameter ACT_W_delay    = 5'd14,
	// parameter WRITE_DATA     = 5'd15,
	// parameter WRITE_delay    = 5'd16,
	// parameter WRITE_delay_L  = 5'd17,
  // parameter WRITE_RESPONSE = 5'd18,
	// parameter Detect_W       = 5'd19,
	// parameter Detect_W_L     = 5'd20,
	// parameter Detect_W_delay = 5'd21,
	// parameter PRE_W          = 5'd22,
	// parameter PRE_W_delay    = 5'd23
// ) 
(
    input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
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
	
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP, 
	output logic BVALID,
	input BREADY,

	//READ ADDRESS0
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST, 
	input ARVALID,
	output logic ARREADY,
	
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP, 
	output logic RLAST,
	output logic RVALID,
	input RREADY,

    //DRAM
    // CK,
    input [31:0] Q,
    // RST,
    output logic CSn,       //Chip Select
    output logic [3:0] WEn, //Write Enable
    output logic RASn,      //Row Address Select
    output logic CASn,      //Column Address Select
    output logic [10:0] A,  //Address
    output logic [31:0] D,  //DRAM WRITE Data
    input VALID	
);
	
		
	typedef enum logic [4:0] {
		IDLE           = 5'd0,
		//READ
		ADDR_TRANS_R   = 5'd1,
		ACT_R          = 5'd2,
		ACT_R_delay    = 5'd3,
		READ_DATA      = 5'd4,
		DATA_TRANS_1   = 5'd5,
		DATA_TRANS_2   = 5'd6,
		Detect_R       = 5'd7,
		Detect_R_L     = 5'd8,
		Detect_R_delay = 5'd9,
		PRE_R          = 5'd10,
		PRE_R_delay    = 5'd11,
		
		//WRITE
		ADDR_TRANS_W   = 5'd12,
		ACT_W          = 5'd13,
		ACT_W_delay    = 5'd14,
		WRITE_DATA     = 5'd15,
		WRITE_delay    = 5'd16,
		WRITE_delay_L  = 5'd17,
		WRITE_RESPONSE = 5'd18,
		Detect_W       = 5'd19,
		Detect_W_L     = 5'd20,
		Detect_W_delay = 5'd21,
		PRE_W          = 5'd22,
		PRE_W_delay    = 5'd23
  } dram_wrapper_state;

  dram_wrapper_state current_state, next_state;
  // logic [4:0] current_state;
	// logic [4:0] next_state;
	
	logic [`AXI_IDS_BITS-1:0] ARID_reg;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
	logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
	
	logic [`AXI_IDS_BITS-1:0] AWID_reg;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_reg;
	logic [`AXI_LEN_BITS-1:0] AWLEN_reg;
	
	logic [`AXI_DATA_BITS-1:0] WDATA_reg;
	
	logic [2:0] ACT_cnt;
	logic [2:0] WRITE_cnt;
	logic [2:0] DET_cnt;
	logic [2:0] PRE_cnt;
	
	logic [10:0] A_reg;
	logic [31:0] Q_reg;
	logic VALID_reg;
	
	logic [`AXI_ADDR_BITS-1:0] ARADDR_old_reg;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_old_reg;
	
	
	always_ff@(posedge ACLK or negedge ARESETn) begin
	    if(!ARESETn)begin
		    current_state <= IDLE;
		end
		else begin
		    current_state <= next_state;
		end
	end
	
	always_comb begin
	    case(current_state)
		    IDLE : begin
			    if(ARVALID)begin
				    next_state = ADDR_TRANS_R;
				end
				else if(AWVALID)begin
				    next_state = ADDR_TRANS_W;
				end
				else begin
				    next_state = IDLE;
				end
			end
	        ADDR_TRANS_R : begin
			    next_state = ACT_R;
			end
	        ACT_R : begin
			    next_state = ACT_R_delay;
			end
	        ACT_R_delay : begin
			    if(ACT_cnt == 3'd4)begin
				    next_state = READ_DATA;
				end
				else begin
				    next_state = ACT_R_delay;
				end
			end
	        READ_DATA : begin
			    next_state = DATA_TRANS_1;
			end
	        DATA_TRANS_1 : begin
			    if(RREADY && VALID && RLAST)begin
				    next_state = Detect_R_L;
				end
				else if(RREADY && VALID)begin
				    next_state = Detect_R;
				end
				else if(VALID)begin
				    next_state = DATA_TRANS_2;
				end
				else begin
				    next_state = DATA_TRANS_1;
				end
			end
			DATA_TRANS_2 : begin
			    if(RREADY && VALID_reg && RLAST)begin
				    next_state = Detect_R_L;
				end
				else if(RREADY && VALID_reg)begin
				    next_state = Detect_R;
				end
				else begin
				    next_state = DATA_TRANS_2;
				end
			end
			Detect_R : begin
			    if(ARADDR_reg[22:12] == ARADDR_old_reg[22:12])begin 
				    next_state = Detect_R_delay;
				end
				else begin 
				    next_state = PRE_R;
				end
			end
	        Detect_R_L : begin
			    if(ARVALID && (ARADDR_reg[22:12] == ARADDR[22:12]))begin 
				    next_state = Detect_R_delay;
				end
				else if(AWVALID && (ARADDR_reg[22:12] == AWADDR[22:12]))begin 
				    next_state = Detect_W_delay;
				end
				else if(ARVALID)begin 
				    next_state = PRE_R;
				end
				else if(AWVALID)begin 
				    next_state = PRE_W;
				end
				else begin
				    next_state = Detect_R_L;
				end
			end
			Detect_R_delay : begin
			    if(DET_cnt == 3'd4)begin
				    next_state = READ_DATA;
				end
				else begin
				    next_state = Detect_R_delay;
				end
			end
	        PRE_R : begin
			    next_state = PRE_R_delay;
			end
	        PRE_R_delay : begin
			    if(PRE_cnt == 3'd4)begin 
				    next_state = ACT_R;
				end
				else begin
				    next_state = PRE_R_delay;
				end
			end
	        ADDR_TRANS_W : begin
			    next_state = ACT_W;
			end
	        ACT_W : begin
			    next_state = ACT_W_delay;
			end
	        ACT_W_delay : begin
			    if(ACT_cnt == 3'd4)begin
				    next_state = WRITE_DATA;
				end
				else begin
				    next_state = ACT_W_delay;
				end
			end
            WRITE_DATA : begin
			    if(WLAST && WVALID)begin
				    next_state = WRITE_delay_L;
				end
				else if(WVALID)begin
				    next_state = WRITE_delay;
				end
				else begin
				    next_state = WRITE_DATA;
				end
			end
			WRITE_delay : begin
			    if(WRITE_cnt == 3'd4)begin
				    next_state = Detect_W;
				end
				else begin
				    next_state = WRITE_delay;
				end
			end
			WRITE_delay_L : begin
			    if(WRITE_cnt == 3'd3)begin
				    next_state = WRITE_RESPONSE;
				end
				else begin
				    next_state = WRITE_delay_L;
				end
			end
            WRITE_RESPONSE : begin
			    if(BREADY)begin
				    next_state = Detect_W_L;
				end
				else begin
				    next_state = WRITE_RESPONSE;
				end
			end
			Detect_W : begin
			    if(AWADDR_reg[22:12] == AWADDR_old_reg[22:12])begin 
				    next_state = Detect_W_delay;
				end
				else begin 
				    next_state = PRE_W;
				end
			end
	        Detect_W_L : begin
			    if(ARVALID && (AWADDR_reg[22:12] == ARADDR[22:12]))begin 
				    next_state = Detect_R_delay;
				end
				else if(AWVALID && (AWADDR_reg[22:12] == AWADDR[22:12]))begin 
				    next_state = Detect_W_delay;
				end
				else if(ARVALID)begin 
				    next_state = PRE_R;
				end
				else if(AWVALID)begin 
				    next_state = PRE_W;
				end
				else begin
				    next_state = Detect_W_L;
				end
			end
			Detect_W_delay : begin
			    if(DET_cnt == 3'd4)begin
				    next_state = WRITE_DATA;
				end
				else begin
				    next_state = Detect_W_delay;
				end
			end
	        PRE_W : begin
			    next_state = PRE_W_delay;
			end
	        PRE_W_delay : begin
			    if(PRE_cnt == 3'd4)begin 
				    next_state = ACT_W;
				end
				else begin
				    next_state = PRE_W_delay;
				end
			end
			default : next_state = IDLE;
		endcase
	end
	
	always_comb begin
	    case(current_state)
		    IDLE : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        ADDR_TRANS_R : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b1;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        ACT_R : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd0;
                CASn    = 1'd1;
                A       = ARADDR_reg[22:12];
                D       = 32'd0;
			end
	        ACT_R_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        READ_DATA : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd0;
                A       = {1'b0,ARADDR_reg[11:2]};
                D       = 32'd0;
			end
	        DATA_TRANS_1 : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = ARID_reg;
	            RDATA   = Q;
	            RRESP   = 2'b00; //OKAY
				if(VALID && (ARLEN_reg == 8'd0))begin
	                RLAST = 1'd1;
				end
                else begin
				    RLAST = 1'd0;
                end				
	            RVALID  = VALID;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			DATA_TRANS_2 : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = ARID_reg;
	            RDATA   = Q_reg;
	            RRESP   = 2'b00; //OKAY
	            if(VALID_reg && (ARLEN_reg == 8'd0))begin
	                RLAST = 1'd1;
				end
                else begin
				    RLAST = 1'd0;
                end	
	            RVALID  = VALID_reg;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			Detect_R : begin
				AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

				ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        Detect_R_L : begin
			    if(AWVALID)begin
				    AWREADY = 1'b1;
				end
				else begin
				    AWREADY = 1'b0;
				end
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	if(ARVALID)begin
				    ARREADY = 1'b1;
				end
				else begin
				    ARREADY = 1'b0;
				end
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			Detect_R_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        PRE_R : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'h0;
                RASn    = 1'd0;
                CASn    = 1'd1;
                A       = A_reg;
                D       = 32'd0;
			end
	        PRE_R_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        ADDR_TRANS_W : begin
			    AWREADY = 1'b1;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        ACT_W : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd0;
                CASn    = 1'd1;
                A       = AWADDR_reg[22:12];
                D       = 32'd0;
			end
	        ACT_W_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        WRITE_DATA : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b1;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                if(WVALID)begin
				    CSn  = 1'd0;
                    WEn  = WSTRB; 
                    RASn = 1'd1;
                    CASn = 1'd0;
                    A    = {1'b0,AWADDR_reg[11:2]};
                    D    = WDATA;
				end
				else begin
				    CSn  = 1'd1;
                    WEn  = 4'hf;
                    RASn = 1'd1;
                    CASn = 1'd1;
                    A    = 11'd0;
                    D    = 32'd0;
				end
			end
			WRITE_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

				CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = {1'b0,AWADDR_reg[11:2]};
                D       = WDATA_reg;
			end
			WRITE_delay_L : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

				CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = {1'b0,AWADDR_reg[11:2]};
                D       = WDATA_reg;
			end
            WRITE_RESPONSE : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = AWID_reg;
				BRESP   = 2'b00;
	            BVALID  = 1'b1;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			Detect_W : begin
				AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

				ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        Detect_W_L : begin
			    if(AWVALID)begin
				    AWREADY = 1'b1;
				end
				else begin
				    AWREADY = 1'b0;
				end
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	if(ARVALID)begin
				    ARREADY = 1'b1;
				end
				else begin
				    ARREADY = 1'b0;
				end
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			Detect_W_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
	        PRE_W : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd0;
                WEn     = 4'h0;
                RASn    = 1'd0;
                CASn    = 1'd1;
                A       = A_reg;
                D       = 32'd0;
			end
	        PRE_W_delay : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
			default : begin
			    AWREADY = 1'b0;
                WREADY  = 1'b0;
	            BID     = 8'd0;
	            BRESP   = 2'b00; //OKAY
	            BVALID  = 1'b0;

            	ARREADY = 1'b0;
	            RID     = 8'd0;
	            RDATA   = 32'd0;
	            RRESP   = 2'b00; //OKAY
	            RLAST   = 1'b0;
	            RVALID  = 1'b0;

                CSn     = 1'd1;
                WEn     = 4'hf;
                RASn    = 1'd1;
                CASn    = 1'd1;
                A       = 11'd0;
                D       = 32'd0;
			end
		endcase
	end
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)begin
		    ARID_reg   <= 8'd0;
	        ARADDR_reg <= 32'd0;
	        ARSIZE_reg <= 3'd0;
	        ARLEN_reg  <= 8'd0;
	
	        AWID_reg   <= 8'd0;
	        AWADDR_reg <= 32'd0;
	        AWSIZE_reg <= 3'd0;
	        AWLEN_reg  <= 8'd0;
			
			WDATA_reg  <= 32'd0;
			
			A_reg      <= 11'd0;
			Q_reg      <= 32'd0;
	        VALID_reg  <= 1'd0;
			
			ARADDR_old_reg <= 32'd0;
			AWADDR_old_reg <= 32'd0;
		end
		else if(current_state == ADDR_TRANS_R)begin
		    ARID_reg   <= ARID;
	        ARADDR_reg <= ARADDR;
	        ARSIZE_reg <= ARSIZE;
	        ARLEN_reg  <= ARLEN;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= ARADDR_reg[22:12];
			A_reg      <= ARADDR[22:12];
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
		else if(current_state == ADDR_TRANS_W)begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID;
	        AWADDR_reg <= AWADDR;
	        AWSIZE_reg <= AWSIZE;
	        AWLEN_reg  <= AWLEN;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= AWADDR_reg[22:12];
			A_reg      <= AWADDR[22:12];
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR;
		end
		else if((current_state == DATA_TRANS_1) && VALID)begin
		    ARID_reg   <= ARID_reg;
			if(RREADY)begin
			    ARADDR_reg <= ARADDR_reg + 32'd4;
				ARLEN_reg  <= ARLEN_reg - 8'd1;
			end
			else begin
			    ARADDR_reg <= ARADDR_reg;
				ARLEN_reg  <= ARLEN_reg;
			end
	        ARSIZE_reg <= ARSIZE_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			A_reg      <= A_reg;
			Q_reg      <= Q;
	        VALID_reg  <= VALID;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
		else if((current_state == DATA_TRANS_2) && RREADY && VALID_reg)begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg + 32'd4;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg - 8'd1;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= ARADDR_reg[22:12];
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
        else if((current_state == Detect_R_L) && ARVALID)begin
		    ARID_reg   <= ARID;
	        ARADDR_reg <= ARADDR;
	        ARSIZE_reg <= ARSIZE;
	        ARLEN_reg  <= ARLEN;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= ARADDR_reg[22:12];
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
        else if((current_state == Detect_R_L) && AWVALID)begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID;
	        AWADDR_reg <= AWADDR;
	        AWSIZE_reg <= AWSIZE;
	        AWLEN_reg  <= AWLEN;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= ARADDR_reg[22:12];
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
		else if((current_state == WRITE_delay) && (WRITE_cnt == 3'd3))begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg + 32'd4;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= AWADDR_reg[22:12];
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_reg;
		end
		else if((current_state == Detect_W_L) && ARVALID)begin
		    ARID_reg   <= ARID;
	        ARADDR_reg <= ARADDR;
	        ARSIZE_reg <= ARSIZE;
	        ARLEN_reg  <= ARLEN;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= AWADDR_reg[22:12];
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
        else if((current_state == Detect_W_L) && AWVALID)begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID;
	        AWADDR_reg <= AWADDR;
	        AWSIZE_reg <= AWSIZE;
	        AWLEN_reg  <= AWLEN;
			
			WDATA_reg  <= WDATA_reg;
			
			// A_reg      <= AWADDR_reg[22:12];
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
		else if((current_state == WRITE_DATA) && WVALID)begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA;
			
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
		else if(current_state == PRE_R)begin
			ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			A_reg      <= ARADDR_reg[22:12];
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end	
		else if(current_state == PRE_W)begin
			ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			A_reg      <= AWADDR_reg[22:12];
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end	
		else begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
	
	        AWID_reg   <= AWID_reg;
	        AWADDR_reg <= AWADDR_reg;
	        AWSIZE_reg <= AWSIZE_reg;
	        AWLEN_reg  <= AWLEN_reg;
			
			WDATA_reg  <= WDATA_reg;
			
			A_reg      <= A_reg;
			Q_reg      <= Q_reg;
	        VALID_reg  <= VALID_reg;
			
			ARADDR_old_reg <= ARADDR_old_reg;
			AWADDR_old_reg <= AWADDR_old_reg;
		end
	end
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)begin
			ACT_cnt   <= 3'd0;
	        WRITE_cnt <= 3'd0;
			DET_cnt   <= 3'd0;
	        PRE_cnt   <= 3'd0;
		end
		else if(current_state == ACT_R_delay || current_state == ACT_W_delay)begin
			ACT_cnt   <= ACT_cnt + 3'd1;
	        WRITE_cnt <= 3'd0;
			DET_cnt   <= 3'd0;
	        PRE_cnt   <= 3'd0;
		end
		else if(current_state == WRITE_delay || current_state == WRITE_delay_L)begin
			ACT_cnt   <= 3'd0;
	        WRITE_cnt <= WRITE_cnt + 3'd1;
			DET_cnt   <= 3'd0;
	        PRE_cnt   <= 3'd0;
		end
		else if(current_state == Detect_R_delay || current_state == Detect_W_delay)begin
			ACT_cnt   <= 3'd0;
	        WRITE_cnt <= 3'd0;
			DET_cnt   <= DET_cnt + 3'd1;
	        PRE_cnt   <= 3'd0;
		end
		else if(current_state == PRE_R_delay || current_state == PRE_W_delay)begin
			ACT_cnt   <= 3'd0;
	        WRITE_cnt <= 3'd0;
			DET_cnt   <= 3'd0;
	        PRE_cnt   <= PRE_cnt + 3'd1;
		end
		else begin
		    ACT_cnt   <= 3'd0;
	        WRITE_cnt <= 3'd0;
			DET_cnt   <= 3'd0;
	        PRE_cnt   <= 3'd0;
		end
	end

endmodule
