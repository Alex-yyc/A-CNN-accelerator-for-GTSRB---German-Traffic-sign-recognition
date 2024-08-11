//*********************************************************
// Auther:      N26111512           
// Filename:    CPU.sv                            
// Description: Top module of CPU                   
// Version:     3.0 
//*********************************************************
`include "CPU/Stage_IF.sv"
`include "CPU/Stage_ID.sv"
`include "CPU/Stage_EX.sv"
`include "CPU/Stage_MEM.sv"
`include "CPU/Stage_WB.sv"
`include "CPU/IF_ID.sv"
`include "CPU/ID_EX.sv"
`include "CPU/EX_MEM.sv"
`include "CPU/MEM_WB.sv"
`include "CPU/mux.sv"

module CPU (
    input clk, 
    input rst,

    input CPU_STALL,		// inst, data stall
    input interrupt,   // WFI
    input interrupt_dma_epu, //dma&epu
    input [`InstBus]IM_data,
    input [`RegBus]DM_DO,

    output logic [`InstAddrBus]IM_addr,
    output logic [`InstAddrBus]DM_A,
    output logic [`RegBus]DM_DI,
    output logic [3:0]DM_WEB,
    output logic IM_OE,
    output logic DM_OE
);

  ////////////////////////////////
  // Variables
  //
    // forwarding / jump / stall / hazard 
    logic hazard_stall, flush, stall, CPU_ALL_STALL; 
    logic [`InstBus] EX_pc_new;
    //========================= IF to reg =========================
    logic [`InstBus] IF_pc4_o, IF_pc_o, IF_inst_o;
    //========================= reg to ID =========================
    logic [`InstBus] ID_inst_i, ID_pc4_i, ID_pc_i;
    //========================= ID to reg =========================
    logic ID_jump_o, ID_Branch_o, ID_MemRead_o, ID_RegWrite_o, ID_MemtoReg_o, ID_ALUSrc_o, ID_PCsel_o, ID_ALUSel_o;
    logic [1:0] ID_StoreCon_o;
    logic [2:0] ID_LoadCon_o, ID_rdsrc_o;
    logic [3:0] ID_WEB_o;
    logic [5:0] ID_ALUop_o;
    logic [`InstBus] ID_pc4_o, ID_pc_o;
    logic [`RegAddrBus] ID_raddr1_o, ID_raddr2_o, ID_rd_o;
    logic [`RegBus] ID_rdata1_o, ID_rdata2_o, ID_imm_o, ID_csr_o;
    // new csr
    logic ID_CSR_return_o, ID_WFI_o, ID_CSRWrite_o, ID_CSR_ALUSrc_o;
    logic [1:0] ID_CSR_ALUop_o;
    logic [11:0] ID_CSR_waddr_o;
    //========================= reg to EXE =========================
    logic EX_jump_i, EX_Branch_i, EX_MemRead_i, EX_RegWrite_i, EX_MemtoReg_i, EX_ALUSrc_i, EX_PCsel_i, EX_ALUSel_i;
    logic [1:0] EX_StoreCon_i;
    logic [2:0] EX_LoadCon_i, EX_rdsrc_i;
    logic [3:0] EX_WEB_i;
    logic [5:0] EX_ALUop_i;
    logic [`InstBus] EX_pc4_i, EX_pc_i;
    logic [`RegAddrBus] EX_raddr1_i, EX_raddr2_i, EX_rd_i;
    logic [`RegBus] EX_rdata1_i, EX_rdata2_i, EX_imm_i, EX_csr_i;
    // new csr
    logic EX_CSR_return_i, EX_WFI_i, EX_CSRWrite_i, EX_CSR_ALUSrc_i;
    logic [1:0] EX_CSR_ALUop_i;
    logic [11:0] EX_CSR_waddr_i;
    //========================= EXE to reg =========================
    logic EX_MemRead_o, EX_RegWrite_o, EX_MemtoReg_o;
    logic [1:0] EX_StoreCon_o;
    logic [2:0] EX_LoadCon_o, EX_rdsrc_o;
    logic [3:0] EX_WEB_o;
    logic [`InstBus] EX_pc4_o, EX_pcimm_o;
    logic [`RegAddrBus] EX_rd_o;
    logic [`RegBus] EX_ALU_result_o, EX_rdata2_o, EX_imm_o, EX_csr_o;
    // new csr
    logic EX_CSRWrite_o, EX_CSR_return_o;
    logic [11:0] EX_CSR_waddr_o;
    logic [`RegBus] EX_CSR_wdata_o;
    //========================= reg to MEM =========================
    logic MEM_MemRead_i, MEM_RegWrite_i, MEM_MemtoReg_i;
    logic [1:0] MEM_StoreCon_i;
    logic [2:0] MEM_LoadCon_i, MEM_rdsrc_i;
    logic [3:0] MEM_WEB_i;
    logic [`InstBus] MEM_pc4_i, MEM_pcimm_i;
    logic [`RegAddrBus] MEM_rd_i;
    logic [`RegBus] MEM_ALU_result_i, MEM_rdata2_i, MEM_imm_i, MEM_csr_i;
    // new csr
    logic MEM_CSRWrite_i, MEM_CSR_return_i;
    logic [11:0] MEM_CSR_waddr_i;
    logic [`RegBus] MEM_CSR_wdata_i;
    //========================= MEM to reg =========================
    logic MEM_RegWrite_o;
    logic [`RegAddrBus] MEM_rd_o;
    logic [`RegBus] MEM_result_o, EX_MEM_data_o;
    // new csr
    logic MEM_CSR_return_o, MEM_CSRWrite_o;
    logic [11:0] MEM_CSR_waddr_o;
    logic [`RegBus] MEM_CSR_wdata_o;
    //========================= reg to WB =========================
    logic WB_RegWrite_i;
    logic [`RegAddrBus] WB_rd_i;
    logic [`RegBus] WB_result_i;
    // new csr
    logic WB_CSR_return_i;
    logic [11:0] WB_CSR_waddr_i;
    logic [`RegBus] WB_CSR_wdata_i;
    //========================= wb to ID =========================
    logic WB_RegWrite_o;
    logic [`RegBus] WB_result_o;
    logic [`RegAddrBus] WB_rd_o;


  ////////////////////////////////
  // Module Body
  //
    assign IM_OE = 1'b1;
    assign DM_A = MEM_ALU_result_i;
		assign flush2 = flush | ID_jump_o;

    always_comb begin
				if      (EX_WFI_i)  CPU_ALL_STALL = ~(interrupt | interrupt_dma_epu);
				else if (CPU_STALL) CPU_ALL_STALL = 1'd1;
				else 								CPU_ALL_STALL = 1'd0;
    end

    Stage_IF f(.clk(clk), .rst(rst), .hazard_stall(hazard_stall), .MemStall(CPU_ALL_STALL), .flush(flush), .pc_new(EX_pc_new),//input
               .pc4_o(IF_pc4_o), .pc_o(IF_pc_o), .inst_addr_o(IM_addr)); //output

    IF_ID fd(.clk(clk), .rst(rst), .hazard_stall(hazard_stall), .MemStall(CPU_ALL_STALL), .flush(flush2), .pc4_i(IF_pc4_o), .pc_i(IF_pc_o), .inst_i(IM_data), //input
             .pc4_o(ID_pc4_i), .pc_o(ID_pc_i), .inst_o(ID_inst_i)); //output

    Stage_ID d(.clk(clk), .rst(rst), .pc4_i(ID_pc4_i), .pc_i(ID_pc_i), .inst_i(ID_inst_i), .RegWrite_i(WB_RegWrite_o), .waddr_i(WB_rd_o), .wdata_i(WB_result_o), .ID_EX_Rt_i(EX_rd_o), .ID_EX_MemRead(EX_MemRead_i), .flush(flush), .MemStall(CPU_ALL_STALL),  //input
               .pc4_o(ID_pc4_o), .pc_o(ID_pc_o), .jump_o(ID_jump_o), .Branch_o(ID_Branch_o), .PCsel_o(ID_PCsel_o), .StoreCon_o(ID_StoreCon_o), .LoadCon_o(ID_LoadCon_o), .WEB_o(ID_WEB_o), .MemRead_o(ID_MemRead_o), .rdsrc_o(ID_rdsrc_o), .RegWrite_o(ID_RegWrite_o), .MemtoReg_o(ID_MemtoReg_o), .ALUSrc_o(ID_ALUSrc_o), .ALUop_o(ID_ALUop_o), .ALUSel_o(ID_ALUSel_o), // control
               .rdata1_o(ID_rdata1_o), .rdata2_o(ID_rdata2_o), .imm_o(ID_imm_o), .csr_o(ID_csr_o), .raddr1_o(ID_raddr1_o), .raddr2_o(ID_raddr2_o), .rd_o(ID_rd_o), .hazard_stall(hazard_stall),  // data out
               .CSRWrite_i(WB_CSRWrite_i), .CSR_return_i(WB_CSR_return_i), .CSR_waddr_i(WB_CSR_waddr_i), .CSR_wdata_i(WB_CSR_wdata_i), .interrupt(interrupt),  .interrupt_dma_epu(interrupt_dma_epu),// new csr input
               .WFI_o(ID_WFI_o), .CSR_return_o(ID_CSR_return_o), .CSR_ALUop_o(ID_CSR_ALUop_o), .CSR_ALUSrc_o(ID_CSR_ALUSrc_o), .CSRWrite_o(ID_CSRWrite_o), .CSR_waddr_o(ID_CSR_waddr_o));  //  new csr output 

    ID_EX de(.clk(clk), .rst(rst), .stall(CPU_ALL_STALL), .jump_i(ID_jump_o), .Branch_i(ID_Branch_o), .pc4_i(ID_pc4_o), .pc_i(ID_pc_o), 
             .PCsel_i(ID_PCsel_o), .StoreCon_i(ID_StoreCon_o), .LoadCon_i(ID_LoadCon_o), .WEB_i(ID_WEB_o), .MemRead_i(ID_MemRead_o), .rdsrc_i(ID_rdsrc_o), .RegWrite_i(ID_RegWrite_o), .MemtoReg_i(ID_MemtoReg_o), .ALUSrc_i(ID_ALUSrc_o), .ALUop_i(ID_ALUop_o), .ALUSel_i(ID_ALUSel_o), // control in
             .rdata1_i(ID_rdata1_o), .rdata2_i(ID_rdata2_o), .imm_i(ID_imm_o), .csr_i(ID_csr_o), .raddr1_i(ID_raddr1_o), .raddr2_i(ID_raddr2_o), .rd_i(ID_rd_o), // data in
             .pc4_o(EX_pc4_i), .pc_o(EX_pc_i), .jump_o(EX_jump_i), .Branch_o(EX_Branch_i), .PCsel_o(EX_PCsel_i), .StoreCon_o(EX_StoreCon_i), .LoadCon_o(EX_LoadCon_i), .WEB_o(EX_WEB_i), .MemRead_o(EX_MemRead_i), .rdsrc_o(EX_rdsrc_i), .RegWrite_o(EX_RegWrite_i), .MemtoReg_o(EX_MemtoReg_i), .ALUSrc_o(EX_ALUSrc_i), .ALUop_o(EX_ALUop_i), .ALUSel_o(EX_ALUSel_i),// control out
             .rdata1_o(EX_rdata1_i), .rdata2_o(EX_rdata2_i), .imm_o(EX_imm_i), .csr_o(EX_csr_i), .raddr1_o(EX_raddr1_i), .raddr2_o(EX_raddr2_i), .rd_o(EX_rd_i), .flush(flush), //data out
             .CSR_return_i(ID_CSR_return_o), .CSR_ALUSrc_i(ID_CSR_ALUSrc_o), .CSR_ALUop_i(ID_CSR_ALUop_o), .WFI_i(ID_WFI_o), .CSRWrite_i(ID_CSRWrite_o), .CSR_waddr_i(ID_CSR_waddr_o),   // new csr input
             .CSR_return_o(EX_CSR_return_i), .CSR_ALUSrc_o(EX_CSR_ALUSrc_i), .CSR_ALUop_o(EX_CSR_ALUop_i), .WFI_o(EX_WFI_i), .CSRWrite_o(EX_CSRWrite_i), .CSR_waddr_o(EX_CSR_waddr_i));  // nex csr output

    Stage_EX e(.jump_i(EX_jump_i), .Branch_i(EX_Branch_i), .PCsel_i(EX_PCsel_i), .StoreCon_i(EX_StoreCon_i), .LoadCon_i(EX_LoadCon_i), .WEB_i(EX_WEB_i), .MemRead_i(EX_MemRead_i), .rdsrc_i(EX_rdsrc_i), .RegWrite_i(EX_RegWrite_i), .MemtoReg_i(EX_MemtoReg_i), .ALUSrc_i(EX_ALUSrc_i), .ALUop_i(EX_ALUop_i), .ALUSel_i(EX_ALUSel_i),
               .pc4_i(EX_pc4_i), .pc_i(EX_pc_i), .rdata1_i(EX_rdata1_i), .rdata2_i(EX_rdata2_i), .imm_i(EX_imm_i), .csr_i(EX_csr_i), .raddr1_i(EX_raddr1_i), .raddr2_i(EX_raddr2_i), .rd_i(EX_rd_i), .interrupt_dma_epu(interrupt_dma_epu),
               .EX_MEM_Rd(MEM_rd_i), .MEM_WB_Rd(WB_rd_i), .EX_MEM_RegWrite(MEM_RegWrite_i), .MEM_WB_RegWrite(WB_RegWrite_i), .WB_result_i(WB_result_o), .MEM_result_i(MEM_result_o),  // forwarding
               .StoreCon_o(EX_StoreCon_o), .LoadCon_o(EX_LoadCon_o), .WEB_o(EX_WEB_o), .MemRead_o(EX_MemRead_o), .rdsrc_o(EX_rdsrc_o), .RegWrite_o(EX_RegWrite_o), .MemtoReg_o(EX_MemtoReg_o),
               .pc4_o(EX_pc4_o), .pcimm_o(EX_pcimm_o), .ALU_result_o(EX_ALU_result_o), .rdata2_o(EX_rdata2_o), .imm_o(EX_imm_o), .csr_o(EX_csr_o), .rd_o(EX_rd_o), .pc_new(EX_pc_new), .flush(flush),
               .WFI_i(EX_WFI_i), .CSR_return_i(EX_CSR_return_i), .CSR_ALUSrc_i(EX_CSR_ALUSrc_i), .CSRWrite_i(EX_CSRWrite_i), .CSR_ALUop_i(EX_CSR_ALUop_i), .CSR_waddr_i(EX_CSR_waddr_i),  // new csr input
               .MEM_CSRWrite_i(MEM_CSRWrite_i), .WB_CSRWrite_i(WB_CSRWrite_i), .MEM_CSR_waddr_i(MEM_CSR_waddr_i), .WB_CSR_waddr_i(WB_CSR_waddr_i), .MEM_CSR_wdata_i(MEM_CSR_wdata_i), .WB_CSR_wdata_i(WB_CSR_wdata_i),  // csr forward
               .CSR_return_o(EX_CSR_return_o), .CSRWrite_o(EX_CSRWrite_o), .CSR_waddr_o(EX_CSR_waddr_o), .CSR_wdata_o(EX_CSR_wdata_o)); // new csr output

    EX_MEM em(.clk(clk), .rst(rst), .stall(CPU_ALL_STALL), .StoreCon_i(EX_StoreCon_o), .LoadCon_i(EX_LoadCon_o), .WEB_i(EX_WEB_o), .MemRead_i(EX_MemRead_o), .rdsrc_i(EX_rdsrc_o), .RegWrite_i(EX_RegWrite_o), .MemtoReg_i(EX_MemtoReg_o),
              .pc4_i(EX_pc4_o), .pcimm_i(EX_pcimm_o), .ALU_result_i(EX_ALU_result_o), .rdata2_i(EX_rdata2_o), .imm_i(EX_imm_o), .csr_i(EX_csr_o), .rd_i(EX_rd_o),
              .StoreCon_o(MEM_StoreCon_i), .LoadCon_o(MEM_LoadCon_i), .WEB_o(DM_WEB), .MemRead_o(DM_OE), .rdsrc_o(MEM_rdsrc_i), .RegWrite_o(MEM_RegWrite_i), .MemtoReg_o(MEM_MemtoReg_i),
              .pc4_o(MEM_pc4_i), .pcimm_o(MEM_pcimm_i), .ALU_result_o(MEM_ALU_result_i), .rdata2_o(MEM_rdata2_i), .imm_o(MEM_imm_i), .csr_o(MEM_csr_i), .rd_o(MEM_rd_i),
              .CSRWrite_i(EX_CSRWrite_o), .CSR_return_i(EX_CSR_return_o), .CSR_waddr_i(EX_CSR_waddr_o), .CSR_wdata_i(EX_CSR_wdata_o),    // new csr input
              .CSRWrite_o(MEM_CSRWrite_i), .CSR_return_o(MEM_CSR_return_i), .CSR_waddr_o(MEM_CSR_waddr_i), .CSR_wdata_o(MEM_CSR_wdata_i));   // new csr output

    Stage_MEM m(.clk(clk), .rst(rst), .StoreCon_i(MEM_StoreCon_i), .LoadCon_i(MEM_LoadCon_i), .WEB_i(DM_WEB), .MemRead_i(DM_OE), .rdsrc_i(MEM_rdsrc_i), .RegWrite_i(MEM_RegWrite_i), .MemtoReg_i(MEM_MemtoReg_i),
                .pc4_i(MEM_pc4_i), .pcimm_i(MEM_pcimm_i), .ALU_result_i(MEM_ALU_result_i), .rdata2_i(MEM_rdata2_i), .imm_i(MEM_imm_i), .csr_i(MEM_csr_i), .rd_i(MEM_rd_i),
                .RegWrite_o(MEM_RegWrite_o), .result_o(MEM_result_o), .rd_o(MEM_rd_o), //.MemStall(MemStall),  HW1
                .DO_i(DM_DO), .store_data(DM_DI),  // DM
                .CSRWrite_i(MEM_CSRWrite_i), .CSR_return_i(MEM_CSR_return_i), .CSR_waddr_i(MEM_CSR_waddr_i), .CSR_wdata_i(MEM_CSR_wdata_i),    // new csr input
                .CSRWrite_o(MEM_CSRWrite_o), .CSR_return_o(MEM_CSR_return_o), .CSR_waddr_o(MEM_CSR_waddr_o), .CSR_wdata_o(MEM_CSR_wdata_o));   // new csr output 

    MEM_WB mw(.clk(clk), .rst(rst), .stall(CPU_ALL_STALL), .RegWrite_i(MEM_RegWrite_o), .result_i(MEM_result_o), .rd_i(MEM_rd_o),
              .RegWrite_o(WB_RegWrite_i), .result_o(WB_result_i), .rd_o(WB_rd_i),
              .CSRWrite_i(MEM_CSRWrite_o), .CSR_return_i(MEM_CSR_return_o), .CSR_waddr_i(MEM_CSR_waddr_o), .CSR_wdata_i(MEM_CSR_wdata_o),    // new csr input
              .CSRWrite_o(WB_CSRWrite_i), .CSR_return_o(WB_CSR_return_i), .CSR_waddr_o(WB_CSR_waddr_i), .CSR_wdata_o(WB_CSR_wdata_i));   // new csr output

    Stage_WB w(.RegWrite_i(WB_RegWrite_i), .result_i(WB_result_i), .rd_i(WB_rd_i), .RegWrite_o(WB_RegWrite_o), .result_o(WB_result_o), .rd_o(WB_rd_o));
    
endmodule

