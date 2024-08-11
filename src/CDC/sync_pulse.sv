//*********************************************************
// Auther:      N26111512                                
// Description: 1T pulse synchronizer    
// Version:     1 
//*********************************************************

module sync_pulse (
  input clk, rst,
  input clk2, rst2,
  input d,
  output logic q  
);

  logic dtog, syn_dtog_tmp, syn_dtop, reg_syn_dtop; 

  assign q = syn_dtop ^ reg_syn_dtop; // q 1T pulse 

  //toggle flop
  always_ff @(posedge clk or posedge rst) begin
    if (rst) dtog <= 1'd0;
    else     dtog <= dtog ^ d;
  end

  //sync 2ff
  always_ff @(posedge clk2 or posedge rst2) begin
    if (rst2) syn_dtog_tmp <= 1'd0;
    else      syn_dtog_tmp <= dtog;
  end
  always_ff @(posedge clk2 or posedge rst2) begin
    if (rst2) syn_dtop <= 1'd0;
    else      syn_dtop <= syn_dtog_tmp;
  end
  
  //reg syn_dtog
  always_ff @(posedge clk2 or posedge rst2) begin
    if (rst2) reg_syn_dtop <= 1'd0;
    else      reg_syn_dtop <= syn_dtop;
  end
    
endmodule
