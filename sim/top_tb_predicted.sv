`include "CYCLE_MAX.sv"
`timescale 1ns/10ps
`define DRAM_CYCLE    30.4
`define ROM_CYCLE     50.2
`define SRAM_CYCLE    11.0

`ifdef SYN
`include "top_syn.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "SRAM/SRAM.v"
`include "InOut_SRAM/SUMA180_32768X16X1BM8.v"
`include "Weight_SRAM/SUMA180_16384X18X1BM4.v"
`include "Bias_SRAM/SUMA180_384X32X1BM4.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif PR
`include "top_pr.v"
`include "SRAM/SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "InOut_SRAM/SUMA180_32768X16X1BM8.v"
`include "Weight_SRAM/SUMA180_16384X18X1BM4.v"
`include "Bias_SRAM/SUMA180_384X32X1BM4.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`else
`include "top.sv"
`include "SRAM/SRAM_rtl.sv"
`include "data_array/data_array_rtl.sv"
`include "tag_array/tag_array_rtl.sv"
`include "InOut_SRAM/SUMA180_32768X16X1BM8_rtl.sv"
`include "Weight_SRAM/SUMA180_16384X18X1BM4_rtl.sv"
`include "Bias_SRAM/SUMA180_384X32X1BM4_rtl.sv"
`endif
`timescale 1ns/10ps
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
   TOP.DM1.i_SRAM.Memory_byte2[addr], \
   TOP.DM1.i_SRAM.Memory_byte1[addr], \
   TOP.DM1.i_SRAM.Memory_byte0[addr]}
`define dram_word(addr) \
  {i_DRAM.Memory_byte3[addr], \
   i_DRAM.Memory_byte2[addr], \
   i_DRAM.Memory_byte1[addr], \
   i_DRAM.Memory_byte0[addr]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h100000

`define dram_ANS(addr) {i_DRAM.Memory_byte1[addr], \
   i_DRAM.Memory_byte0[addr]}
module top_tb_predicted;
	logic cpu_clk;
  logic axi_clk;
  logic dram_clk;
  logic rom_clk;
  logic sram_clk;
  logic rst;
  logic cpu_rst ;
  logic axi_rst ;
  logic rom_rst ;
  logic dram_rst;
  logic sram_rst;
  logic [31:0] GOLDEN[200000];
  logic [7:0] predi;
  logic [7:0] Memory_byte0[32768];
  logic [7:0] Memory_byte1[32768];
  logic [7:0] Memory_byte2[32768];
  logic [7:0] Memory_byte3[32768];
  //HW4
  logic [31:0] ROM_out;
  logic sensor_ready;
  logic [31:0] sensor_out;
  logic [31:0] DRAM_Q;
  logic ROM_enable;
  logic ROM_read;
  logic [11:0] ROM_address;
  logic sensor_en;
  logic DRAM_CSn;
  logic [3:0]DRAM_WEn;
  logic DRAM_RASn;
  logic DRAM_CASn;
  logic [10:0] DRAM_A;
  logic [31:0] DRAM_D; 
  logic DRAM_valid;

  logic [31:0] sensor_mem [0:511];
  logic [8:0] sensor_counter;
  logic [9:0] data_counter;
  //HW4
  integer gf, i, num, max_index, max_value, pre;
  logic [31:0] temp;
  integer err;
  string prog_path;
  // always #(`CYCLE/2) clk = ~clk;
  
	  // clock generater
  always #(`CPU_CYCLE/2)    cpu_clk     = ~cpu_clk;
  always #(`AXI_CYCLE/2)    axi_clk     = ~axi_clk;
  always #(`DRAM_CYCLE/2)   dram_clk    = ~dram_clk;
  always #(`ROM_CYCLE/2)    rom_clk     = ~rom_clk;
  always #(`SRAM_CYCLE/2)   sram_clk    = ~sram_clk;

  top TOP(
    .cpu_clk		    (cpu_clk      ), // CPU CLOCK DOMAIN
    .axi_clk		    (axi_clk      ),
    .rom_clk        (rom_clk      ),
    .dram_clk       (dram_clk     ),
    .sram_clk       (sram_clk     ),
    .cpu_rst		    (cpu_rst      ),
    .axi_rst		    (axi_rst      ),
    .rom_rst        (rom_rst      ),
    .dram_rst       (dram_rst     ),
    .sram_rst       (sram_rst     ),
    .ROM_out      (ROM_out      ),
    .sensor_ready (sensor_ready ),
    .sensor_out   (sensor_out   ),
    .DRAM_valid   (DRAM_valid   ),
    .DRAM_Q       (DRAM_Q       ),
    .ROM_read     (ROM_read     ),
    .ROM_enable   (ROM_enable   ),
    .ROM_address  (ROM_address  ),
    .sensor_en    (sensor_en    ),
    .DRAM_CSn     (DRAM_CSn     ),
    .DRAM_WEn     (DRAM_WEn     ),
    .DRAM_RASn    (DRAM_RASn    ),
    .DRAM_CASn    (DRAM_CASn    ),
    .DRAM_A       (DRAM_A       ),
    .DRAM_D       (DRAM_D       )
  );


  ROM i_ROM(
		.CK             (rom_clk      ), // ROM CLOCK DOMAIN
    .CS (ROM_enable ),
    .OE (ROM_read   ),
    .A  (ROM_address),
    .DO (ROM_out    )
  );

   DRAM i_DRAM(
    .CK             (dram_clk     ), // DRAM CLOCK DOMAIN
    .Q    (DRAM_Q     ),
    .RST            (dram_rst     ),
    .CSn  (DRAM_CSn   ),
    .WEn  (DRAM_WEn   ),
    .RASn (DRAM_RASn  ),
    .CASn (DRAM_CASn  ),
    .A    (DRAM_A     ),
    .D    (DRAM_D     ),
    .VALID(DRAM_valid )
  );

  // reset release sequence (DRAM -> ROM -> SRAM -> AXI -> CPU)
  initial begin
    dram_rst = 1;
    rom_rst  = 1;
    sram_rst = 1;
    axi_rst  = 1;
    cpu_rst  = 1;
    @(posedge dram_clk)
    #(2); // small number 
    dram_rst = 0;
    @(posedge rom_clk)
    #(2); // small number 
    rom_rst = 0;
    @(posedge sram_clk)
    #(2); // small number 
    sram_rst = 0;
    @(posedge axi_clk)
    #(2); // small number 
    axi_rst = 0;
    @(posedge cpu_clk)
    #(2); // small number 
    cpu_rst = 0;
  end
  
  

  initial
  begin
    $value$plusargs("prog_path=%s", prog_path);
    // reset
    cpu_clk         = 0;  
    axi_clk         = 0;
    dram_clk        = 0;
    rom_clk         = 0;
    sram_clk        = 0;
    sensor_counter  = 0; 
    data_counter    = 0;
		wait(dram_rst)
    wait(~dram_rst)
    // #(`CYCLE*20);  //?
    $readmemh({prog_path, "/rom0.hex"}, i_ROM.Memory_byte0);
    $readmemh({prog_path, "/rom1.hex"}, i_ROM.Memory_byte1);
    $readmemh({prog_path, "/rom2.hex"}, i_ROM.Memory_byte2);
    $readmemh({prog_path, "/rom3.hex"}, i_ROM.Memory_byte3);
    $readmemh({prog_path, "/dram0.hex"}, i_DRAM.Memory_byte0);
    $readmemh({prog_path, "/dram1.hex"}, i_DRAM.Memory_byte1);
    $readmemh({prog_path, "/dram2.hex"}, i_DRAM.Memory_byte2);
    $readmemh({prog_path, "/dram3.hex"}, i_DRAM.Memory_byte3);


    num = 0;

`ifdef conv_all
    gf = $fopen({prog_path, "/Out8_FC2.hex"}, "r");
    pre = $fopen({prog_path, "/Out_check.hex"}, "r");
`elsif fc0
    gf = $fopen({prog_path, "/Out8.hex"}, "r");
    pre = $fopen({prog_path, "/Out_check.hex"}, "r");
`endif
    //gf = $fopen({prog_path, "/golden.hex"}, "r");
    while (!$feof(gf))
    begin
      $fscanf(gf, "%h\n", GOLDEN[num]);
      num++;
    end
    $fclose(gf);

    while (!$feof(pre))
    begin
      $fscanf(pre, "%h\n", predi);
      num++;
    end
    $fclose(pre);

    `ifdef prog1
    $readmemh({prog_path, "/Sensor_data.dat"}, sensor_mem);
    `endif

    while (1)
    begin
      #(`CPU_CYCLE)
      if (`mem_word(`SIM_END) == `SIM_END_CODE)
      begin
        break; 
      end
      `ifdef prog1
      if (sensor_en)
      begin
        if (data_counter == 10'h3ff)
        begin
          sensor_out = sensor_mem[sensor_counter];
          sensor_counter ++;
          sensor_ready = 1'b1;
        end
        else
        begin
          sensor_out = 32'hxxxx_xxxx;
          sensor_ready = 1'b0;
        end
        data_counter ++;
      end
      else begin
        sensor_ready = 1'b0;
      end
      `endif
    end	
    $display("\nDone\n");
    err = 0;
    max_index = 0;
    max_value = 0;
    for (i = 0; i < 43; i++)
    begin
        if($signed(`dram_word(`TEST_START + i)) > max_value)begin
          max_value = `dram_word(`TEST_START + i);
          max_index = i;
        end

        // $display("minus = %d", $signed(`dram_ANS(`TEST_START + i)) - $signed(GOLDEN[i][15:0]));
      // if (`dram_word(`TEST_START + i) !== GOLDEN[i])
      // begin
      //   if($signed(`dram_word(`TEST_START + i)) - $signed(GOLDEN[i][15:0])>224 || $signed(`dram_word(`TEST_START + i)) - $signed(GOLDEN[i][15:0])<-224)
      //   begin
      //     $display("class = %4d : DRAM = %d", i, $signed(`dram_word(`TEST_START + i)));
      //     err = err + 1;
      //   end
      //   else 
      //   begin
      //     $display("class = %4d : DRAM = %d", i, $signed(`dram_word(`TEST_START + i)));
      //   end
      // end
      // else
      begin
        $display("class = %4d : DRAM = %d", i, $signed(`dram_word(`TEST_START + i)));
      end
    end
    if(max_index !== predi)
      err = err + 1;

    $display("------------------------------------");  
    $display("\n");
    $display("                                            \\     ****************************    /");
    $display("      Predict class: %d             \\    *   Correct class:  %d    *   /", max_index, predi);
    $display("                                              \\   ****************************  /");
    $display("                                               \\                               /");
    result(err, num); 
    $finish;
  end

  `ifdef SYN
  initial $sdf_annotate("top_syn.sdf", TOP);
  `elsif PR
  initial $sdf_annotate("top_pr.sdf", TOP);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    //$fsdbDumpvars(0, TOP);
    $fsdbDumpvars;
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    //$fsdbDumpvars("+struct", "+mda", i_DRAM);
    $fsdbDumpvars("+struct", i_DRAM);
    `endif
    #(`CPU_CYCLE*`MAX)
    for (i = 0; i < num; i++)
    begin
      $display("minus = %d", $signed(`dram_ANS(`TEST_START + i)) - $signed(GOLDEN[i][15:0]));

      if (`dram_word(`TEST_START + i) !== GOLDEN[i])
      begin
        if($signed(`dram_ANS(`TEST_START + i)) - $signed(GOLDEN[i][15:0])>=224 || $signed(`dram_ANS(`TEST_START + i)) - $signed(GOLDEN[i][15:0])<-224)
        begin
          $display("DRAM[%4d] = %d, expect = %d", `TEST_START + i, $signed(`dram_word(`TEST_START + i)), GOLDEN[i]);
          err=err+1;
        end
        else 
        begin
          $display("DRAM[%4d] = %d, pass", `TEST_START + i, $signed(`dram_word(`TEST_START + i)));
        end
      end
      else begin
        
      end
    end

    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `dram_word(`SIM_END), `SIM_END_CODE);
    result(err, num);
    $finish;
  end

  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
        rf = $fopen({prog_path, "/result_syn.txt"}, "w");
        `elsif PR
        rf = $fopen({prog_path, "/result_pr.txt"}, "w");
      `else
        rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
        $display("                                                             _oo0oo_                     ");
        $display("                                                            o8888888o                    ");
        $display("                                                            88' . '88                    ");
        $display("                                                            (| -_- |)                    ");
        $display("                                                            0\\  =  /0                    ");
        $display("        ****************************                      ___/`---'\\___                  ");
        $display("        ****************************                    .\\\"\\\\|     |// \\'.                ");
        $display("        **                        **                   / \\\\|||  :   |||// \\               ");
        $display("        **                        **                  / _||||| -:-  |||||- \\              ");
        $display("        **   Congratulations !!   **                 |   | \\\\\\  -  /// |   |             ");
        $display("        **                        **                 | \\_|   ''\---/''  |_/ |             ");
        $display("        **   Simulation PASS!!    **                 \\  .-\___  '-'  ___/-. /             ");
        $display("        **                        **               ___'. .'  /--.--\\  `. .'___           ");
        $display("        **                        **            .\"\" \"<  `.___\\_<|>_/___.\" >\" \"\".         ");
        $display("        **                        **           | | :  `- \\`.;`\\ _ /`;.`/ - ` : | |       ");
        $display("        ****************************           \\  \\ `_.   \\_ __\\ /__ _/   .-` /  /       ");
        $display("        ****************************       =====`-.____`.___ \\_____/___.-`___.-'=====    ");
        $display("                                                            `=---='                      ");
        $display("                                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     ");
        $display("                                                                                         ");
        $display("                                                  Buddha Bless NO BUG FOREVER            ");
        $display("\n");
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end
      // display cycle
      $display("                  %10s %10s", "CYCLE", "FREQ");
      $display("        DRAM    : %10f %10f", `DRAM_CYCLE, (1000/`DRAM_CYCLE));
      $display("        ROM     : %10f %10f", `ROM_CYCLE, (1000/`ROM_CYCLE));
      $display("        SRAM    : %10f %10f", `SRAM_CYCLE, (1000/`SRAM_CYCLE));
      $display("        CPU     : %10f %10f", `CPU_CYCLE, (1000/`CPU_CYCLE));
      $display("        AXI     : %10f %10f", `AXI_CYCLE, (1000/`AXI_CYCLE));
    end
  endtask

endmodule
