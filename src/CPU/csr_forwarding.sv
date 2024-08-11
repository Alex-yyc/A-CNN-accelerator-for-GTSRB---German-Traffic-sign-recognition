module csr_forwarding (
    input MEM_CSRWrite,
    input WB_CSRWrite,

    input [11:0] EX_CSR_waddr,
    input [11:0] MEM_CSR_waddr,
    input [11:0] WB_CSR_waddr,

    output logic [1:0] FowardCSR,
    output logic [11:0] FowardCSR_imm // 
);

    always_comb begin
        if (MEM_CSRWrite && (MEM_CSR_waddr == EX_CSR_waddr)) begin
            FowardCSR = 2'd1;
            FowardCSR_imm = MEM_CSR_waddr;
        end
        else if (WB_CSRWrite && (WB_CSR_waddr == EX_CSR_waddr)) begin
            FowardCSR = 2'd2;
            FowardCSR_imm = WB_CSR_waddr;
        end 
        else begin
            FowardCSR = 2'd0;
            FowardCSR_imm = EX_CSR_waddr;
        end
    end
    
endmodule
