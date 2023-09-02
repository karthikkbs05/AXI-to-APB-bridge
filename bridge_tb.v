`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2023 23:54:10
// Design Name: 
// Module Name: bridge_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bridge_tb;
reg clk,arvalid,res_n;
reg [1:0]arburst;
reg [3:0]arlen;
reg [4:0]araddr;
wire arready;
wire [15:0]rdata;
wire rresp,rlast;
reg rready;
wire rvalid;

reg awvalid;
reg [4:0]awaddr;
wire awready;
reg [3:0]awlen;
reg [1:0]awburst;

reg wvalid;
reg [15:0]wdata;
wire wready;
reg wlast;

reg bready;
wire bvalid;
wire bresp;

wire [2:0]PADDR;
wire [15:0]PWDATA;
reg [15:0]PRDATA;
wire PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4;
reg PREADY;

bridge dut(clk,arvalid,res_n,arburst,arlen,araddr,arready,rdata,rresp,rlast,rready,
           rvalid,awvalid,awaddr,awready,awlen,awburst,wvalid,wdata,wready,wlast,bready,
           bvalid,bresp,PADDR,PWDATA,PRDATA,PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4,PREADY);

always #5 clk = ~clk;
initial
  begin
    clk = 0;
    res_n = 0;
    arvalid = 0;
    arburst = 2'b00;
    arlen = 0;
    araddr = 0;
    rready = 0;
    PRDATA = 0; 
    PREADY = 0;
    awvalid = 0;
    awburst = 2'b00; 
    awlen =4'b0000; 
    awaddr = 5'd0;
    wvalid = 0;
    wdata = 0;
    wlast = 0;
    bready = 0; 
  end

initial 
  begin
    #5;
    #10 res_n = 1;
    #10;
    #10 arvalid = 1;arburst = 2'b01; arlen =4'b0011; araddr = 5'd9;
    #10;
    #10 arvalid =0;
    #10 PREADY = 1;PRDATA = 16'd10;
    #10;
    #10 PRDATA = 16'd17;
    #10;
    #10 PRDATA = 16'd25;
    #10;
    #10 PRDATA = 16'd30;
    #10;
    #10 PREADY = 0;
    #10 rready = 1;
    #10;
    #20;
    #20;
    #20;
    #20;
    #10;
    #10 res_n = 0;
    #10 res_n = 1;
    #10;
    #10 awvalid = 1;awburst = 2'b01; awlen =4'b0011; awaddr = 5'd9;
    #10;
    #10 awvalid = 0;
    #10 wvalid = 1; wdata = 16'hffff;
    #10;
    #10 wdata = 16'h1111;
    #10;
    #10 wdata = 16'h2222;
    #10;
    #10 wdata = 16'h3333;wlast = 1;
    #10;
    #10;wlast = 0;wdata = 16'h0000;
    #10;
    #10 bready = 1;
    #10;
    #10 PREADY = 1;
    #20;
    #20;
    #20;
    #20;
    #20 PREADY = 0;
    #20;
    
    $finish;
    
  end
endmodule
