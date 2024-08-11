module sign_extend (
    input [24:0]in,  //inst[31:7]
    input [2:0]Immop,
    output logic [31:0]out
);

    parameter Itype = 3'd1;         //[31:20] sign_extension 32-bit
    parameter Itype_shift = 3'd2;   //[24:20]
    parameter Stype = 3'd3;         //[31:25],[11:7] sign_extension
    parameter Btype = 3'd4;         //out[0] 0
    parameter Utype = 3'd5;         //[31:12] 20 bits
    parameter Jtype = 3'd6;         //out[0] = 0
    parameter CSR   = 3'd7; 

    /*
    31:25 > 24:18
    31:20 > 24:13
    24:20 > 17:13
    11:7  > 4:0
    31:12 > 24:5
    */

    always_comb begin
        unique case (Immop)
            Itype:       out = {{20{in[24]}}, in[24:13]};
            Itype_shift: out = {27'd0, in[17:13]};
            Stype:       out = {{20{in[24]}}, in[24:18], in[4:0]};
            Btype:       out = {{19{in[24]}}, in[24], in[0], in[23:18], in[4:1], 1'd0};
            Utype:       out = {in[24:5], 12'd0};
            Jtype:       out = {{11{in[24]}}, in[24], in[12:5], in[13], in[23:14], 1'b0};   
            CSR  :       out = {27'd0, in[12:8]};                        
            default:     out = 32'd0;
        endcase
    end
    
endmodule
