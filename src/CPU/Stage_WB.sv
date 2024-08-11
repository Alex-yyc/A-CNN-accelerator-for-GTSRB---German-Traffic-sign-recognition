module Stage_WB (
    // control signal in
    input RegWrite_i,
     // data in
    input [`RegBus]result_i,
    input [`RegAddrBus]rd_i,
    // new csr
    
    output logic RegWrite_o,
    output logic [`RegBus]result_o,
    output logic [`RegAddrBus]rd_o

);

    assign result_o = result_i;
    assign RegWrite_o = RegWrite_i;
    assign rd_o = rd_i;
    
endmodule
