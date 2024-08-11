module control (
    input [6:0]opcode,
	input [2:0]func3,   //control ALUop
	input [6:0]func7,
    input [11:0]CSR_imm,

    output logic [3:0] WEB,     //MemWrite
    //output logic CS,            //SRAM 啟動!!!
    output logic [5:0] ALUop,
    output logic jump,
    output logic Branch,
    output logic MemRead,       
    output logic MemtoReg,      // 0:MEM 1:ALU 
    output logic RegWrite,
	output logic ALUSrc,        // 0:rs2 1:imm
	output logic [2:0]rdsrc,    // 0:mem 1:PC+4 2:PC+imm 3:imm 4:csr
    output logic [2:0]Immop,     // 1:I 2:I_S 3:S 4:B 5:U 6:J 7:CSR
    output logic [2:0]LoadCon,    // Mem load Control
    output logic [1:0]StoreCon,    // Mem store Control
    output logic PCsel,         // 0:pc+imm 1:rs1+imm

    // new CSR
    output logic WFI,
    output logic CSR_return,
    output logic CSRWrite,
    output logic CSR_ALUSrc,
    output logic [1:0] CSR_ALUop  //0:data 1: | 2: &

);
//var
    // R type func3
    parameter ADD_SUB_MUL = 3'b000; 
	parameter SLL_MULH = 3'b001;
	parameter SLT_MULHSU = 3'b010;
	parameter SLTU_MULHU = 3'b011;
	parameter _XOR = 3'b100;
	parameter SRL_SRA = 3'b101;
	parameter _OR = 3'b110;
	parameter _AND = 3'b111;
    // I type Load func3
    parameter LB = 3'b000;
    parameter LH = 3'b001;
	parameter LW = 3'b010;
	parameter LHU = 3'b101;
	parameter LBU = 3'b100;
    // B type func3
    parameter BEQ = 3'b000;
    parameter BNE = 3'b001;
	parameter BLT = 3'b100;
	parameter BGE = 3'b101;
	parameter BLTU = 3'b110;
	parameter BGEU = 3'b111;	
    // CSR func3
    parameter TRAP   = 3'b000;  //MRET, WFI
    parameter CSRRW  = 3'b001;
    parameter CSRRS  = 3'b010;
    parameter CSRRC  = 3'b011;
    parameter CSRRWI = 3'b101;
    parameter CSRRSI = 3'b110;
    parameter CSRRCI = 3'b111;

//main
    always_comb begin
        unique case (opcode)
            `R_type: begin
                jump = 1'b0;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1; 
                ALUSrc = 1'b0;
                rdsrc = 3'd0;
                RegWrite = 1'b1;
                Immop = 3'd0;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;
                unique case (func3) 
                    ADD_SUB_MUL: begin
                        if (func7[5] == 1'b1)   ALUop = `ALU_SUB;  //SUB 
                        else if (func7[0] == 1'b1)  ALUop = `ALU_MUL; //MUL
                        else    ALUop = `ALU_ADD;   // ADD
                    end
                    SLL_MULH: ALUop = (func7[0] == 1'b1) ? `ALU_MULH : `ALU_SLL;
                    SLT_MULHSU: ALUop = (func7[0] == 1'b1) ? `ALU_MULHSU : `ALU_SLT;
                    SLTU_MULHU: ALUop = (func7[0] == 1'b1) ? `ALU_MULHU : `ALU_SLTU;
                    _XOR:  ALUop = `ALU_XOR;
                    SRL_SRA:  ALUop = (func7[5] == 1'b0) ? `ALU_SRL : `ALU_SRA;
                    _OR:   ALUop = `ALU_OR;
                    _AND:  ALUop = `ALU_AND;
                    // default:  ALUop = `ALU_ADD; fullcase
                endcase

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `I_type: begin
                jump = 1'b0;
                Branch = 1'b0;
                WEB = 4'b1111;  
                MemRead = 1'b0;
                MemtoReg = 1'b1;
                ALUSrc = 1'b1;
                rdsrc = 3'd0;
                RegWrite = 1'b1;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;
                unique case (func3)
                    ADD_SUB_MUL: begin  //ADDI
                        ALUop = `ALU_ADD; 
                        Immop = 3'd1;
                    end 
                    SLL_MULH: begin  //SLLI
                        ALUop = `ALU_SLL;
                        Immop = 3'd2;
                    end         
                    SLT_MULHSU: begin  //SLTI
                        ALUop = `ALU_SLT;  
                        Immop = 3'd1;       
                    end
                    SLTU_MULHU: begin  //SLTIU
                        ALUop = `ALU_SLTU;  
                        Immop = 3'd1;      
                    end
                    _XOR: begin  //XORI
                        ALUop = `ALU_XOR; 
                        Immop = 3'd1;        
                    end
                    SRL_SRA: begin  //SRLI SRAI
                        ALUop = (func7[5] == 1'b0) ? `ALU_SRL : `ALU_SRA;   
                        Immop = 3'd2;
                    end
                    _OR: begin  //ORI
                        ALUop = `ALU_OR;  
                        Immop = 3'd1;        
                    end
                    _AND: begin  //ANDI
                        ALUop = `ALU_AND; 
                        Immop = 3'd1;        
                    end
                    //default: begin  fullcase
                    //    ALUop = `ALU_ADD;
                    //    Immop = 3'd0;
                    //end
                endcase

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `I_type_Load: begin
                jump = 1'b0;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b1;
                MemtoReg = 1'b0;
                ALUSrc = 1'b1;
                rdsrc = 3'd0;
                RegWrite = 1'b1;
                ALUop = `ALU_ADD;  //add
                Immop = 3'd1;
                StoreCon = 2'd0;
                PCsel = 1'b0;
                case (func3) // extend operation
                    LB:  LoadCon = 3'd1;
                    LH:  LoadCon = 3'd2;
                    LW:  LoadCon = 3'd0;
                    LHU: LoadCon = 3'd3;
                    LBU: LoadCon = 3'd4;
                    default: LoadCon=3'd0;
                endcase

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `I_type_JALR: begin   //rd = pc+4, pc = imm + rs1
                jump = 1'b1;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1;
                ALUSrc = 1'b1;
                rdsrc = 3'd1;
                RegWrite = 1'b1;
                ALUop = `ALU_ADD;
                Immop = 3'd1; 
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b1;

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `S_type: begin
                jump = 1'b0;
                Branch = 1'b0;
                //WEB = 4'b0000;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUSrc = 1'b1;
                rdsrc = 3'd0;
                RegWrite = 1'b0;
                ALUop = `ALU_ADD;
                Immop = 3'd3; 
                LoadCon = 3'd0;
                PCsel = 1'b0;
                case (func3)
                    3'd0: begin StoreCon = 2'd0;  WEB = ~`AXI_STRB_BYTE; end //SB
                    3'd1: begin StoreCon = 2'd1;  WEB = ~`AXI_STRB_HWORD; end //SH
                    3'd2: begin StoreCon = 2'd2;  WEB = ~`AXI_STRB_WORD; end //SW
                    default: begin StoreCon = 2'd0; WEB = ~`AXI_STRB_BYTE; end
                endcase

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `B_type: begin
                jump = 1'b0;
                Branch = 1'b1;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1; 
                ALUSrc = 1'b0;
                rdsrc = 3'd0;
                RegWrite = 1'b0;
                Immop = 3'd4;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;
                case (func3)
                    BEQ: ALUop = `ALU_BEQ;
                    BNE: ALUop = `ALU_BNE;
                    BLT: ALUop = `ALU_BLT;
                    BGE: ALUop = `ALU_BGE;
                    BLTU: ALUop = `ALU_BLTU;
                    BGEU: ALUop = `ALU_BGEU;
                    default: ALUop = `ALU_ADD;
                endcase

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `U_AUIPC: begin  //rd = PC + imm
                jump = 1'b0;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1;
                ALUSrc = 1'b1;
                rdsrc = 3'd2;
                RegWrite = 1'b1;
                ALUop = `ALU_ADD; 
                Immop = 3'd5;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `U_LUI: begin   //rd = imm
                jump = 1'b0;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1;
                ALUSrc = 1'b1;
                rdsrc = 3'd3;
                RegWrite = 1'b1;
                ALUop = `ALU_ADD;
                Immop = 3'd5;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `J_type: begin
                jump = 1'b1;
                Branch = 1'b0;
                WEB = 4'b1111;
                MemRead = 1'b0;
                MemtoReg = 1'b1;
                ALUSrc = 1'b1;
                rdsrc = 3'd1;
                RegWrite = 1'b1;
                ALUop = `ALU_JAL;
                Immop = 3'd6;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
            `CSR_inst: begin
                unique case (func3)
                    TRAP: begin
                        WEB = 4'b1111;
                        jump = 1'd0;   
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd0;
                        RegWrite = 1'd0;
                        ALUop = `ALU_ADD;
                        Immop = 3'd0;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        CSRWrite = 1'd0;
                        CSR_ALUSrc = 1'd0;
                        CSR_ALUop = 2'd0;
                        case (CSR_imm)
                            12'b0011_0000_0010: begin //MRET
                                WFI = 1'd0;
                                CSR_return = 1'd1;
                            end
                            12'b0001_0000_0101:begin  //WFI
                                WFI = 1'd1;
                                CSR_return = 1'd0;
                            end
                            default: begin
                                WFI = 1'd0;
                                CSR_return = 1'd0;
                            end
                        endcase
                    end
                    CSRRW: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd0;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd0;
                        CSR_ALUop = 2'd0;
                    end
                    CSRRS: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd0;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd0;
                        CSR_ALUop = 2'd1;
                    end
                    CSRRC: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd0;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;
                        
                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd0;
                        CSR_ALUop = 2'd2;
                    end
                    CSRRWI: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd7;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd1;
                        CSR_ALUop = 2'd0;
                    end
                    CSRRSI: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd7;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd1;
                        CSR_ALUop = 2'd1;
                    end
                    CSRRCI: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd4;
                        RegWrite = 1'd1;
                        ALUop = `ALU_ADD;
                        Immop = 3'd7;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd1;
                        CSR_ALUSrc = 1'd1;
                        CSR_ALUop = 2'd2;
                    end
                    default: begin
                        WEB = 4'b1111;
                        jump = 1'd0;
                        Branch = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd1;
                        ALUSrc = 1'd0;
                        rdsrc = 3'd0;
                        RegWrite = 1'd0;
                        ALUop = `ALU_ADD;
                        Immop = 3'd0;
                        LoadCon = 3'd0;
                        StoreCon = 2'd0;
                        PCsel = 1'b0;

                        WFI = 1'd0;
                        CSR_return = 1'd0;
                        CSRWrite = 1'd0;
                        CSR_ALUSrc = 1'd0;
                        CSR_ALUop = 2'd0;
                    end
                endcase
            end
            default: begin
                WEB = 4'b1111;
                jump = 1'd0;
                Branch = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'd1;
                ALUSrc = 1'd0;
                rdsrc = 3'd0;
                RegWrite = 1'd0;
                ALUop = `ALU_ADD;
                Immop = 3'd0;
                LoadCon = 3'd0;
                StoreCon = 2'd0;
                PCsel = 1'b0;

                WFI = 1'd0;
                CSR_return = 1'd0;
                CSRWrite = 1'd0;
                CSR_ALUSrc = 1'd0;
                CSR_ALUop = 2'd0;
            end
        endcase
   end
    
endmodule
