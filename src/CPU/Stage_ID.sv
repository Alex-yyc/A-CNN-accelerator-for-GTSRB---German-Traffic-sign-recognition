`include "CPU/control.sv"
`include "CPU/register_file.sv"
`include "CPU/sign_extend.sv"
`include "CPU/hazard_detection_unit.sv"
`include "CPU/csr.sv"

module Stage_ID (
    input clk, rst,
    
    // from pipe_reg
    input [`InstBus] pc4_i,
    input [`InstBus] pc_i,
    input [`InstBus] inst_i,  // from im
    // from WB
    input RegWrite_i,
    input [`RegAddrBus]waddr_i,
    input [`RegBus]wdata_i,
    // hazard from ex
	input ID_EX_MemRead,
    input [`RegAddrBus]ID_EX_Rt_i,
	// for CSR
	input flush,
	input MemStall,
    // new csr
    input CSRWrite_i,
    input CSR_return_i,
    input [11:0]CSR_waddr_i,
    input [`RegBus]CSR_wdata_i,
    input interrupt,  //WFI
    input interrupt_dma_epu,

    // pc
    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pc_o,
    // control signal
    output logic jump_o,
    output logic Branch_o,
    output logic PCsel_o,
    output logic [1:0]StoreCon_o,
    output logic [2:0]LoadCon_o,
    output logic [3:0]WEB_o,
    output logic MemRead_o,
    output logic [2:0]rdsrc_o,
    output logic RegWrite_o,
    output logic MemtoReg_o,
    output logic ALUSrc_o,
    output logic [5:0]ALUop_o,
    output logic ALUSel_o,
    // rf
    output logic [`RegBus]rdata1_o,
    output logic [`RegBus]rdata2_o,
    // imm
    output logic [`RegBus]imm_o,
    // to forwarding
    output logic [`RegAddrBus]raddr1_o,
    output logic [`RegAddrBus]raddr2_o,
    output logic [`RegAddrBus]rd_o,
    //csr
    output logic [`RegBus]csr_o,
    // hazard
    output logic hazard_stall,
    // new csr
    output logic WFI_o,
    output logic CSR_return_o,
    output logic [1:0]CSR_ALUop_o,
    output logic CSR_ALUSrc_o,    
    output logic CSRWrite_o,
    output logic [11:0]CSR_waddr_o
);
    
    // control unit
    logic MemRead_wire, RegWrite_wire, MemtoReg_wire, ALUSrc_wire, jump_wire, Branch_wire, WFI_wire, CSR_ALUSrc_wire, CSRWrite_wire, CSR_return_wire;
    logic [1:0]StoreCon_wire, CSR_ALUop_wire;
    logic [2:0]LoadCon_wire, rdsrc_wire, Immop_wire;
    logic [3:0]WEB_wire;
    logic [5:0]ALUop_wire;
    logic [11:0]CSR_waddr_wire;
    logic [`InstBus] inst_wire;

    /* HW1

	logic flush2;
	always_ff @(posedge clk or posedge rst) begin   // for flush 2 clk
		if(rst) flush2 <= 1'b1;   										// for beining rst
		else if(flush) flush2 <= 1'b1;
		else flush2 <= 1'b0;  
	end
    
	logic stall_reg;  // for inst stall 1 clk
    always_ff @( posedge clk or posedge rst) begin
	    if(rst) stall_reg <= 1'd0;
        else if(hazard_stall || MemStall) stall_reg <= 1'd1;
        else stall_reg <= 1'd0;
    end     
	logic [`InstBus]inst_reg;  // save stall inst
	always_ff @(posedge clk or posedge rst) begin
		if(rst) inst_reg <= 32'd0;
		else if (stall_reg) inst_reg <= inst_reg;
		else inst_reg <= inst_i;
	end

    logic [`InstBus]mux_wire;
    mux_2to1 mux1(.i1(inst_i), .i2(inst_i), .sel(stall_reg), .result(mux_wire));
    mux_2to1 mux2(.i1(mux_wire), .i2(32'd0), .sel(flush || flush2), .result(inst_wire));

    //assign inst_wire = (flush || flush2) ? 32'd0 : ((stall_reg) ? inst_reg : inst_i);  //?

    */
    

    assign pc4_o  = pc4_i;
    // assign pc_o   = (flush || flush2) ? 32'd0 : pc_i;  // 
    assign pc_o   = pc_i; //(flush) ? 32'd0 : pc_i;

    control control1 (.opcode(inst_i[6:0]), .func3(inst_i[14:12]), .func7(inst_i[31:25]), .CSR_imm(inst_i[31:20]), 
                      .WEB(WEB_wire), .ALUop(ALUop_wire), .jump(jump_wire), .Branch(Branch_wire), .MemRead(MemRead_wire), .MemtoReg(MemtoReg_wire), .RegWrite(RegWrite_wire), 
                      .ALUSrc(ALUSrc_wire), .rdsrc(rdsrc_wire), .Immop(Immop_wire), .LoadCon(LoadCon_wire), .StoreCon(StoreCon_wire), .PCsel(PCsel_o),
                      .WFI(WFI_wire), .CSR_return(CSR_return_wire), .CSRWrite(CSRWrite_wire), .CSR_ALUSrc(CSR_ALUSrc_wire), .CSR_ALUop(CSR_ALUop_wire));
    register_file rf (.clk(clk), .rst(rst), .raddr1_i(inst_i[19:15]), .raddr2_i(inst_i[24:20]), .RegWrite(RegWrite_i), .waddr_i(waddr_i), .wdata_i(wdata_i), .rdata1_o(rdata1_o), .rdata2_o(rdata2_o));
    sign_extend se(.in(inst_i[31:7]), .Immop(Immop_wire), .out(imm_o));
    hazard_detection_unit hdu(.clk(clk), .rst(rst), .MemStall(MemStall), .ID_EX_MemRead(ID_EX_MemRead), .IF_ID_Rs(inst_i[19:15]), .IF_ID_Rt(inst_i[24:20]), .ID_EX_Rt(ID_EX_Rt_i), .hazard_stall(hazard_stall));
    csr csr1(.clk(clk), .rst(rst), .flush(flush) , .hazard_stall(hazard_stall), .MemStall(MemStall), .CSR_imm(inst_i[31:20]), .opcode(inst_i[6:0]), .out(csr_o), .pc(pc_i), .interrupt_dma_epu(interrupt_dma_epu),
             .WFI(WFI_o), .interrupt(interrupt), .CSR_return(CSR_return_o), .CSRWrite(CSRWrite_i), .CSR_wdata_i(CSR_wdata_i), .CSR_waddr_i(CSR_waddr_i), .CSR_waddr_o(CSR_waddr_o));

    always_comb begin
        if(hazard_stall || (pc_i == 32'd0))
            ALUSel_o = 1'd0;
        else if((ALUop_wire == `ALU_MUL)||(ALUop_wire == `ALU_MULH)||(ALUop_wire == `ALU_MULHSU)||(ALUop_wire == `ALU_MULHU))
            ALUSel_o = 1'd1;
        else 
            ALUSel_o = 1'd0;
    end

    always_comb begin
        if (hazard_stall || (pc_i == 32'd0)) begin
            jump_o = 1'd0;
            Branch_o = 1'd0;
            StoreCon_o = 2'd0;
            LoadCon_o = 3'd0;
            WEB_o = 4'b1111;
            MemRead_o = 1'd0;
            rdsrc_o = 3'd0;
            RegWrite_o = 1'd0;
            MemtoReg_o = 1'd1;
            ALUSrc_o = 1'd0;
            ALUop_o = 6'd0;
			raddr1_o = 5'd0;
			raddr2_o = 5'd0;
			rd_o     = 5'd0;
            
            WFI_o = 1'd0;
            CSR_return_o = 1'd0;
            CSRWrite_o = 1'd0;
            CSR_ALUSrc_o = 1'd0;
            CSR_ALUop_o = 2'd0;
        end else begin
            jump_o = jump_wire;
            Branch_o = Branch_wire;
            StoreCon_o = StoreCon_wire;
            LoadCon_o = LoadCon_wire;
            WEB_o = WEB_wire;
            MemRead_o = MemRead_wire;
            rdsrc_o = rdsrc_wire;
            RegWrite_o = RegWrite_wire;
            MemtoReg_o = MemtoReg_wire;
            ALUSrc_o = ALUSrc_wire;
            ALUop_o = ALUop_wire;
			raddr1_o = inst_i[19:15];
			raddr2_o = inst_i[24:20];
			rd_o     = inst_i[11: 7];

            WFI_o = WFI_wire;
            CSR_return_o = CSR_return_wire;
            CSRWrite_o = CSRWrite_wire;
            CSR_ALUSrc_o = CSR_ALUSrc_wire;
            CSR_ALUop_o = CSR_ALUop_wire;
        end
    end

endmodule

    
