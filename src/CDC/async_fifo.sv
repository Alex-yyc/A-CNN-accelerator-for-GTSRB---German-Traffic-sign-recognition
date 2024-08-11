//*********************************************************
// Auther:      N26111512
// Description: Asynchronous FIFO of 1bit depth
// Version:     2.0 
// Date:        12/13
//*********************************************************
//`include "CDC/sync2ff.sv"
//`include "CDC/fifo_mem.sv"
//`include "CDC/wptr_ctrl.sv"
//`include "CDC/rptr_ctrl.sv"

module async_fifo # (
  parameter FIFO_DATASIZE = 51,
  parameter FIFO_ADDRSIZE = 1
)(
  // write
  input wclk, wrst,
  input wpush,
  input [FIFO_DATASIZE-1:0] wdata,
  output logic wfull,

  // read 
  input rclk, rrst,
  input rpop,
  output logic [FIFO_DATASIZE-1:0] rdata,
  output logic rempty
);

  logic we, wfull_wire, rempty_wire, wpush_reg, rpop_reg, wpush_pulse, rpop_pulse;
  logic [FIFO_ADDRSIZE-1:0] raddr, waddr, raddr_wclk, waddr_rclk;

  
  // make push & pop into 1T pulse 
  assign wpush_pulse = (wpush & ~wpush_reg);
  always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) wpush_reg <= 1'b0;
    else     wpush_reg <= wpush;
  end
  assign rpop_pulse = (rpop & ~rpop_reg);
  always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) rpop_reg <= 1'b0;
    else     rpop_reg <= rpop;
  end

  assign we = wpush_pulse & ~wfull; 
  // full & empty
  assign wfull_wire = (waddr != raddr_wclk);
  always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) wfull <= 1'b0;
    else     wfull <= wfull_wire;
  end
  assign rempty_wire = (raddr == waddr_rclk);
  always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) rempty <= 1'b1;
    else     rempty <= rempty_wire;
  end

  // addr 
  always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) begin
      waddr <= 1'b0;
    end
    else if(wpush_pulse && !wfull) begin
      waddr <= ~waddr;
    end
  end

  always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) begin
      raddr <= 1'b0;
    end
    else if(rpop_pulse && !rempty) begin
      raddr <= ~raddr;
    end
  end


  
  // data
  logic [FIFO_DATASIZE-1:0] mem;
  //assign rdata = (rpop) ? mem : {FIFO_DATASIZE{1'b0}};
  //assign rdata = mem;

  always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) begin
      rdata <= {FIFO_DATASIZE{1'b0}};
    end
    else begin
      rdata <= mem;
    end
  end


  always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) begin
      mem <= {FIFO_DATASIZE{1'b0}};
    end
    else if(we) 
      mem <= wdata;
  end
	
  // 2 dff sync
  logic waddr_temp, raddr_temp;
  //sync2ff sync_r2w(
  // .clk(wclk),
  // .rst(wrst),
  // .d  (raddr),
  // .q  (raddr_wclk)
  //);
  always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) {raddr_wclk, raddr_temp} <= 2'd0; 
    else     {raddr_wclk, raddr_temp} <= {raddr_temp, raddr};
  end

  //sync2ff sync_w2r(
  // .clk(rclk),
  // .rst(rrst),
  // .d  (waddr),
  // .q  (waddr_rclk)
  //);
  always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) {waddr_rclk, waddr_temp} <= 2'd0; 
    else     {waddr_rclk, waddr_temp} <= {waddr_temp, waddr};
  end

  // -------- assertion check ---------
/*
  WRITE_FULL_CHECK: assert property (
    @(posedge wclk) disable iff (wrst) (!wpush || !wfull))
    else $error("\n *** Assertion WRITE_FULL_CHECK failed: push when FIFO is full! *** \n");


  READ_EMPTY_CHECK: assert property (
    @(posedge rclk) disable iff (rrst) (!rpop || !rempty))
    else $error("\n *** Assertion READ_EMPTY_CHECK failed: pop when FIFO is empty! *** \n");
*/

endmodule
