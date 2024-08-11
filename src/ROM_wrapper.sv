`include "../include/AXI_define.svh"

module ROM_wrapper
#(
	parameter IDLE       = 1'd0,
	parameter DATA_TRANS = 1'd1
) 
(
    input ACLK,
	input ARESETn,

	//AR
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST, 
	input ARVALID,
	output logic ARREADY,
	
	//R
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP, 
	output logic RLAST,
	output logic RVALID,
	input RREADY,

    //ROM
    input [31:0] DO,
    output logic OE,
    output logic CS,
    output logic [11:0] A	
);

	logic current_state;
	logic next_state;
	
	logic [`AXI_IDS_BITS-1:0] ARID_reg;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
	logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
	
	logic [3:0] LEN_cnt;
  
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
					next_state = DATA_TRANS;
				end
				else begin
				    next_state = IDLE;
				end
			end
	        DATA_TRANS : begin
			    if(RLAST && RREADY)begin
				    next_state = IDLE;
				end
				else begin
				    next_state = DATA_TRANS;
				end
			end 
		endcase
	end
	
	always_comb begin
	    case(current_state)
		    IDLE : begin
			    if(ARVALID)begin
	                ARREADY = 1'b1;
	                RID     = 8'd0;
	                RDATA   = 32'd0;
	                RRESP   = 2'b00; //OKAY
	                RLAST   = 1'b0;
	                RVALID  = 1'b0;

                    OE      = 1'b1;
                    CS      = 1'b1;
                    A       = ARADDR[13:2];
				end
				else begin
				    ARREADY = 1'b0;
	                RID     = 8'd0;
	                RDATA   = 32'd0;
	                RRESP   = 2'b00; //OKAY
	                RLAST   = 1'b0;
	                RVALID  = 1'b0;

                    OE      = 1'b0;
                    CS      = 1'b0;
                    A       = 12'd0;
				end
			end
	        DATA_TRANS : begin
	            ARREADY = 1'b0;
	            RID     = ARID_reg;
	            RDATA   = DO;
				RRESP   = 2'b00; //OKAY
				RLAST   = 1'b1;
	            RVALID  = 1'b1;

                OE      = 1'b1;
                CS      = 1'b1;
                A       = ARADDR_reg[13:2];
			end   
		endcase
	end
	
	always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)begin
		    ARID_reg   <= 8'd0;
	        ARADDR_reg <= 32'd0;
	        ARSIZE_reg <= 3'd0;
	        ARLEN_reg  <= 8'd0;
		end
		else if(ARVALID)begin
		    ARID_reg   <= ARID;
	        ARADDR_reg <= ARADDR;
	        ARSIZE_reg <= ARSIZE;
	        ARLEN_reg  <= ARLEN;
		end	
		else begin
		    ARID_reg   <= ARID_reg;
	        ARADDR_reg <= ARADDR_reg;
	        ARSIZE_reg <= ARSIZE_reg;
	        ARLEN_reg  <= ARLEN_reg;
		end
	end

endmodule
