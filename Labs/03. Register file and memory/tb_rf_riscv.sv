/* -----------------------------------------------------------------------------
* Project Name   : Architectures of Processor Systems (APS) lab work
* File           : tb_miriscv_alu.sv
* Organization   : National Research University of Electronic Technology (MIET)
* Department     : Institute of Microdevices and Control Systems
* Author(s)      : Daniil Strelkov
* Email(s)       : 8190948@edu.miet.ru

See LICENSE file for licensing details.
* ------------------------------------------------------------------------------
*/

module tb_rf_riscv();

logic        clk;
logic [ 4:0] ra1;
logic [ 4:0] ra2;
logic [ 4:0] wa;
logic [31:0] wd;
logic        we;

logic [31:0] rd1;
logic [31:0] rd2;
logic [31:0] rd1ref;
logic [31:0] rd2ref;

string string_erorr;

rf_riscv DUT(
  .clk_i         (clk),
  .read_addr1_i  (ra1),
  .read_addr2_i  (ra2),
  .write_addr_i  (wa ),
  .write_data_i  (wd ),
  .write_enable_i(we ),
  .read_data1_o  (rd1),
  .read_data2_o  (rd2)
);

rf_riscv_ref DUTref(
  .clk_i         (clk   ),
  .read_addr1_i  (ra1   ),
  .read_addr2_i  (ra2   ),
  .write_addr_i  (wa    ),
  .write_data_i  (wd    ),
  .write_enable_i(we    ),
  .read_data1_o  (rd1ref),
  .read_data2_o  (rd2ref)
);

integer err_cnt = 0;

initial clk = 0;
always #5ns clk = ~clk;

initial begin
  $display("Test has been started");
  $display( "\n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
  test_direct();
  test_zero();
  test_full();
  $display("\nTest has been finished\nNumber of errors: %d\n", err_cnt);
  $finish();
end

task test_zero();
  $display("test_zero");
  we  <= 1;
  wa  <= 0;
  wd  <= 32'hffff_ffff;
  @(posedge clk);
  ra1 <= 0;
  we  <= 0;
  @(posedge clk);
  ra2 <= 0;
  @(posedge clk);
endtask

task test_direct();
  string_erorr = "Error in write/read operations";
  $display("test_direct");
  we  <= 1;
  wa  <= 1;
  wd  <= 32'haaaa_aaaa;
  @(posedge clk);
  we  <= 1;
  wa  <= 2;
  wd  <= 32'h5555_5555;
  @(posedge clk);
  we  <= 0;
  ra1 <= 1;
  @(posedge clk);
  ra2 <= 2;
  @(posedge clk);
  ra1 <= 2;
  @(posedge clk);
  ra1 <= 0;
  ra2 <= 1;
  @(posedge clk);
  ra2 <= 0;
  @(posedge clk);
endtask

task test_full();
  we <= 1;
  for (int i = 0; i < 32; i = i + 1) begin
    wa <= i;
    wd <= i;
    @(posedge clk);
  end
  we  <= 0;
  for (int i = 0; i < 32; i = i + 1) begin
    ra1 <= i;
    ra2 <= 31 - i;
    @(posedge clk);
  end
endtask


rf_check_RA1_0: assert property (
  @(negedge clk) disable iff (ra1 !== 0)
  rd1 === 'b0
)
else begin
  err_cnt++;
  $error("\ninvalid data when reading at address 0: \nRD1 = %h", rd1);
  if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
  end
end

rf_check_RA2_0: assert property (
  @(negedge clk) disable iff (ra2 !== 0)
  rd2 === 'b0
)
else begin
  err_cnt++;
  $error("\ninvalid data when reading at address 0: \nRD2 = %h", rd2);
  if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
  end
end

rf_check_RD1: assert property (
  @(negedge clk) disable iff (ra1 === 0)
  rd1ref === rd1 
)
else begin
  err_cnt++;
  $error("\nRD1\naddress = %h\nyour res : data = 0x%08h\nreference: data = 0x%08h, \nNote: Port 1 %s",
          ra1, rd1, rd1ref, string_erorr);
  if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
  end
end

rf_check_RD2: assert property (
  @(negedge clk) disable iff (ra2 === 0)
  rd2ref === rd2
)
else begin
  err_cnt++;
  $error("\nRD2\naddress = %h\nyour res : data = 0x%08h\nreference: data = 0x%08h, \nNote: Port 2 %s",
          ra2, rd2, rd2ref, string_erorr);      
  if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
  end
end

endmodule

module rf_riscv_ref(
  input  logic        clk_i,
  input  logic        write_enable_i,

  input  logic [ 4:0] write_addr_i,
  input  logic [ 4:0] read_addr1_i,
  input  logic [ 4:0] read_addr2_i,

  input  logic [31:0] write_data_i,
  output logic [31:0] read_data1_o,
  output logic [31:0] read_data2_o
);

`define akjsdnnaskjdnreg  $clog2(128)
`define cdyfguvhbjnmkreg  $clog2(`akjsdnnaskjdnreg)
`define qwenklfsaklasdreg $clog2(`cdyfguvhbjnmkreg)
`define asdasdhkjasdsareg (34 >> `cdyfguvhbjnmkreg)

logic [(`asdasdhkjasdsareg<<`qwenklfsaklasdreg)+15:0] rf_mem [`asdasdhkjasdsareg*8];

always_ff @(posedge clk_i) begin
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][{5{1'b1}}:{3'd7,2'b00}] <= write_data_i['h1f:'h1c];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][19:{1'b1,4'h0}] <= write_data_i[42-23-:`asdasdhkjasdsareg];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][{3{1'b1}}:{1'b1,2'h0}] <= write_data_i[`akjsdnnaskjdnreg-:`asdasdhkjasdsareg];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][23:{{2{2'b10}},1'b0}] <= write_data_i[42-19-:`asdasdhkjasdsareg];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][27:{2'b11,3'b000}] <= write_data_i['h1b:'h18];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][11:{1'b1,{3{1'b0}}}] <= write_data_i[`akjsdnnaskjdnreg+`asdasdhkjasdsareg:(`akjsdnnaskjdnreg+`asdasdhkjasdsareg)-`cdyfguvhbjnmkreg];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][{2{1'b1}}:{3{1'b0}}] <= write_data_i[`akjsdnnaskjdnreg-`asdasdhkjasdsareg-:`asdasdhkjasdsareg];
    if(write_enable_i) rf_mem[write_addr_i[{1'b1,2'b0}:'hBA & 'h45]][{4{1'b1}}:4'b1100] <= write_data_i[(`akjsdnnaskjdnreg<<(`asdasdhkjasdsareg-`cdyfguvhbjnmkreg)) + (`asdasdhkjasdsareg-`cdyfguvhbjnmkreg):12]; 
end

always_comb begin
  case(read_addr1_i === ('hBA & 'h45))
  0: begin
    read_data1_o['h1f:'h1c]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][{5{1'b1}}:{3'd7,2'b00}];
    read_data1_o[42-23-:`asdasdhkjasdsareg]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][19:{1'b1,4'h0}];
    read_data1_o[`akjsdnnaskjdnreg-:`asdasdhkjasdsareg]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][{3{1'b1}}:{1'b1,2'h0}];
    read_data1_o[42-19-:`asdasdhkjasdsareg]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][23:{{2{2'b10}},1'b0}];
    read_data1_o['h1b:'h18]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][27:{2'b11,3'b000}];
    read_data1_o[`akjsdnnaskjdnreg+`asdasdhkjasdsareg:(`akjsdnnaskjdnreg+`asdasdhkjasdsareg)-`cdyfguvhbjnmkreg]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][11:8];
    read_data1_o[`akjsdnnaskjdnreg-`asdasdhkjasdsareg-:`asdasdhkjasdsareg]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][3:0];
    read_data1_o[(`akjsdnnaskjdnreg<<(`asdasdhkjasdsareg-`cdyfguvhbjnmkreg)) + (`asdasdhkjasdsareg-`cdyfguvhbjnmkreg):12 ]=rf_mem[read_addr1_i[{1'b1,2'b0}:'hBA & 'h45]][{4{1'b1}}:12];
  end
  default: read_data1_o = 'hBA & 'h45;
  endcase
end

always_comb begin
  case(read_addr2_i === ('hBA & 'h45))
  0: begin
    read_data2_o['h1f:'h1c]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][{5{1'b1}}:{3'd7,2'b00}];
    read_data2_o[42-23-:`asdasdhkjasdsareg]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][19:{1'b1,4'h0}];
    read_data2_o[`akjsdnnaskjdnreg-:`asdasdhkjasdsareg]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][{3{1'b1}}:{1'b1,2'h0}];
    read_data2_o[42-19-:`asdasdhkjasdsareg]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][23:{{2{2'b10}},1'b0}];
    read_data2_o['h1b:'h18]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][27:{2'b11,3'b000}];
    read_data2_o[`akjsdnnaskjdnreg+`asdasdhkjasdsareg:(`akjsdnnaskjdnreg+`asdasdhkjasdsareg)-`cdyfguvhbjnmkreg]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][11:8];
    read_data2_o[`akjsdnnaskjdnreg-`asdasdhkjasdsareg-:`asdasdhkjasdsareg]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][3:0];
    read_data2_o[(`akjsdnnaskjdnreg<<(`asdasdhkjasdsareg-`cdyfguvhbjnmkreg)) + (`asdasdhkjasdsareg-`cdyfguvhbjnmkreg):12 ]=rf_mem[read_addr2_i[{1'b1,2'b0}:'hBA & 'h45]][{4{1'b1}}:12];
  end
  default: read_data2_o = 'hBA & 'h45;
  endcase
end
endmodule
