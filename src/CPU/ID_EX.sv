module ID_EX (
    input clk, rst,
    input flush,
    input stall,

    // pc 
    input [`InstBus]pc4_i,
    input [`InstBus]pc_i,
    // control signal 
    input jump_i,
    input Branch_i,
    input PCsel_i,
    input [1:0]StoreCon_i,
    input [2:0]LoadCon_i,
    input [3:0]WEB_i,
    input MemRead_i,
    input [2:0]rdsrc_i,
    input RegWrite_i,
    input MemtoReg_i,
    input ALUSrc_i,
    input [5:0]ALUop_i,
    input ALUSel_i,
	// rs1 rs2
	input [`RegBus]rdata1_i,
	input [`RegBus]rdata2_i,
    //imm
    input [`RegBus]imm_i,
    //csr
    input [`RegBus]csr_i,
    // to forwarding
    input [`RegAddrBus]raddr1_i,
    input [`RegAddrBus]raddr2_i,
    input [`RegAddrBus]rd_i,
    // new csr
    input CSR_return_i,
    input CSR_ALUSrc_i,
    input [1:0]CSR_ALUop_i,
    input WFI_i,
    input CSRWrite_i,
    input [11:0] CSR_waddr_i,

    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pc_o,
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
    output logic [`RegBus]rdata1_o,
    output logic [`RegBus]rdata2_o,
    output logic [`RegBus]imm_o,
    output logic [`RegBus]csr_o,
    output logic [`RegAddrBus]raddr1_o,
    output logic [`RegAddrBus]raddr2_o,
    output logic [`RegAddrBus]rd_o,
    //new csr
    output logic CSR_return_o,
    output logic CSR_ALUSrc_o,
    output logic [1:0]CSR_ALUop_o,
    output logic WFI_o,
    output logic CSRWrite_o,
    output logic [11:0]CSR_waddr_o
);
    
// -------- control signal ----------
    logic jump_r, Bran_r, PCs_r, MemR_r, RegW_r, MtoR_r, ALUsrc_r, ALUSel_r;
    logic [1:0] Stor_r;
    logic [2:0] Load_r, rdsrc_r;
	logic [3:0] WEB_r;
	logic [5:0] ALUop_r;

	always_comb begin
		jump_o = jump_r;
		Branch_o = Bran_r;
		PCsel_o = PCs_r;
		MemRead_o = MemR_r;
		RegWrite_o = RegW_r; 
		MemtoReg_o = MtoR_r;
		ALUSrc_o = ALUsrc_r;
		StoreCon_o = Stor_r;
		LoadCon_o = Load_r;
		rdsrc_o = rdsrc_r;
		WEB_o = WEB_r;
		ALUop_o = ALUop_r;
		ALUSel_o = ALUSel_r;
	end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        jump_r <= 1'd0;  
        else if (stall) jump_r <= jump_r;
        else if (flush) jump_r <= 1'd0;
        else            jump_r <= jump_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        Bran_r <= 1'd0;  
        else if (stall) Bran_r <= Bran_r;
        else if (flush) Bran_r <= 1'd0;
        else            Bran_r <= Branch_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        PCs_r <= 1'd0;  
        else if (stall) PCs_r <= PCs_r;
        else if (flush) PCs_r <= 1'd0;
        else            PCs_r <= PCsel_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        MemR_r <= 1'd0;  
        else if (stall) MemR_r <= MemR_r;
        else if (flush) MemR_r <= 1'd0;
        else            MemR_r <= MemRead_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        RegW_r <= 1'd0;  
        else if (stall) RegW_r <= RegW_r;
        else if (flush) RegW_r <= 1'd0;
        else            RegW_r <= RegWrite_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        MtoR_r <= 1'd0;  
        else if (stall) MtoR_r <= MtoR_r;
        else if (flush) MtoR_r <= 1'd0;
        else            MtoR_r <= MemtoReg_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        ALUsrc_r <= 1'd0;  
        else if (stall) ALUsrc_r <= ALUsrc_r;
        else if (flush) ALUsrc_r <= 1'd0;
        else            ALUsrc_r <= ALUSrc_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        Stor_r <= 2'd0;  
        else if (stall) Stor_r <= Stor_r;
        else if (flush) Stor_r <= 2'd0;
        else            Stor_r <= StoreCon_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        Load_r <= 3'd0;  
        else if (stall) Load_r <= Load_r;
        else if (flush) Load_r <= 3'd0;
        else            Load_r <= LoadCon_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rdsrc_r <= 3'd0;  
        else if (stall) rdsrc_r <= rdsrc_r;
        else if (flush) rdsrc_r <= 3'd0;
        else            rdsrc_r <= rdsrc_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        WEB_r <= 4'b1111;  
        else if (stall) WEB_r <= WEB_r;
        else if (flush) WEB_r <= 4'b1111;
        else            WEB_r <= WEB_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        ALUop_r <= 6'd0;  
        else if (stall) ALUop_r <= ALUop_r;
        else if (flush) ALUop_r <= 6'd0;
        else            ALUop_r <= ALUop_i;
    end

            always_ff @ (posedge clk or posedge rst) begin
        if (rst)        ALUSel_r <= 1'd0;  
        else if (stall) ALUSel_r <= ALUSel_r;
        else if (flush) ALUSel_r <= 1'd0;
        else            ALUSel_r <= ALUSel_i;
    end

// ---------- data -----------
	logic [31:0] pc4_r, pc_r, rdata1_r, rdata2_r, imm_r, csr_r;
	logic [4:0] raddr1_r, raddr2_r, rd_r;

	always_comb begin
		pc4_o = pc4_r;
		pc_o = pc_r;
		rdata1_o = rdata1_r;
		rdata2_o = rdata2_r;
		imm_o = imm_r;
		csr_o = csr_r;
		raddr1_o = raddr1_r;
		raddr2_o = raddr2_r;
		rd_o = rd_r;
	end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        pc4_r <= 32'd0;  
        else if (stall) pc4_r <= pc4_r;
        else if (flush) pc4_r <= 32'd0;
        else            pc4_r <= pc4_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        pc_r <= 32'd0;  
        else if (stall) pc_r <= pc_r;
        //else if (flush) pc_r <= 32'd0;
        else            pc_r <= pc_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rdata1_r <= 32'd0;  
        else if (stall) rdata1_r <= rdata1_r;
        else if (flush) rdata1_r <= 32'd0;
        else            rdata1_r <= rdata1_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rdata2_r <= 32'd0;  
        else if (stall) rdata2_r <= rdata2_r;
        else if (flush) rdata2_r <= 32'd0;
        else            rdata2_r <= rdata2_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        imm_r <= 32'd0;  
        else if (stall) imm_r <= imm_r;
        else if (flush) imm_r <= 32'd0;
        else            imm_r <= imm_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        csr_r <= 32'd0;  
        else if (stall) csr_r <= csr_r;
        //else if (flush) csr_r <= 32'd0;
        else            csr_r <= csr_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        raddr1_r <= 5'd0;  
        else if (stall) raddr1_r <= raddr1_r;
        else if (flush) raddr1_r <= 5'd0;
        else            raddr1_r <= raddr1_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        raddr2_r <= 5'd0;  
        else if (stall) raddr2_r <= raddr2_r;
        else if (flush) raddr2_r <= 5'd0;
        else            raddr2_r <= raddr2_i;
    end
    
	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rd_r <= 5'd0;  
        else if (stall) rd_r <= rd_r;
        else if (flush) rd_r <= 5'd0;
        else            rd_r <= rd_i;
    end

// -----------------csr--------------------
    logic CSR_return_r, CSR_ALUSrc_r, WFI_r, CSRWrite_r;
    logic [1:0]CSR_ALUop_r;
    logic [11:0]CSR_waddr_r;

    always_comb begin
        CSR_return_o = CSR_return_r;
        CSR_ALUSrc_o = CSR_ALUSrc_r;
        CSR_ALUop_o = CSR_ALUop_r;
        WFI_o = WFI_r;
        CSRWrite_o = CSRWrite_r;
        CSR_waddr_o = CSR_waddr_r;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         CSR_return_r <= 1'd0;  
        else if (stall) CSR_return_r <= CSR_return_r;
        //else if (flush) CSR_return_r <= 1'd0;
        else            CSR_return_r <= CSR_return_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         CSR_ALUSrc_r <= 1'd0;  
        else if (stall) CSR_ALUSrc_r <= CSR_ALUSrc_r;
        else if (flush) CSR_ALUSrc_r <= 1'd0;
        else            CSR_ALUSrc_r <= CSR_ALUSrc_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         WFI_r <= 1'd0;  
        else if (stall) WFI_r <= WFI_r;
        else if (flush) WFI_r <= 1'd0; //revise
        else            WFI_r <= WFI_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         CSRWrite_r <= 1'd0;  
        else if (stall) CSRWrite_r <= CSRWrite_r;
        else if (flush) CSRWrite_r <= 1'd0;
        else            CSRWrite_r <= CSRWrite_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         CSR_ALUop_r <= 2'd0;  
        else if (stall) CSR_ALUop_r <= CSR_ALUop_r;
        else if (flush) CSR_ALUop_r <= 2'd0;
        else            CSR_ALUop_r <= CSR_ALUop_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if(rst)         CSR_waddr_r <= 12'd0;  
        else if (stall) CSR_waddr_r <= CSR_waddr_r;
        else if (flush) CSR_waddr_r <= 12'd0;
        else            CSR_waddr_r <= CSR_waddr_i;
    end


endmodule

