module hazard_detection_unit (
    input clk, rst,
    input MemStall,

    input ID_EX_MemRead,
    input [`RegAddrBus]IF_ID_Rs,
    input [`RegAddrBus]IF_ID_Rt,
    input [`RegAddrBus]ID_EX_Rt,

    output logic hazard_stall
);
    
    logic hstall, stall_end;
    always_comb begin
        if (ID_EX_MemRead && ((ID_EX_Rt == IF_ID_Rs) || (ID_EX_Rt == IF_ID_Rt)))
             hstall = 1'b1;
        else hstall = 1'b0;
    end

    always_ff @( posedge clk or posedge rst) begin 
	    if (rst) stall_end <= 1'b0;
        else if (hstall && !MemStall) stall_end <= ~stall_end;  
        else        stall_end <= 1'b0;
    end

    assign hazard_stall = (hstall && !stall_end) ? 1'b1 : 1'b0;

endmodule
