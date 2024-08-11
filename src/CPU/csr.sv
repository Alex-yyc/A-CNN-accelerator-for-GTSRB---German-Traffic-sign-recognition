module csr (
    input clk, rst,
    input flush, 
    input hazard_stall,
    input MemStall,
    input [11:0] CSR_imm,
    input [6:0] opcode,
    //HW3 New
    input WFI,
    input interrupt,
    input interrupt_dma_epu,
    input CSR_return,
    input CSRWrite,
    input [`RegBus] CSR_wdata_i,
    input [11:0] CSR_waddr_i,
    input [`InstBus] pc,

    output logic [`RegBus] out,
    output logic [11:0] CSR_waddr_o
);

    //csr imm
    parameter imm_MSTATUS   = 12'h300; 
    parameter imm_MIE       = 12'h304;
    parameter imm_MTVEC     = 12'h305;
    parameter imm_MEPC      = 12'h341;
    parameter imm_MIP       = 12'h344;
    parameter imm_MCYCLE    = 12'hb00;
    parameter imm_MINSTRET  = 12'hb02;
    parameter imm_MCYCLEH   = 12'hb80;
    parameter imm_MINSTRETH = 12'hb82;

    // m mode reg
    logic [31:0] mstatus, mie, mtvec, mepc, mip;
    logic [63:0] cycle, instret;

    // ---------------output data-------------------
    assign CSR_waddr_o = CSR_imm;

    always_comb begin
        if (CSR_return) out = mepc;
        else if (WFI)   out = mtvec;
        else begin
            unique case (CSR_imm)
                imm_MSTATUS:   out = mstatus;
                imm_MIE:       out = mie;
                imm_MTVEC:     out = mtvec;
                imm_MEPC:      out = mepc;
                imm_MIP:       out = mip;
                imm_MINSTRETH: out = instret[63:32];
                imm_MINSTRET:  out = instret[31:0];
                imm_MCYCLEH:   out = cycle[63:32];
                imm_MCYCLE:    out = cycle[31:0];
                default:       out = 32'd0;
            endcase
        end 
    end 

    // -----------------CSR register--------------------
    assign mtvec = 32'h0001_0000;	

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mstatus <= 32'd0;
            mie     <= 32'd0;
            mepc    <= 32'd0;
            mip     <= 32'd0;
        end 
        else if ((interrupt | interrupt_dma_epu)) begin  // && (mie[11] == 1'd1)
            mstatus <= {19'd0,2'b11,3'd0,mstatus[3],3'd0,1'b0,3'd0};
            mie     <= {20'd0,CSR_wdata_i[11],11'd0};  //?
            mepc    <= pc;
            mip     <= mip;
        end
        else if (CSR_return) begin
            mstatus <= {19'd0,2'b11,3'd0,1'b1,3'd0,mstatus[7],3'd0};
            mie     <= mie;
            mepc    <= mepc;
            mip     <= mip;
        end
        else begin
            if (CSRWrite) begin
                unique case(CSR_waddr_i)
                    imm_MSTATUS : begin 
						mstatus <= {19'd0,CSR_wdata_i[12:11],3'd0,CSR_wdata_i[7],3'd0,CSR_wdata_i[3],3'd0};
						mie     <= mie;
						mepc    <= mepc;
						mip     <= mip;
					end
                    imm_MIE     : begin 
						mstatus <= mstatus;
						mie     <= {20'd0,CSR_wdata_i[11],11'd0};
						mepc    <= mepc;
						mip     <= mip;
					end
                    imm_MEPC    : begin
						mstatus <= mstatus;
						mie     <= mie;
						mepc    <= CSR_wdata_i;
						mip     <= mip; 
					end 
                    imm_MIP     : begin 
						mstatus <= mstatus;
						mie     <= mie;
						mepc    <= mepc;
						mip     <= mip;      //{20'd0,CSR_wdata_i[11],3'd0,CSR_wdata_i[7],7'd0};  //?
					end 
			        default : begin
                        mstatus <= mstatus;
                        mie     <= mie;
                        mepc    <= mepc;
                        mip     <= mip;
                    end	
                endcase
            end 
            else begin
                mstatus <= mstatus;
                mie     <= mie;
                mepc    <= mepc;
                mip     <= mip;
            end
        end 
    end
   
    // -------------------hardware performance monitor-------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)  instret <= 64'd0;
        else if (flush && !MemStall) instret <= instret - 64'd1; 
        else if (hazard_stall || MemStall || opcode == 7'd0) instret <= instret;
	    else      instret <= instret + 64'd1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)  cycle <= 64'd0;
        else      cycle <= cycle + 64'd1;
    end

endmodule
