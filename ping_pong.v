`timescale 1ns / 1ps
`include "ball.v"
`include "paddle.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2023 02:13:58 PM
// Design Name: 
// Module Name: ping_pong
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


module ping_pong(
        Ox,
        Oy,
        sysclk,
        p1b1,
        p1b2,
        p2b1,
        p2b2,
        divclk,
        divclk2,
        divclk3
    );
    input sysclk;
    input p1b1;
    input p1b2;
    input p2b1;
    input p2b2;
    
    output [7:0] Ox;
    output [7:0] Oy;
    
    wire [7:0] Sx;
    wire [7:0] Sy;
    
    wire [7:0] Px1;
    wire [7:0] Py1;
    
    wire [7:0] Px2;
    wire [7:0] Py2;
    
    wire [7:0] Px;
    wire [7:0] Py;
    
    wire [2:0] Wx;
    wire [2:0] Wy;
    
    
    output divclk;
    output divclk2;
    output divclk3;
    //circuit
    reg ball_on = 1;
    reg paddle_on1 = 0;
    reg paddle_on2 = 0;
    
    ball_write l1(Wx, Wy, Sx, Sy, ball_on);
    
    reg [2:0] dir = 3'b001;
    
    
    reg [2:0] X = 3'b100;
    reg [2:0] Y = 3'b100;
    
    reg [2:0] P1 = 3'b000;
    reg [2:0] P2 = 3'b000;
    
    integer ctr = 0;
    
    //paddle write
    paddle_write1 d1(P1, Px1, Py1, paddle_on1);
    paddle_write2 d2(P2, Px2, Py2, paddle_on2);
    
    
    
    assign Wx = X;
    assign Wy = Y;

    assign Ox = Sx | Px1 | Px2;
    assign Oy = Sy | Py1 | Py2;
    
    //my cloock at 400 hz
    freq_div f1(sysclk, divclk);
    freq_div2 f2(sysclk, divclk2);
    freq_div3 f3(sysclk, divclk3);
    //loop
    always @(posedge divclk2)
    begin
    
        if (p1b1 == 1)
        begin
            if (P1 != 3'b000)
                P1 = P1 - 1;
        end
        if (p1b2 == 1)
        begin
            if (P1 != 3'b110)
                P1 = P1 + 1;
        end
        if (p2b1 == 1)
        begin
            if (P2 != 3'b000)
                P2 = P2 - 1;
        end
        if (p2b2 == 1)
        begin
            if (P2 != 3'b110)
                P2 = P2 + 1;
        end
    end

    always @(posedge divclk3)
    begin
        if (ctr % 3 == 0)
        begin
            ball_on = 1;
            paddle_on1 = 0;
            paddle_on2 = 0;
        end
        
        if (ctr % 3 == 1)
        begin
            ball_on = 0;
            paddle_on1 = 1;
            paddle_on2 = 0;
        end
        if (ctr % 3 == 2)
        begin
            ball_on = 0;
            paddle_on1 = 0;
            paddle_on2 = 1;
        end
        ctr = ctr + 1;
    end
    
    always @(posedge divclk)
    begin
        if (ctr % 3 == 0 )
        begin
        //
        if (X == 3'b000)
        begin
            if (dir == 3'b011)
                dir = 3'b001;
            if (dir == 3'b100)
                dir = 3'b000;
            if (dir == 3'b101)
               dir = 3'b111;
        end
        if (X == 3'b111)
        begin
            if (dir == 3'b000)
                dir = 3'b100;
            if (dir == 3'b001)
                dir = 3'b011;
            if (dir == 3'b111)
               dir = 3'b101;       
        end
        
        if (Y == 3'b000 )
        begin
            /*
            if (dir == 3'b101)
                dir = 3'b011;
            if (dir == 3'b110)
                dir = 3'b010;
            if (dir == 3'b111)
               dir = 3'b001;
            */
            if (P2 == X)
            begin
                dir = 3'b011;
            end
            else if (P2 + 1 == X)
            begin
                dir = 3'b001;
            end
            else
            begin
                X = 3'b100;
                Y = 3'b100;
                dir = 3'b010;
            end
        end
        if (Y == 3'b111)
        begin
            /*
            if (dir == 3'b001)
                dir = 3'b111;
            if (dir == 3'b010)
                dir = 3'b110;
            if (dir == 3'b011)
               dir = 3'b101;
               
            */
            if (P1 == X)
            begin
                dir = 3'b101;
            end
            else if (P1 + 1 == X)
            begin
                dir = 3'b111;
            end
            else
            begin
                X = 3'b100;
                Y = 3'b100;
                dir = 3'b110;
            end
        end

        //
        if (dir == 3'b000)
        begin
            X = X + 1;
        end
        if (dir == 3'b001)
        begin
            X = X + 1;
            Y = Y + 1;
        end
        if (dir == 3'b010)
        begin
            Y = Y + 1;
        end
        if (dir == 3'b011)
        begin
            X = X - 1;
            Y = Y + 1;
        end
        if (dir == 3'b100)
        begin
            X = X - 1;
        end
        if (dir == 3'b101)
        begin
            X = X - 1;
            Y = Y - 1;
        end
        if (dir == 3'b110)
         begin
            Y = Y - 1;
        end
        if (dir == 3'b111)
        begin
            X = X + 1;
            Y = Y - 1;
        end
        end
    end

endmodule

module freq_div(clk, out_clk);
    input clk;
    output reg out_clk;

    reg[27:0] counter = 28'd0;
    parameter DIVISOR = 28'd7000000;
    
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter >= (DIVISOR-1))
            counter <= 28'd0;
         
        out_clk <= (counter < DIVISOR/2) ? 1'b1 : 1'b0; 
    end
endmodule

module freq_div2(clk, out_clk);
    input clk;
    output reg out_clk;

    reg[27:0] counter = 28'd0;
    parameter DIVISOR = 28'd10000000;
    
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter >= (DIVISOR-1))
            counter <= 28'd0;
         
        out_clk <= (counter < DIVISOR/2) ? 1'b1 : 1'b0; 
    end
endmodule

module freq_div3(clk, out_clk);
    input clk;
    output reg out_clk;

    reg[27:0] counter = 28'd0;
    parameter DIVISOR = 28'd2000000;
    
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter >= (DIVISOR-1))
            counter <= 28'd0;
         
        out_clk <= (counter < DIVISOR/2) ? 1'b1 : 1'b0; 
    end
endmodule
/*
module sim();
    reg sysclk;
    reg p1b1;
    reg p1b2;
    reg p2b1;
    reg p2b2;
    
    wire [7:0] Ox;
    wire [7:0] Oy;
    wire divclk;

    ping_pong b1(Ox, Oy, sysclk, p1b1, p1b2, p2b1, p1b2, divclk);
    
    initial
    begin
        assign sysclk = 0;
        assign p1b1 = 0;
        assign p1b2 = 0;
        assign p2b1 = 0;
        assign p2b2 = 0;
        
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        #1 assign sysclk = 1;
        #1 assign sysclk = 0;
        $finish;
    end
endmodule
*/

