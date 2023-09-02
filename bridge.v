`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.08.2023 23:41:33
// Design Name: 
// Module Name: bridge
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


module bridge(
input clk,arvalid,res_n,
input [1:0]arburst,
input [3:0]arlen,
input [4:0]araddr,
output arready,
output reg [15:0]rdata,
output rresp,rlast,
input rready,
output rvalid,

input awvalid,
input [4:0]awaddr,
output awready,
input [3:0]awlen,
input [1:0]awburst,

input wvalid,
input [15:0]wdata,
output wready,
input wlast,

input bready,
output bvalid,
output bresp,

output [2:0]PADDR,
output reg [15:0]PWDATA,
input [15:0]PRDATA,
output PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4,
input PREADY
    );
    
    parameter IDLE = 4'b0000,SETUP_M = 4'b0001,SETUP_S = 4'b0010,
              ACCESS_S = 4'b0011,PREACCESS_M = 4'b0100,ACCESS_M = 4'b0101,
              WSETUP_M =4'b0110,WPREACCESS_M = 4'b0111,WACCESS_M = 4'b1000,
              WTERMINATE = 4'b1001,WSETUP_S = 4'b1010,WACCESS_S = 4'b1011;
    reg [3:0]current_state,next_state=IDLE;
    reg [1:0]DWREQ = 0;
    reg [12:0]burst;
    reg [3:0]lenS;
    reg [3:0]lenM;
    reg [4:0]addr;
    reg [15:0]DDATA[15:0];
    reg [2:0]DADDR = 0;
    integer i = 0;
    reg last;
    
//    initial
//      begin
//        DDATA[0] = 16'h00;
//        DDATA[1] = 16'h00;
//        DDATA[2] = 16'h00;
//        DDATA[3] = 16'h00;
//        DDATA[4] = 16'h00;
//        DDATA[5] = 16'h00;
//        DDATA[6] = 16'h00;
//      end 
    
    always@(posedge clk,negedge res_n)
    begin
      if(!res_n)
        current_state <= IDLE;
      else 
        current_state <= next_state;
    end
    
    
    always@(arvalid,current_state,rready,PREADY,awvalid,wvalid)
    begin
      case(current_state)
        IDLE : begin
                 i = 0;
                 last = 0;
                 rdata = 0;
                 DWREQ = 0;
                 PWDATA = 0;
                 if(arvalid)
                   begin
                     next_state <= SETUP_M; 
                     DWREQ = 2'b01;
                   end
                 else if(awvalid)
                   begin
                     next_state <= WSETUP_M;

                   end
                 else
                     next_state <=IDLE;   
               end
               
        WSETUP_M : begin
                     if(awvalid)
                     begin
                       addr = awaddr;
                       burst = awburst;
                       lenS = awlen + 1;
                       lenM = awlen + 1;
                       DADDR = addr % 8;
                       next_state <= WPREACCESS_M;
                     end
                     else 
                       next_state <= IDLE;  
                   end 
                   
        WPREACCESS_M : begin
                         if(wvalid)
                           next_state <= WACCESS_M;
                         else 
                           next_state <= WPREACCESS_M;
                       end      
        
        WACCESS_M : begin
                   if(lenM != 4'd0)
                     begin
                       if(wlast)
                         next_state <= WTERMINATE;
                       else 
                         next_state <= WPREACCESS_M;
                       DDATA[i] = wdata;
                       case(burst)
                         2'b00: i = i;
                         2'b01: i = i + 1;
                         default : i = i;
                       endcase
                       lenM = lenM - 1; 
                     end
                   else 
                     next_state <= WTERMINATE;
                 end 
               
        WTERMINATE : begin
                       if(bready)
                         begin
                           next_state <= WSETUP_S;
                           DWREQ = 2'b11;
                         end
                       else 
                         next_state <= WTERMINATE;
                     end
              
        WSETUP_S : begin
                     next_state <= WACCESS_S;
                   end
                
        WACCESS_S : begin
                      if(PREADY)
                        begin
                          if(lenS != 4'd0)
                            begin
                              if(lenS == 4'd1)
                                next_state <= IDLE;
                              else 
                                next_state <= WSETUP_S;
                              i = i - 1;
                              DADDR = DADDR + 1;
                              PWDATA = DDATA[i];
                              lenS = lenS - 1;
                               
                            end
                        end
                      else 
                        next_state <= IDLE;
                    end
              
        SETUP_M : begin
                    if(arvalid)
                    begin
                      addr = araddr;
                      burst = arburst;
                      lenS = arlen; 
                      lenM = arlen + 1;
                      DADDR = addr % 8;
                      next_state <= SETUP_S;
                    end 
                    else 
                      next_state <= IDLE;                  
                  end
        
        SETUP_S : begin
                    if(PREADY)
                      begin
                        DDATA[i] = PRDATA;
                        next_state <= ACCESS_S;
                      end 
                    else 
                      next_state <= SETUP_S;
                  end  
                  
        ACCESS_S : begin
                     if(lenS != 0)
                       begin
                         case(burst)
                         2'b00 : DADDR = DADDR;
                         2'b01 : DADDR = DADDR + 1;
                         default : DADDR = DADDR;
                         endcase 
                       lenS = lenS - 1;
                       i = i + 1;
                       next_state <= SETUP_S; 
                       end
                     else 
                       next_state <= PREACCESS_M;
                   end
                   
        PREACCESS_M : begin
                        if(rready)
                          next_state <= ACCESS_M;
                        else 
                          next_state <= PREACCESS_M; 
                      end 
                      
        ACCESS_M : begin
                     if(lenM != 0)
                       begin
                         if(lenM == 4'd1)
                           begin
                             last = 1;
                             next_state <= IDLE;
                           end
                         else 
                           next_state <= PREACCESS_M;
                         rdata = DDATA[i];
                         i = i - 1;
                         lenM = lenM - 1;
                       end
                     else 
                       next_state <= IDLE;
                   end
        
        default : next_state <= IDLE;
         
      endcase 
    end
    
    assign arready = (current_state == SETUP_M);
    assign PADDR = DWREQ[0] ? DADDR : 3'd0;
    assign PSEL1 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S || current_state == WSETUP_S || current_state == WACCESS_S)?((addr >= 5'b00000 && addr <= 5'b00111) ? 1 : 0) : 0;
    assign PSEL2 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S || current_state == WSETUP_S || current_state == WACCESS_S)?((addr >= 5'b01000 && addr <= 5'b01111) ? 1 : 0) : 0;
    assign PSEL3 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S || current_state == WSETUP_S || current_state == WACCESS_S)?((addr >= 5'b10000 && addr <= 5'b10111) ? 1 : 0) : 0;
    assign PSEL4 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S || current_state == WSETUP_S || current_state == WACCESS_S)?((addr >= 5'b11000 && addr <= 5'b11111) ? 1 : 0) : 0;
    assign PWRITE = (DWREQ[1] && (PSEL1 || PSEL2 || PSEL3 || PSEL4));
    assign PENABLE = (current_state == SETUP_S || current_state == ACCESS_S || current_state == WACCESS_S);
    assign rresp = (current_state == ACCESS_M);
    assign rlast = (rresp && last);
    assign rvalid = (current_state == ACCESS_M);
    assign awready = (current_state == WSETUP_M);
    assign wready = (current_state == WACCESS_M);
    assign bvalid = (current_state == WTERMINATE);
    assign bresp = (current_state == WTERMINATE);
    
endmodule
