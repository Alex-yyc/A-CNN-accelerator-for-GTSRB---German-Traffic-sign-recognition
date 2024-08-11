`include "CPU/store_control.sv"
`include "CPU/load_control.sv"

module Stage_MEM (
    input clk, rst,

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
    output logic RegWrite_o,
    // data out
    output logic [`RegBus]result_o,
    output logic [`RegAddrBus]rd_o,
    // DM
    input [`RegBus]DO_i,
    output logic [`RegBus]store_data, //DI
    // mem stall
    //output logic MemStall, //HW1
    // new csr
    output logic CSRWrite_o,
    output logic CSR_return_o,
    output logic [11:0]CSR_waddr_o,
    output logic [`RegBus]CSR_wdata_o
);
	

	// --------------- mem stall -------------------- HW1
    /*
	logic mstall, stall_end;
    always_comb begin
        if (MemRead_i==1'd1) begin
            mstall = 1'd0;
        end else begin
            mstall = 1'd0;
        end
    end

	always_ff @( posedge clk or posedge rst) begin
   	  if(rst) stall_end <= 1'b0;
        else if(mstall) stall_end <= ~stall_end;
        else stall_end <= 1'b0;
    end 
    */

	//assign MemStall = 1'b0; 
    

    // --------------- mem stage --------------------

    logic [`RegBus]load_data, mux2_result;
	assign RegWrite_o = RegWrite_i;
	assign rd_o = rd_i;
    // new csr
    assign CSRWrite_o = CSRWrite_i;
    assign CSR_return_o = CSR_return_i;
    assign CSR_waddr_o = CSR_waddr_i;
    assign CSR_wdata_o = CSR_wdata_i;

    store_control s_c(.in(rdata2_i), .StoreCon(StoreCon_i), .addr(ALU_result_i[1:0]), .out(store_data));
    load_control l_c(.in(DO_i), .LoadCon(LoadCon_i), .addr(ALU_result_i[1:0]), .out(load_data));
    mux_2to1 mux2(.i1(load_data), .i2(ALU_result_i), .sel(MemtoReg_i), .result(mux2_result));
    mux_5to1 mux5(.i1(mux2_result), .i2(pc4_i), .i3(pcimm_i), .i4(imm_i), .i5(csr_i), .sel(rdsrc_i), .result(result_o));

endmodule

