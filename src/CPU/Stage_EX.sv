`include "CPU/alu.sv"
`include "CPU/m_alu.sv"
`include "CPU/forwarding_unit.sv"
`include "CPU/csr_alu.sv"
`include "CPU/csr_forwarding.sv"

module Stage_EX (
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
    // pc 
    input [`InstBus]pc4_i,
    input [`InstBus]pc_i,
    //reg data
    input [`RegBus]rdata1_i,
    input [`RegBus]rdata2_i,
    //imm
    input [`RegBus]imm_i,
    //csr
    input [`RegBus]csr_i,
    // to forwarding
    input [`RegAddrBus]raddr1_i,    //ID_EX_Rs
    input [`RegAddrBus]raddr2_i,    //ID_EX_Rt
    input [`RegAddrBus]rd_i,        //from id/ex
    input [`RegAddrBus]EX_MEM_Rd,   
    input [`RegAddrBus]MEM_WB_Rd,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    // forwarding data
    input [`RegBus]MEM_result_i,
    input [`RegBus]WB_result_i,
    // new csr 
    input WFI_i,
    input interrupt_dma_epu,
    input CSR_return_i,
    input CSR_ALUSrc_i,
    input CSRWrite_i,
    input [1:0] CSR_ALUop_i,
    input [11:0] CSR_waddr_i,
    // csr forwarding
    input MEM_CSRWrite_i,
    input WB_CSRWrite_i,
    input [11:0]MEM_CSR_waddr_i,
    input [11:0]WB_CSR_waddr_i,
    input [`RegBus]MEM_CSR_wdata_i,
    input [`RegBus]WB_CSR_wdata_i,

    // control signal out
    output logic [1:0]StoreCon_o,
    output logic [2:0]LoadCon_o,
    output logic [3:0]WEB_o,
    output logic MemRead_o,
    output logic [2:0]rdsrc_o,
    output logic RegWrite_o,
    output logic MemtoReg_o,
    //pc
    output logic [`InstBus]pc4_o,
    output logic [`InstBus]pcimm_o,
    //data
    output logic [`RegBus]ALU_result_o,
    output logic [`RegBus]rdata2_o,
    output logic [`RegBus]imm_o,
    output logic [`RegBus]csr_o,
    output logic [`RegAddrBus]rd_o,
    //flush
    output logic flush,
    output logic [`InstBus]pc_new,
    //csr
    output logic CSR_return_o,
    output logic CSRWrite_o,
    output logic [11:0]CSR_waddr_o,
    output logic [`RegBus]CSR_wdata_o

);

    logic zero_flag;
    logic [1:0] ForwardA, ForwardB, FowardCSR;
    logic [11:0] FowardCSR_imm;
    logic [`RegBus] muxA_result, muxB_result, muxC_result, CSRmux_result, CSRforward_result, ALU_result, MUL_result;
    logic [`InstBus] mux1_result, pc_temp;

    // control signal
    assign StoreCon_o = StoreCon_i;
    assign LoadCon_o = LoadCon_i;
    assign WEB_o = WEB_i;
    assign MemRead_o = MemRead_i;
    assign rdsrc_o = rdsrc_i;
    assign RegWrite_o = RegWrite_i;
    assign MemtoReg_o = MemtoReg_i;
    // data
    assign pc4_o = pc4_i;
    assign rdata2_o = muxC_result;
    assign imm_o = imm_i;
    assign csr_o = CSRforward_result;
    assign rd_o = rd_i;
    assign pcimm_o = pc_i + imm_i;
    // flush
    assign flush = (Branch_i & zero_flag) | jump_i | WFI_i | CSR_return_i;


    //final
    assign pc_new = (interrupt_dma_epu) ? 32'h0000_1000 : pc_temp;

    alu alu1(.in1(muxB_result), .in2(muxA_result), .ALUop(ALUop_i), .result(ALU_result), .zero_flag(zero_flag));
    forwarding_unit fu(.EX_MEM_RegWrite(EX_MEM_RegWrite), .MEM_WB_RegWrite(MEM_WB_RegWrite), .EX_MEM_Rd(EX_MEM_Rd), .MEM_WB_Rd(MEM_WB_Rd), .ID_EX_Rs(raddr1_i), .ID_EX_Rt(raddr2_i), .ForwardA(ForwardA), .ForwardB(ForwardB));

    mux_3to1 muxC(.i1(rdata2_i), .i2(WB_result_i), .i3(MEM_result_i), .sel(ForwardB), .result(muxC_result));
    mux_2to1 muxA(.i1(muxC_result), .i2(imm_i), .sel(ALUSrc_i), .result(muxA_result));
    mux_3to1 muxB(.i1(rdata1_i), .i2(WB_result_i), .i3(MEM_result_i), .sel(ForwardA), .result(muxB_result));
    mux_2to1 mux1(.i1(pcimm_o), .i2(ALU_result), .sel(PCsel_i), .result(mux1_result));

    m_alu malu(.in1(muxB_result), .in2(muxA_result), .ALUop(ALUop_i), .result(MUL_result));
    mux_2to1 mux_alu(.i1(ALU_result), .i2(MUL_result), .sel(ALUSel_i), .result(ALU_result_o));

    //new
    assign CSRWrite_o = CSRWrite_i;
    assign CSR_return_o = CSR_return_i;
    assign CSR_waddr_o = CSR_waddr_i;
    csr_alu alu2(.data(CSRmux_result), .csr(CSRforward_result), .CSR_ALUop(CSR_ALUop_i), .csr_result(CSR_wdata_o));
    csr_forwarding cfu(.MEM_CSRWrite(MEM_CSRWrite_i), .WB_CSRWrite(WB_CSRWrite_i), .EX_CSR_waddr(CSR_waddr_i), .MEM_CSR_waddr(MEM_CSR_waddr_i), .WB_CSR_waddr(WB_CSR_waddr_i), .FowardCSR(FowardCSR), .FowardCSR_imm(FowardCSR_imm));

    mux_2to1 CSRmuxA(.i1(muxB_result), .i2(imm_i), .sel(CSR_ALUSrc_i), .result(CSRmux_result));
    mux_3to1_csr CSRmuxB(.i1(csr_i), .i2(MEM_CSR_wdata_i), .i3(WB_CSR_wdata_i), .sel(FowardCSR), .CSR_imm(FowardCSR_imm), .result(CSRforward_result));
    mux_2to1 mux2(.i1(mux1_result), .i2(csr_i), .sel(WFI_i | CSR_return_i), .result(pc_temp));

endmodule

