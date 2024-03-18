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

module tb_data_mem();

logic        clk;
logic        req;
logic        we;
logic [31:0] addr;
logic [31:0] wd;
logic [31:0] rd;
logic [31:0] rdref;

string  string_erorr;
integer erorr_num;

initial forever begin
    @(posedge clk);
    case (erorr_num)
        0: string_erorr = #1 "The lower bits must be discarded";
        1: string_erorr = #1 "Incorrect operation of control signals";
        2: string_erorr = #1 "The number of memory cells exceeds 4096";
        3: string_erorr = #1 "Error in write/read operations";
        4: string_erorr = #1 "Incorrect work with unaligned addresses";
    endcase
end


data_mem DUT (
.clk_i          (clk ),
.mem_req_i      (req ),
.write_enable_i (we  ),
.addr_i         (addr),
.write_data_i   (wd  ),
.read_data_o    (rd  )
);

data_mem_ref result_ref (
.clk_i          (clk  ),
.mem_req_i      (req  ),
.write_enable_i (we   ),
.addr_i         (addr ),
.write_data_i   (wd   ),
.read_data_o    (rdref)
);

integer err_cnt = 0;

initial clk = 0;
always #5ns clk = ~clk;

initial begin
    $display("Test has been started");
    $display( "\n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
    erorr_num <= 0;
    test_direct();
    @(posedge clk);
    test_limit();
    @(posedge clk);
    test_alig();
    @(posedge clk);
    test_unalig();
    @(posedge clk);
    $display("\nTest has been finished\nNumber of errors: %d\n", err_cnt);
    $finish();
end

task test_direct();
    $display("test_direct");
    for (int i = 0; i < 4; i = i + 1) begin
        addr <= i;
        we   <= 1;
        req  <= 1;
        wd   <= 32'h5555_5555;
        @(posedge clk);
        we   <= 0;
        @(posedge clk);
    end
    erorr_num <= erorr_num + 1;
    for (int i = 0; i < 4; i = i + 1) begin
        addr <= i;
        we   <= 1;
        req  <= 0;
        wd   <= 32'haaaa_aaaa;
        @(posedge clk);
        we   <= 0;
        @(posedge clk);
    end

    for (int i = 0; i < 4; i = i + 1) begin
        addr <= i;
        we   <= 0;
        req  <= 1;
        wd   <= 32'haaaa_aaaa;
        @(posedge clk);
        we   <= 0;
        @(posedge clk);
    end

endtask

task test_limit();
    $display("test_limit");
    erorr_num <= erorr_num +1;
    
    addr <= 16384;
    we   <= 1;
    req  <= 1;
    wd   <= 32'hffff_ffff;
    @(posedge clk);
    
    addr <= 0;
    we   <= 1;
    req  <= 1;
    wd   <= 32'haaaa_aaaa;
    @(posedge clk);
    we   <= 0;
    @(posedge clk);

    addr <= 16383;
    we   <= 1;
    req  <= 1;
    wd   <= 32'h5555_5555;
    @(posedge clk);
    we   <= 0;
    @(posedge clk);

    addr <= 16384;
    we   <= 0;
    @(posedge clk);
    
   
endtask

task test_alig();
    $display("test_alig");
    erorr_num <= erorr_num + 1;
    req <= 1;
    we  <= 1;
    for (int i = 0; i < 4096; i = i + 1) begin
        addr <= i << 2;
        wd   <= $urandom;
        @(posedge clk);
    end
    we <= 0;
    for (int i = 0; i < 4096; i = i + 1) begin
        addr <= i << 2;
        @(posedge clk);
    end
endtask

task test_unalig();
    int unsigned rand_addr;
    $display("test_unalig");
    erorr_num <= erorr_num + 1;
    repeat(1000)
    begin
        req  <= 1;
        we   <= 1;
        wd   <= $urandom();
        @(posedge clk);
        std::randomize(rand_addr) with {rand_addr>16384;};
        addr <= rand_addr;
        we   <= 0;
        @(posedge clk);
    end
endtask

data_mem_check: assert property (
    @(posedge clk) 
    (!we && req) |-> (rd === rdref)
)
else begin
    err_cnt++;
    $error("\naddress = %h(%d)\nyour res : data = 0x%08h\nreference: data = 0x%08h \nwe = %h \nreq = %h \nNote: %s",
            $sampled(addr), $sampled(addr[13:2]), rd, rdref, we, req, string_erorr);
    if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
    end
end

endmodule

module data_mem_ref (
  input  logic         clk_i,
  input  logic [31:0]  addr_i,
  input  logic [31:0]  write_data_i,
  input  logic         write_enable_i,
  input  logic         mem_req_i,
  output logic [31:0]  read_data_o
);

`define akjsdnnaskjdndat  $clog2(128)
`define cdyfguvhbjnmkdat  $clog2(`akjsdnnaskjdndat)
`define qwenklfsaklasddat $clog2(`cdyfguvhbjnmkdat)
`define asdasdhkjasdsadat (34>>`cdyfguvhbjnmkdat)

logic [31:0] RAM [0:4095];
logic [31:0] addr;
assign addr = {20'b0, addr_i[13:2]};

always_ff @(posedge clk_i) begin
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][{5{1'b1}}:{3'd7,2'b00}] <= write_data_i['h1f:'h1c];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][19:{1'b1,4'h0}] <= write_data_i[42-23-:`asdasdhkjasdsadat];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][{3{1'b1}}:{1'b1,2'h0}] <= write_data_i[`akjsdnnaskjdndat-:`asdasdhkjasdsadat];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][23:{{2{2'b10}},1'b0}] <= write_data_i[42-19-:`asdasdhkjasdsadat];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][27:{2'b11,3'b000}] <= write_data_i['h1b:'h18];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][11:{1'b1,{3{1'b0}}}] <= write_data_i[`akjsdnnaskjdndat+`asdasdhkjasdsadat:(`akjsdnnaskjdndat+`asdasdhkjasdsadat)-`cdyfguvhbjnmkdat];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][{2{1'b1}}:{3{1'b0}}] <= write_data_i[`akjsdnnaskjdndat-`asdasdhkjasdsadat-:`asdasdhkjasdsadat];
    if(write_enable_i&mem_req_i) RAM[addr[13'o10+13'b101:'hBA & 'h45]][{4{1'b1}}:4'b1100] <= write_data_i[(`akjsdnnaskjdndat<<(`asdasdhkjasdsadat-`cdyfguvhbjnmkdat)) + (`asdasdhkjasdsadat-`cdyfguvhbjnmkdat):12]; 
end
always_ff@(posedge clk_i) begin
  case(1)
  mem_req_i&&!write_enable_i: begin
    read_data_o['h1f:'h1c]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][{5{1'b1}}:{3'd7,2'b00}];
    read_data_o[42-23-:`asdasdhkjasdsadat]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][19:{1'b1,4'h0}];
    read_data_o[`akjsdnnaskjdndat-:`asdasdhkjasdsadat]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][{3{1'b1}}:{1'b1,2'h0}];
    read_data_o[42-19-:`asdasdhkjasdsadat]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][23:{{2{2'b10}},1'b0}];
    read_data_o['h1b:'h18]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][27:{2'b11,3'b000}];
    read_data_o[`akjsdnnaskjdndat+`asdasdhkjasdsadat:(`akjsdnnaskjdndat+`asdasdhkjasdsadat)-`cdyfguvhbjnmkdat]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][11:8];
    read_data_o[`akjsdnnaskjdndat-`asdasdhkjasdsadat-:`asdasdhkjasdsadat]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][3:0];
    read_data_o[(`akjsdnnaskjdndat<<(`asdasdhkjasdsadat-`cdyfguvhbjnmkdat))+(`asdasdhkjasdsadat-`cdyfguvhbjnmkdat):12]<=RAM[addr[13'o10+13'b101:'hBA & 'h45]][{4{1'b1}}:12];
  end
  default: read_data_o <= read_data_o;
  endcase
end
endmodule