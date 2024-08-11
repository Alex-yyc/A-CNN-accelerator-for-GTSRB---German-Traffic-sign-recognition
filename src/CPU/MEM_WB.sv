

module MEM_WB (
    input clk, rst,
    input stall,

    // control signal in
    input RegWrite_i,
     // data in
    input [`RegBus]result_i,
    input [`RegAddrBus]rd_i,
    // new csr
    input CSRWrite_i, 
    input CSR_return_i,
    input [11:0]CSR_waddr_i,
    input [`RegBus]CSR_wdata_i,

    // control signal out
    output logic RegWrite_o,
    // data out
    output logic [`RegBus]result_o,
    output logic [`RegAddrBus]rd_o,
    // new csr
    output logic CSRWrite_o,
    output logic CSR_return_o,
    output logic [11:0]CSR_waddr_o,
    output logic [`RegBus]CSR_wdata_o

);

//------------------control signal---------------
	logic RegW_r;
	assign RegWrite_o = RegW_r;
	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        RegW_r <= 1'd0;  
        else if (stall) RegW_r <= RegW_r;
        else            RegW_r <= RegWrite_i;
    end

//---------------------data---------------------
	logic [`RegBus] result_r;
	logic [4:0] rd_r;
	assign result_o = result_r;
	assign rd_o = rd_r;

	always_ff @ (posedge clk or posedge rst) begin
        if (rst)        result_r <= 32'd0;  
        else if (stall) result_r <= result_r;
        else            result_r <= result_i;
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
