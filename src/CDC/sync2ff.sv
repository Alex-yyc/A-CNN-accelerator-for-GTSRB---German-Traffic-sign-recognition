//*********************************************************
// Auther:      N26111512                                
// Description: sync signal to different clock domain (2dff)             
// Version:     1 
//*********************************************************

module sync2ff (
  input clk, rst, d,
  output logic q
);
  // 1st dff
  logic q_temp;  
  always_ff @(posedge clk or posedge rst) begin
    if (rst) q_temp <= 1'd0;
    else     q_temp <= d;
  end
  //2st dff
  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= 1'd0;
    else     q <= q_temp;
  end
endmodule