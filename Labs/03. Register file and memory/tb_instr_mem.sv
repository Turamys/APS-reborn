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

module tb_instr_mem();

logic [31:0] addr;

wire  [31:0] RD;
wire  [31:0] RDref;

string  string_erorr;

instr_mem DUT (
    .addr_i(addr),
    .read_data_o(RD)
);

instr_mem_ref DUTref(
    .addr_i(addr),
    .read_data_o(RDref)
);

logic clk = 0;
always #5ns clk = ~clk;

integer err_cnt = 0;

initial begin
    $display("Test has been started");
    $display( "\n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
    test_direct();
    test_limit();
    test_alig();
    test_unalig();
    $display("\nTest has been finished\nNumber of errors: %d\n", err_cnt);
    $finish();
end

task test_direct();
    string_erorr = "The lower bits must be discarded";
    for (int i = 0; i < 4; i = i + 1) begin
        addr <= i;
        @(posedge clk);
    end
endtask

task test_limit();
    string_erorr = "The number of memory cells exceeds 1024";
    addr <= 4095;
    @(posedge clk);
    addr <= 4096;
    @(posedge clk);
endtask

task test_alig();
    string_erorr = "Error in read operations";
    for (int i = 0; i < 4096; i = i + 4) begin
        addr <= i;
        @(posedge clk);
    end
endtask

task test_unalig();
    string_erorr = "Incorrect work with unaligned addresses";
    repeat(1000) begin
        std::randomize(addr) with {addr>4096;};
        @(posedge clk);
    end
endtask    

instr_mem_check: assert property (
    @(negedge clk)
    (RD === RDref)
)
else begin
    err_cnt++;
    $error("\naddress = %h(%d)\nyour res : data = 0x%08h\nreference: data = 0x%08h \nNote: %s",
            addr, addr[11:2], RD, RDref, string_erorr);
    if(err_cnt == 10) begin
    $display("\nTest has been stopped after 10 errors");
    $stop();
    end
end

endmodule

module instr_mem_ref(
    input  logic [31:0] addr_i,
    output logic [31:0] read_data_o
    );

`define akjsdnnaskjdn  $clog2(128)
`define cdyfguvhbjnmk  $clog2(`akjsdnnaskjdn)
`define qwenklfsaklasd $clog2(`cdyfguvhbjnmk)
`define asdasdhkjasdsa (34 >> `cdyfguvhbjnmk)

reg [31:0] RAM [0:1023];
initial begin $readmemh("program.mem",RAM); end

always_comb begin
    read_data_o['h1f:'h1c]=RAM[{2'b00, addr_i[5'd28^5'o27:2]}][{5{1'b1}}:{3'd7,2'b00}];
    read_data_o[42-23-:`asdasdhkjasdsa]=RAM[{2'b00, addr_i[5'h1C-5'd17:2]}][19:{1'b1,4'h0}];
    read_data_o[`akjsdnnaskjdn-:`asdasdhkjasdsa]=RAM[{2'b00, addr_i[5'd28^5'o27:2]}][{3{1'b1}}:{1'b1,2'h0}];
    read_data_o[42-19-:`asdasdhkjasdsa]=RAM[{2'b00, addr_i[5'h1C-5'd17:2]}][23:{{2{2'b10}},1'b0}];
    read_data_o['h1b:'h18]=RAM[{2'b00, addr_i[5'h1C-5'd17:2]}][27:{2'b11,3'b000}];
    read_data_o[`akjsdnnaskjdn+`asdasdhkjasdsa:(`akjsdnnaskjdn+`asdasdhkjasdsa)-`cdyfguvhbjnmk]=RAM[{2'b00, addr_i[5'h1C-5'd17:2]}][11:8];
    read_data_o[`akjsdnnaskjdn-`asdasdhkjasdsa-:`asdasdhkjasdsa]=RAM[{2'b00, addr_i[5'd28^5'o27:2]}][3:0];
    read_data_o[(`akjsdnnaskjdn<<(`asdasdhkjasdsa-`cdyfguvhbjnmk)) + (`asdasdhkjasdsa-`cdyfguvhbjnmk):12 ]=RAM[{2'b00, addr_i[5'h1C-5'd17:2]}][{4{1'b1}}:12];
end
endmodule


