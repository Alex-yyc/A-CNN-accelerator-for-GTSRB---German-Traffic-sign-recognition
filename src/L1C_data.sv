//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "def.svh"
module L1C_data(
  input clk,
  input rst,

  input m2_start,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output logic D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [`CACHE_TYPE_BITS-1:0] D_type
);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;

  //--------------- complete this part by yourself -----------------//
  parameter IDLE         = 4'd0;
  //READ
  parameter TA_R         = 4'd1;
  parameter READ_Detect  = 4'd2;
  parameter READ_Hit     = 4'd3;
  parameter READ_Miss_00 = 4'd4;
  parameter READ_Miss_01 = 4'd5;
  parameter READ_Miss_10 = 4'd6;
  parameter READ_Miss_11 = 4'd7;
  //WRITE
  parameter TA_W         = 4'd8;
  parameter WRITE_Detect = 4'd9;
  parameter WRITE_Hit    = 4'd10;
  parameter WRITE_Miss   = 4'd11;
  //Sensor
  parameter Sensor_Read  = 4'd12;
  parameter Sensor_Write = 4'd13;
  
  logic [21:0] TAG;
  logic [3:0] offset;  
	
  assign TAG    = core_addr [31:10];
  assign index  = core_addr [9:4];
  assign offset = core_addr [3:0];
  
  logic cacheable;
//   always_comb cacheable = (core_addr[31:16] != 16'h1000) && (core_addr < 32'h3fff_ffff);
  // assign cacheable = ~((core_addr[31:16] > 16'h0fff) && (core_addr[31:16] > 16'h3fff));
	assign cacheable = (core_addr[31:16] != 16'h1000) & (core_addr[31:28] < 4'h3); // senorcrtl & DMA & EPU
  
  always_ff@(posedge clk or posedge rst) begin
	if(rst)begin
        valid <= 64'd0;
    end
    else if(TA_write && cacheable)begin
		valid[index] <= 1'd1;
	end
	else begin
		valid <= valid;
	end
  end
  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(~TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );
  
    logic [3:0] current_state;
	logic [3:0] next_state;

    logic [31:0] hit_count;
    logic [31:0] miss_count;

    logic [`DATA_BITS-1:0] core_out_reg;	
	
	always_ff@(posedge clk or posedge rst) begin
	    if(rst)begin
	        current_state <= IDLE;
	    end
	    else begin
	        current_state <= next_state;
	    end
    end
	
	always_comb begin
	    case(current_state)
		    IDLE : begin
				if(m2_start) begin
					next_state = IDLE;
				end
				else if(core_req && cacheable)begin
				    next_state = TA_R;
				end
				else if(core_write && cacheable)begin
				    next_state = TA_W;
				end
				else if(core_req && (!cacheable))begin
				    next_state = Sensor_Read;
				end
				else if(core_write && (!cacheable))begin
				    next_state = Sensor_Write;
				end
				else begin
				    next_state = IDLE;
				end
			end
			TA_R : begin
				next_state = READ_Detect;
			end
			READ_Detect : begin
			    if(valid[index] && TAG == TA_out)begin
				    next_state = READ_Hit;
				end
				else begin
				    next_state = READ_Miss_00;
				end
			end
			READ_Hit : begin
				next_state = IDLE;
			end
			READ_Miss_00 : begin
			    if(D_wait)begin
				    next_state = READ_Miss_00;
				end
				else begin
				    next_state = READ_Miss_01;
				end
			end
			READ_Miss_01 : begin
			    if(D_wait)begin
				    next_state = READ_Miss_01;
				end
				else begin
				    next_state = READ_Miss_10;
				end
			end
			READ_Miss_10 : begin
			    if(D_wait)begin
				    next_state = READ_Miss_10;
				end
				else begin
				    next_state = READ_Miss_11;
				end
			end
			READ_Miss_11 : begin
			    if(D_wait)begin
				    next_state = READ_Miss_11;
				end
				else begin
				    next_state = READ_Detect;
				end
			end
            TA_W : begin
				next_state = WRITE_Detect;
			end
			WRITE_Detect : begin
			    if(valid[index] && TAG == TA_out)begin
				    next_state = WRITE_Hit;
				end
				else begin
				    next_state = WRITE_Miss;
				end
			end
			WRITE_Hit : begin
			    if(D_wait)begin
				    next_state = WRITE_Hit;
				end
				else begin
				    next_state = IDLE;
				end
			end
			WRITE_Miss : begin
			    if(D_wait)begin
				    next_state = WRITE_Miss;
				end
				else begin
				    next_state = IDLE;
				end
			end
			Sensor_Read : begin
			    if(D_wait)begin
				    next_state = Sensor_Read;
				end
				else begin
				    next_state = IDLE;
				end
			end
			Sensor_Write : begin
			    if(D_wait)begin
				    next_state = Sensor_Write;
				end
				else begin
				    next_state = IDLE;
				end
			end
			default : begin
			    next_state = IDLE;
			end
		endcase
    end
	
	always_comb begin
	    case(current_state)
		    IDLE : begin
			    core_out  = core_out_reg;
                core_wait = 1'd0;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			TA_R : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			READ_Detect : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd1;
			end
			READ_Hit : begin
			    case(offset[3:2])
				    2'b00 : core_out = DA_out[31:0];
					2'b01 : core_out = DA_out[63:32];
					2'b10 : core_out = DA_out[95:64];
					2'b11 : core_out = DA_out[127:96];
				endcase
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd1;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			READ_Miss_00 : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd1;
                D_addr    = {core_addr[31:4],4'b0000};
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b010;
				
                DA_in     = {96'd0,D_out};
                DA_write  = 16'b1111_1111_1111_0000;
                DA_read   = 1'd0;
                TA_in     = TAG;
                TA_write  = 1'd1;
                TA_read   = 1'd0;
			end
			READ_Miss_01 : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd1;
                D_addr    = {core_addr[31:4],4'b0100};
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b010;
				
                DA_in     = {64'd0,D_out,32'd0};
                DA_write  = 16'b1111_1111_0000_1111;
                DA_read   = 1'd0;
                TA_in     = TAG;
                TA_write  = 1'd1;
                TA_read   = 1'd0;
			end
			READ_Miss_10 : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd1;
                D_addr    = {core_addr[31:4],4'b1000};
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b010;
				
                DA_in     = {32'd0,D_out,64'd0};
                DA_write  = 16'b1111_0000_1111_1111;
                DA_read   = 1'd0;
                TA_in     = TAG;
                TA_write  = 1'd1;
                TA_read   = 1'd0;
			end
			READ_Miss_11 : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd1;
                D_addr    = {core_addr[31:4],4'b1100};
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b010;
				
                DA_in     = {D_out,96'd0};
                DA_write  = 16'b0000_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = TAG;
                TA_write  = 1'd1;
                TA_read   = 1'd1;
			end
            TA_W : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			WRITE_Detect : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd1;
			end
			WRITE_Hit : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = core_addr;
                D_write   = 1'd1;
                D_in      = core_in;
                D_type    = core_type;
				
				case(core_type)
				    3'b000 : begin
					    case(offset)
						    4'b0000 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_1110;
							end
							4'b0001 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_1101;
							end
							4'b0010 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_1011;
							end
							4'b0011 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_0111;
							end
							4'b0100 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_1110_1111;
							end
							4'b0101 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_1101_1111;
							end
							4'b0110 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_1011_1111;
							end
							4'b0111 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_0111_1111;
							end
							4'b1000 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_1110_1111_1111;
							end
							4'b1001 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_1101_1111_1111;
							end
							4'b1010 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_1011_1111_1111;
							end
							4'b1011 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_0111_1111_1111;
							end
							4'b1100 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b1110_1111_1111_1111;
							end
							4'b1101 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b1101_1111_1111_1111;
							end
							4'b1110 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b1011_1111_1111_1111;
							end
							4'b1111 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b0111_1111_1111_1111;
							end
						endcase
					end
					3'b001 : begin
					    case(offset[3:1])
						    3'b000 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_1100;
							end
							3'b001 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_0011;
							end
							3'b010 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_1100_1111;
							end
							3'b011 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_0011_1111;
							end
							3'b100 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_1100_1111_1111;
							end
							3'b101 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_0011_1111_1111;
							end
							3'b110 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b1100_1111_1111_1111;
							end
							3'b111 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b0011_1111_1111_1111;
							end
						endcase
					end
					3'b010 : begin
					    case(offset[3:2])
						    2'b00 : begin
							    DA_in    = {96'd0, core_in};
                                DA_write = 16'b1111_1111_1111_0000;
							end
							2'b01 : begin
							    DA_in    = {64'd0, core_in,32'd0};
                                DA_write = 16'b1111_1111_0000_1111;
							end
							2'b10 : begin
							    DA_in    = {32'd0, core_in,64'd0};
                                DA_write = 16'b1111_0000_1111_1111;
							end
							2'b11 : begin
							    DA_in    = {core_in,96'h0};
                                DA_write = 16'b0000_1111_1111_1111;
							end
						endcase
					end
					default : begin
					    DA_in    = 128'd0;
                        DA_write = 16'b1111_1111_1111_1111;
					end
				endcase
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			WRITE_Miss : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = core_addr;
                D_write   = 1'd1;
                D_in      = core_in;
                D_type    = core_type;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			Sensor_Read : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd1;
                D_addr    = core_addr;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b010;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			Sensor_Write : begin
			    core_out  = 32'd0;
                core_wait = 1'd1;
                D_req     = 1'd0;
                D_addr    = core_addr;
                D_write   = 1'd1;
                D_in      = core_in;
                D_type    = core_type;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
			default : begin
			    core_out  = 32'd0;
                core_wait = 1'd0;
                D_req     = 1'd0;
                D_addr    = 32'd0;
                D_write   = 1'd0;
                D_in      = 32'd0;
                D_type    = 3'b000;
				
                DA_in     = 128'd0;
                DA_write  = 16'b1111_1111_1111_1111;
                DA_read   = 1'd0;
                TA_in     = 22'd0;
                TA_write  = 1'd0;
                TA_read   = 1'd0;
			end
		endcase
    end
	
	always_ff@(posedge clk or posedge rst) begin
	    if(rst)begin
	        hit_count  <= 32'd0;
			miss_count <= 32'd0;
	    end
	    else if(((current_state == READ_Hit) || ((current_state == WRITE_Hit)) && (!D_wait)))begin
	        hit_count  <= hit_count + 32'd1;
			miss_count <= miss_count;
	    end
		else if(((current_state == READ_Miss_00) || (current_state == WRITE_Miss)) && (!D_wait))begin
	        hit_count  <= hit_count - 32'd1;
			miss_count <= miss_count + 32'd1;
	    end
		else begin
	        hit_count  <= hit_count;
			miss_count <= miss_count;
	    end
    end

    always_ff@(posedge clk or posedge rst) begin
	    if(rst)begin
	        core_out_reg <= 32'd0;
	    end
        else if(current_state == READ_Hit)begin
	        core_out_reg <= core_out;
	    end
		else if((current_state == Sensor_Read) && (!D_wait))begin
	        core_out_reg <= D_out;
	    end
	    else begin
	        core_out_reg <= core_out_reg;
	    end
    end

endmodule

