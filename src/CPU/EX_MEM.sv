

module EX_MEM (
    input clk, rst,
    input stall,

    // control signal in
    input [1:0]StoreCon_i,
    input [2:0]LoadCon_i,
    input [3:0]WEB_i,
    input MemRead_i,
    input [2:0]rdsrc_i,
    input RegWrite_i,
    input MemtoReg_i,
    // data in
    input [`InstBus]pc4_i,
    input [`InstBus]pcimm_i,
    input [`RegBus]ALU_result_i,
    input [`RegBus]rdata2_i,
    input [`RegBus]imm_i,
    input [`RegBus]csr_i,
    input [`RegAddrBus]rd_i,
    // new csr
    input CSRWrite_i, 
    input CSR_return_i,
    input [11:0]CSR_waddr_i,
    input [`RegBus]CSR_wdata_i,

    // control signal out
    output logic [1:0]StoreCon_o,
    output logic [2:0]LoadCon_o,
    output logic [3:0]WEB_o,
    output logic MemRead_o,
    output logic [2:0]rdsrc_o,
    output logic RegWrite_o,
    output logic MemtoReg_o,
    // data out
    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pcimm_o,
    output logic [`RegBus]ALU_result_o,
    output logic [`RegBus]rdata2_o,
    output logic [`RegBus]imm_o,
    output logic [`RegBus]csr_o,
    output logic [`RegAddrBus]rd_o,
    // new csr
    output logic CSRWrite_o,
    output logic CSR_return_o,
    output logic [11:0]CSR_waddr_o,
    output logic [`RegBus]CSR_wdata_o

);

//------------------control signal---------------
	logic MemR_r, RegW_r, MtoR_r;
    logic [1:0] Stor_r;
    logic [2:0] Load_r, rdsrc_r;
	logic [3:0] WEB_r;

	always_comb begin
		MemRead_o = MemR_r;
		RegWrite_o = RegW_r; 
		MemtoReg_o = MtoR_r;
		StoreCon_o = Stor_r;
		LoadCon_o = Load_r;
		rdsrc_o = rdsrc_r;
		WEB_o = WEB_r;
	end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        MemR_r <= 1'd0;  
        else if (stall) MemR_r <= MemR_r;
        else            MemR_r <= MemRead_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        RegW_r <= 1'd0;  
        else if (stall) RegW_r <= RegW_r;
        else            RegW_r <= RegWrite_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        MtoR_r <= 1'd0;  
        else if (stall) MtoR_r <= MtoR_r;
        else            MtoR_r <= MemtoReg_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        Stor_r <= 2'd0;  
        else if (stall) Stor_r <= Stor_r;
        else            Stor_r <= StoreCon_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        Load_r <= 3'd0;  
        else if (stall) Load_r <= Load_r;
        else            Load_r <= LoadCon_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rdsrc_r <= 3'd0;  
        else if (stall) rdsrc_r <= rdsrc_r;
        else            rdsrc_r <= rdsrc_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        WEB_r <= 4'b1111;  
        else if (stall) WEB_r <= WEB_r;
        else            WEB_r <= WEB_i;
    end

//---------------------data---------------------
	logic [31:0] pc4_r, pcimm_r, alu_r, rs2_r, imm_r, csr_r;
	logic [4:0] rd_r;

	always_comb begin
		pc4_o = pc4_r;
		pcimm_o = pcimm_r;
		ALU_result_o = alu_r;
		rdata2_o = rs2_r;
		imm_o = imm_r;
		csr_o = csr_r;
		rd_o = rd_r;
	end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        pc4_r <= 32'd0;  
        else if (stall) pc4_r <= pc4_r;
        else            pc4_r <= pc4_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        pcimm_r <= 32'd0;  
        else if (stall) pcimm_r <= pcimm_r;
        else            pcimm_r <= pcimm_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        alu_r <= 32'd0;  
        else if (stall) alu_r <= alu_r;
        else            alu_r <= ALU_result_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rs2_r <= 32'd0;  
        else if (stall) rs2_r <= rs2_r;
        else            rs2_r <= rdata2_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        imm_r <= 32'd0;  
        else if (stall) imm_r <= imm_r;
        else            imm_r <= imm_i;
    end

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        csr_r <= 32'd0;  
        else if (stall) csr_r <= csr_r;
        else            csr_r <= csr_i;
    end
    
	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        rd_r <= 5'd0;  
        else if (stall) rd_r <= rd_r;
        else            rd_r <= rd_i;
    end
   
//----------------------csr----------------------
    logic CSRWrite_r, CSR_return_r;
    logic [11:0]CSR_waddr_r;
    logic [`RegBus]CSR_wdata_r;

    always_comb begin
        CSRWrite_o = CSRWrite_r;
        CSR_return_o = CSR_return_r;
        CSR_waddr_o = CSR_waddr_r;
        CSR_wdata_o = CSR_wdata_r;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if (rst)        CSRWrite_r <= 1'd0;  
        else if (stall) CSRWrite_r <= CSRWrite_r;
        else            CSRWrite_r <= CSRWrite_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if (rst)        CSR_return_r <= 1'd0;  
        else if (stall) CSR_return_r <= CSR_return_r;
        else            CSR_return_r <= CSR_return_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if (rst)        CSR_waddr_r <= 12'd0;  
        else if (stall) CSR_waddr_r <= CSR_waddr_r;
        else            CSR_waddr_r <= CSR_waddr_i;
    end

    always_ff @ (posedge clk or posedge rst) begin
        if (rst)        CSR_wdata_r <= 32'd0;  
        else if (stall) CSR_wdata_r <= CSR_wdata_r;
        else            CSR_wdata_r <= CSR_wdata_i;
    end


endmodule
