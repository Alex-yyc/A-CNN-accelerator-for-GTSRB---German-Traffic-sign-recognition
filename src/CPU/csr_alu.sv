module csr_alu (
    input [1:0] CSR_ALUop,
    input [`RegBus] data, 
    input [`RegBus] csr,
    output logic [`RegBus] csr_result
);

    always_comb begin
        unique case (CSR_ALUop)
            2'd0:    csr_result = data;
            2'd1:    csr_result = csr | data;
            2'd2:    csr_result = csr & ~data;
            default: csr_result = 32'd0;
        endcase
    end
    
endmodule