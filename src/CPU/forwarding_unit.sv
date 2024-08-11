module forwarding_unit (

    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input [`RegAddrBus]EX_MEM_Rd,
    input [`RegAddrBus]MEM_WB_Rd,
    input [`RegAddrBus]ID_EX_Rs,
    input [`RegAddrBus]ID_EX_Rt,

    output logic [1:0]ForwardA,  //00:EX 10:MEM 01:WB
    output logic [1:0]ForwardB   //00:EX 10:MEM 01:WB

);
    
    always_comb begin
       
        // Rs
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs)) //EX hazard
            ForwardA = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs)) // MEM hazard     ??? && (EX_MEM_Rd != ID_EX_Rs)
            ForwardA = 2'b01;
        else    
            ForwardA = 2'b00;

        // Rt
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rt)) //EX hazard
            ForwardB = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rt)) // MEM hazard    ??? && (EX_MEM_Rd != ID_EX_Rt) 
            ForwardB = 2'b01;
        else   
            ForwardB = 2'b00;

    end

endmodule
