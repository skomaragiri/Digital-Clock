`timescale 1ns / 1ps

module top(input clk, Resetn, E, output [7:4] A, [3:0] AN, [6:0] dis);
assign A = 4'b1111;
assign DP = 1'b1;
wire outsignal_1, outsignal_400;
wire [1:0] Q;
wire [5:0] Sec;
wire [5:0] Min;
wire [6:0] lower_sec;
wire [6:0] upper_sec;
wire [6:0] lower_min;
wire [6:0] upper_min;
Clockgen stage0(clk, outsignal_400, outsignal_1);
twobitcounter stage1(Resetn, outsignal_400, E, Q);
twotofourdecoder stage2(Q, AN);
sixbitcounter stage3(Resetn, outsignal_1, E, Sec, Min);
sevensegment stage4(Sec, lower_sec, upper_sec);
sevensegment stage5(Min, lower_min, upper_min);
mux4(Q, lower_sec, upper_sec, lower_min, upper_min, dis);
endmodule


module mux4(select, A, B, C, D, dis);
input [1:0] select;
input [6:0] A, B, C ,D;
output reg [6:0] dis;
always @(select or A or B or C or D)
if(select==2'b00) dis = A;
else if(select==2'b01) dis = B;
else if(select==2'b10) dis = C;
else if(select==2'b11) dis = D;
endmodule

module Clockgen(clk, outsignal_400, outsignal_1);
    input clk;
    output  outsignal_400, outsignal_1;
    reg [16:0] counter;
    reg[25:0] counter_1;
    reg outsignal_400, outsignal_1;
    always @ (posedge clk)
    begin
    counter = counter +1;
    counter_1 = counter_1 +1;
    if (counter == 125_000)
            begin
            outsignal_400=~outsignal_400;
            counter =0;
            end
    if (counter_1 == 50_000_000)
            begin
            outsignal_1=~outsignal_1;
            counter_1 =0;
            end
        end
    endmodule
    
    
module twobitcounter (input Resetn, Clock, E, output reg [1:0] Q);              //2bit counter taking 400Hz in clock
always @(negedge Resetn, posedge Clock)
begin
if (!Resetn)
    Q <= 0;
else
    begin 
    if (E)
        Q <= Q + 1;
    end
end
endmodule

module sixbitcounter (input Resetn, Clock, E, output reg [5:0] Q, reg [5:0] Min);              //use this for both seconds and minutes
always @(negedge Resetn, posedge Clock)
begin
if (!Resetn)
begin
    Q <= 0;
    Min <= 0;
    end
else
    begin 
    if (E)
        Q <= Q + 1;
    if (Q > 58)
    begin
        Q <= 0;
        Min <= Min + 1;
    end
        if (Min > 58 && Q > 58)
        Min <= 0;
       end
end
endmodule

module twotofourdecoder(input [1:0]data,output reg [3:0]C);                              //used with twobitcounter for enable signal into 4-1mux
always@(data)
begin
case (data)
    2'b00 : C = 4'b1110;
    2'b01 : C = 4'b1101;
    2'b10 : C = 4'b1011;
    2'b11 : C = 4'b0111;
    default: 
    C = 4'b0000;
endcase
end
endmodule

module sevensegment(input [5:0] y, output reg [6:0] C, reg [6:0] D);
integer upper;
integer lower;
always@(y)
begin
lower = y%10;
upper = y/10;
upper= upper%10;
begin
case(lower)
0 : C = 7'b1000000;
1 : C = 7'b1111001;
2 : C = 7'b0100100;
3 : C = 7'b0110000;
4 : C = 7'b0011001;
5 : C = 7'b0010010;
6 : C = 7'b0000010;
7 : C = 7'b1111000;
8 : C = 7'b0000000;
9 : C = 7'b0010000;
default: C = 7'b0000000;
endcase
begin
case(upper)
0 : D = 7'b1000000;
1 : D = 7'b1111001;
2 : D = 7'b0100100;
3 : D = 7'b0110000;
4 : D = 7'b0011001;
5 : D = 7'b0010010;
6 : D = 7'b0000010;
7 : D = 7'b1111000;
8 : D = 7'b0000000;
9 : D = 7'b0010000;
default: D = 7'b0000000;
endcase
    end
    end
    end
endmodule

