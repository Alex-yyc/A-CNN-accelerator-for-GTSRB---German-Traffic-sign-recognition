module load_control (
    input [`RegBus]in,
    input [2:0]LoadCon,
    input [1:0] addr,

    output logic [`RegBus]out
);

    parameter LW  = 3'd0;    
    parameter LB  = 3'd1;    //8bit sign_ex
    parameter LH  = 3'd2;    //16bit sign_ex
    parameter LHU = 3'd3;   //16bit unsign_ex
    parameter LBU = 3'd4;   //8bit unsign_ex

    always_comb begin
        unique case (LoadCon)
            LW: out = in;
            LB: begin
                unique case (addr)
                    2'd0:    out = {{24{in[7]}},in[7:0]};
                    2'd1:    out = {{24{in[15]}},in[15:8]};
                    2'd2:    out = {{24{in[23]}},in[23:16]};
                    2'd3:    out = {{24{in[31]}},in[31:24]}; 
                endcase
            end
            LH: begin
                unique case (addr)
                    2'd0, 2'd1: out = {{16{in[15]}},in[15:0]};
                    2'd2, 2'd3: out = {{16{in[31]}},in[31:16]};
                endcase
            end    
            LHU: begin
                unique case (addr)
                    2'd0, 2'd1: out = {16'd0,in[15:0]};
                    2'd2, 2'd3: out = {16'd0,in[31:16]};
                endcase
            end  
            LBU: begin
                unique case (addr)
                    2'd0:    out = {24'd0,in[7:0]};
                    2'd1:    out = {24'd0,in[15:8]};
                    2'd2:    out = {24'd0,in[23:16]};
                    2'd3:    out = {24'd0,in[31:24]}; 
                endcase
            end  
            default: out = 32'd0;
        endcase
    end
    
endmodule
