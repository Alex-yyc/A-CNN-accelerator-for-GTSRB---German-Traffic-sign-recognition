module store_control (
    input [`RegBus]in,
    input [1:0]StoreCon,
    input [1:0]addr,  // ALU_result[1:0]

    output logic [`RegBus]out
);

    parameter SB = 2'd0;   //8bit
    parameter SH = 2'd1;   //16bit
    parameter SW = 2'd2;   //32bit

    always_comb begin 
        unique case (StoreCon)
            SB: begin
                unique case (addr)
                    2'd0: out = {24'd0, in[7:0]};
                    2'd1: out = {16'd0, in[7:0], 8'd0};
                    2'd2: out = {8'd0, in[7:0], 16'd0};
                    2'd3: out = {in[7:0], 24'd0};
                endcase
                end 
            SH: begin
                unique case (addr)
                    2'd0, 2'd1: out = {16'd0, in[15:0]};
                    2'd2, 2'd3: out = {in[15:0], 16'd0};
                endcase
                end 
            SW: out = in;
            default: out = 32'd0;
        endcase
    end

endmodule