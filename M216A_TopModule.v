`timescale 1ns / 100ps

//Do NOT Modify This
module P1_Reg_8_bit (DataIn, DataOut, rst, clk);

    input [7: 0] DataIn;
    output [7: 0] DataOut;
    input rst;
    input clk;
    reg [7:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg  <= 8'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg ;          
endmodule

module P1_Reg_5_bit (DataIn, DataOut, rst, clk);

    input [4: 0] DataIn;
    output [4: 0] DataOut;
    input rst;
    input clk;
    reg [4:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg  <= 5'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg ;          
endmodule

module P1_Reg_4_bit (DataIn, DataOut, rst, clk);

    input [3: 0] DataIn;
    output [3: 0] DataOut;
    input rst;
    input clk;
    reg [3:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg  <= 4'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg ;          
endmodule

//Write enable 8-bit reg

module P1_Reg_8_bit_with_En (DataIn, DataOut, rst, clk, En);

    input [7: 0] DataIn;
    output [7: 0] DataOut;
    input rst;
    input clk;
	input En;
    reg [7:0] DataReg;

    always @(posedge clk)
        if(rst)
            DataReg  <= 8'b0;
        else
            if(En) DataReg <= DataIn;
    assign DataOut = DataReg ;
endmodule

// Reset and Clock Controller

module clock_gen (
    input clk_i, rst,
    output clk_A_E, clk_B_F, clk_C_out, clk_in_D,
    output reg rst_o
);

    reg [2:0] counter;

    always @(posedge clk_i or posedge rst) begin
        if (rst) begin
            counter <= 3'b000;
            rst_o <= 1;
        end
        else begin
            counter <= counter + 1;
            rst_o <= 0;
        end
    end

    assign clk_in_D   = (counter[1:0] == 2'b10);
    assign clk_A_E    = (counter[1:0] == 2'b11);
    assign clk_B_F    = (counter[1:0] == 2'b00);
    assign clk_C_out  = (counter[1:0] == 2'b01);

endmodule

module reset_gen(
  input clk_i, rst_o, clk_A_E, clk_B_F, clk_in_D,
  output reg rst_D, rst_E, rst_F
);

    always @(posedge clk_i)
    begin
        if(rst_o)
        begin
            rst_D <= 1;
            rst_E <= 1;
            rst_F <= 1;    
        end

        if(rst_D && clk_in_D)
            rst_D <= 0;

        if(rst_E && clk_A_E)
            rst_E <= 0;

        if(rst_F && clk_B_F)
            rst_F <= 0;
    end

endmodule

/*
Every Input-Output combination has latency of 8 cycles
1. I - Input Sampling 
2. A - Find candidate rows
3. B - Read from register array
4. C - Find Min occupied width
5. D - Find winner / Strike 
6. E - Write to register array
7. F - Find output coordinates
8. O - Ouptut Sampling

Pipeline Flow
1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19
I1  A1  B1  C1  D1  E1  F1  O1
                I2  A2  B2  C2  D2  E2  F2  O2
                                I3  A3  B3  C3  D3  E3  F3  O3
                                                I4  A4  B4  C4  D4  E4  F4  O4

Stages Interface
I-A: h_in, w_in
A-B: r_1, r_2, r_3, h_in, w_in
B-C: w_1, w_2, w_3, h_in, w_in, r_1, r_2, r_3
C-D: w_min, r_min, h_in, w_in
D-E: r_win, w_win, str, h_in, w_in
E-F: r_win, w_win, str, h_in, w_in
F-O: str, x_out, y_out 
*/

// A stage
    // Inputs: h_in, w_in
    // Outputs: A_B_r_1, A_B_r_2, A_B_r_3, A_B_h_in, A_B_w_in
module A_stage(clk_A, h_in, w_in, A_B_r_1, A_B_r_2, A_B_r_3);
    input clk_A;
    input [4:0] h_in, w_in;
    output reg [3:0] A_B_r_1, A_B_r_2, A_B_r_3;

    always @(posedge clk_A)
    begin

    case(h_in) //synopsys parallel_case
        5'd4:
        begin
            A_B_r_1 <= 4'd2;
            A_B_r_2 <= 4'd4;
            A_B_r_3 <= 0;
        end
        5'd5:
        begin
            A_B_r_1 <= 4'd4;
            A_B_r_2 <= 4'd6;
            A_B_r_3 <= 0;
        end
        5'd6:
        begin
            A_B_r_1 <= 4'd6;
            A_B_r_2 <= 4'd8;
            A_B_r_3 <= 0;
        end
        5'd7:
        begin
            A_B_r_1 <= 4'd8;
            A_B_r_2 <= 4'd9;
            A_B_r_3 <= 4'd10;
        end
        5'd8:
        begin
            A_B_r_1 <= 4'd9;
            A_B_r_2 <= 4'd10;
            A_B_r_3 <= 4'd7;
        end
        5'd9:
        begin
            A_B_r_1 <= 4'd5;
            A_B_r_2 <= 4'd7;
            A_B_r_3 <= 4'd0;
        end
        5'd10:
        begin
            A_B_r_1 <= 4'd5;
            A_B_r_2 <= 4'd3;
            A_B_r_3 <= 4'd0;
        end
        5'd11:
        begin
            A_B_r_1 <= 4'd3;
            A_B_r_2 <= 4'd1;
            A_B_r_3 <= 4'd0;
        end
        5'd12:
        begin
            A_B_r_1 <= 4'd1;
            A_B_r_2 <= 4'd0;
            A_B_r_3 <= 4'd0;
        end
        5'd13:
        begin
            A_B_r_1 <= 4'd11;
            A_B_r_2 <= 4'd12;
            A_B_r_3 <= 4'd13;
        end
        5'd14:
        begin
            A_B_r_1 <= 4'd11;
            A_B_r_2 <= 4'd12;
            A_B_r_3 <= 4'd13;
        end
        5'd15:
        begin
            A_B_r_1 <= 4'd11;
            A_B_r_2 <= 4'd12;
            A_B_r_3 <= 4'd13;
        end
        5'd16:
        begin
            A_B_r_1 <= 4'd11;
            A_B_r_2 <= 4'd12;
            A_B_r_3 <= 4'd13;
        end
        default:
        begin
            A_B_r_1 <= 4'd0;
            A_B_r_2 <= 4'd0;
            A_B_r_3 <= 4'd0;
        end
    endcase

    end
endmodule

// B stage
    // Inputs: A_B_r_1, A_B_r_2, A_B_r_3, A_B_h_in, A_B_w_in
    // Outputs: B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3

// C stage
    // Inputs: B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3
    // Outputs: C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in 
module C_stage(clk_C, B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3, C_D_w_min, C_D_r_min);
    input clk_C;
    input [7:0] B_C_w_1, B_C_w_2, B_C_w_3;
    input [4:0] B_C_h_in, B_C_w_in;
    input [3:0] B_C_r_1, B_C_r_2, B_C_r_3;
    output reg [7:0] C_D_w_min;
    output reg [3:0] C_D_r_min;

    always @(posedge clk_C)
    begin
        if(B_C_r_3 == 0) begin
            //two strips to be compared
            if(B_C_r_2 == 0) begin
                C_D_r_min <= B_C_r_1;
                C_D_w_min <= B_C_w_1;
            end
            else begin
                if(B_C_w_1 <= B_C_w_2) begin
                    C_D_r_min <= B_C_r_1;
                    C_D_w_min <= B_C_w_1;
                end
                else begin
                    C_D_r_min <= B_C_r_2;
                    C_D_w_min <= B_C_w_2;
                end
            end
        end
        else begin
            //three strips to be compared
            if((B_C_w_1 <= B_C_w_2) && (B_C_w_1 <= B_C_w_3)) begin    
                C_D_r_min <= B_C_r_1;
                C_D_w_min <= B_C_w_1;
            end
            else if((B_C_w_2 <= B_C_w_1) && (B_C_w_2 <= B_C_w_3)) begin
                C_D_r_min <= B_C_r_2;
                C_D_w_min <= B_C_w_2;
            end
            else begin
                C_D_r_min <= B_C_r_3;
                C_D_w_min <= B_C_w_3;
            end
        end    
    end
endmodule

// D stage
    // Inputs: C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in
    // Outpus: D_E_r_win, D_E_w_win, D_E_str, D_E_h_in, D_E_w_in
module D_stage(clk_D, D_rst, C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in, D_E_r_win, D_E_w_win, D_E_str);
    input clk_D, D_rst;
    input [7:0] C_D_w_min;
    input [3:0] C_D_r_min; 
    input [4:0] C_D_h_in, C_D_w_in;
    output reg [3:0] D_E_r_win; 
    output reg [7:0] D_E_w_win; 
    output reg [3:0] D_E_str; 

    always @(posedge clk_D)
    begin
        if(D_rst) begin
            D_E_r_win <= 4'b0;
            D_E_w_win <= 8'b0;
            D_E_str <= 4'b0;
        end
        else begin
            if((C_D_w_min + C_D_w_in) <= 128) begin
                D_E_r_win <= C_D_r_min;
                D_E_w_win <= C_D_w_min;
            end
            else begin
                D_E_str <= D_E_str + 1;
                D_E_r_win <= 4'b0;
                D_E_w_win <= 8'b0;
            end
        end
    end
endmodule

// E stage
    // Inputs: D_E_r_win, D_E_w_win, D_E_str, D_E_h_in, D_E_w_in
    // Outputs: E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in

// F stage
    // Inputs: E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in
    // Outputs: str, x_out, y_out 
module F_stage(clk_F, F_rst, E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in, str, x_out, y_out);
    input clk_F, F_rst;
    input [3:0] E_F_r_win;
    input [7:0] E_F_w_win;
    input [3:0] E_F_str;
    input [4:0] E_F_h_in, E_F_w_in;
    output reg [3:0] str;
    output reg [7:0] x_out, y_out;

    always @(posedge clk_F)
    begin
        if(F_rst) begin
            str <= 4'b0;
            x_out <= 8'b0;
            y_out <= 8'b0;
        end
        else begin
            str <= E_F_str;

            if(E_F_r_win == 0) begin
                x_out <= 8'd128; 
                y_out <= 8'd128;    
            end
            else begin
                x_out <= E_F_w_win;

                case(E_F_r_win) //synopsys parallel_case
                    4'd1: y_out <= 8'd0;
                    4'd2: y_out <= 8'd12;
                    4'd3: y_out <= 8'd16;
                    4'd4: y_out <= 8'd27;
                    4'd5: y_out <= 8'd32;
                    4'd6: y_out <= 8'd42;
                    4'd7: y_out <= 8'd48;
                    4'd8: y_out <= 8'd57;
                    4'd9: y_out <= 8'd64;
                    4'd10: y_out <= 8'd72;
                    4'd11: y_out <= 8'd80;
                    4'd12: y_out <= 8'd96;
                    4'd13: y_out <= 8'd112;
                    default: y_out <= 8'd128;
                endcase
            end
        end
    end
endmodule

//Do NOT Modify This
module M216A_TopModule(
    clk_i,
    width_i,
    height_i,
    index_x_o,
    index_y_o,
    strike_o,
    // Occupied_Width,
    rst_i);
    input clk_i;
    input [4:0]width_i;
    input [4:0]height_i;
    output [7:0]index_x_o, index_y_o;
    // output [7:0]Occupied_Width[12:0];  // Connect it to a 13 element Register array
    output [3:0]strike_o;
    input rst_i;

    wire [4:0] width_i, height_i;
    wire clk_i, rst_i;

    // Clock and Reset Controller Generator
    wire clk_A_E, clk_B_F, clk_C_out, clk_in_D, rst_o; 
    wire rst_D, rst_E, rst_F;

    clock_gen clk_gen (clk_i, rst_i, clk_A_E, clk_B_F, clk_C_out, clk_in_D, rst_o);
    reset_gen rst_gen (clk_i, rst_o, clk_A_E, clk_B_F, clk_in_D, rst_D, rst_E, rst_F);

    // Register array
    reg [7:0] already_occupied [0:13];
    integer k;

    // Pipeline stages  

    // I stage
    // Inputs: height_i, width_i
    // Outputs: h_in, w_in

    wire [4:0] h_in, w_in;

    P1_Reg_5_bit height_input_reg (.DataIn(height_i), .DataOut(h_in), .rst(rst_i), .clk(clk_in_D));
    P1_Reg_5_bit width_input_reg (.DataIn(width_i), .DataOut(w_in), .rst(rst_i), .clk(clk_in_D));

    // A stage
    // Inputs: h_in, w_in
    // Outputs: A_B_r_1, A_B_r_2, A_B_r_3, A_B_h_in, A_B_w_in

    wire [4:0] A_B_h_in, A_B_w_in;
    wire [3:0] A_B_r_1, A_B_r_2, A_B_r_3;

    A_stage pipe_stage_A(clk_A_E, h_in, w_in, A_B_r_1, A_B_r_2, A_B_r_3);//, A_B_h_in, A_B_w_in);
    
    P1_Reg_5_bit A_B_height_reg(h_in, A_B_h_in, rst_i, clk_A_E);
    P1_Reg_5_bit A_B_width_reg(w_in, A_B_w_in, rst_i, clk_A_E);

    // B stage
    // Inputs: A_B_r_1, A_B_r_2, A_B_r_3, A_B_h_in, A_B_w_in
    // Outputs: B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3

    wire [4:0] B_C_h_in, B_C_w_in;
    wire [3:0] B_C_r_1, B_C_r_2, B_C_r_3;
    reg [7:0] B_C_w_1, B_C_w_2, B_C_w_3;

    always @(posedge clk_B_F)
    begin
        if(A_B_r_1 != 0)
            B_C_w_1 <= already_occupied[A_B_r_1];
        if(A_B_r_2 != 0)
            B_C_w_2 <= already_occupied[A_B_r_2];
        if(A_B_r_3 != 0)
            B_C_w_3 <= already_occupied[A_B_r_3];
    end

    P1_Reg_5_bit B_C_height_reg(A_B_h_in, B_C_h_in, rst_i, clk_B_F);
    P1_Reg_5_bit B_C_width_reg(A_B_w_in, B_C_w_in, rst_i, clk_B_F);
    P1_Reg_4_bit B_C_r_1_reg(A_B_r_1, B_C_r_1, rst_i, clk_B_F);
    P1_Reg_4_bit B_C_r_2_reg(A_B_r_2, B_C_r_2, rst_i, clk_B_F);
    P1_Reg_4_bit B_C_r_3_reg(A_B_r_3, B_C_r_3, rst_i, clk_B_F);

    // C stage
    // Inputs: B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3
    // Outputs: C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in 
    
    wire [4:0] C_D_h_in, C_D_w_in;
    wire [3:0] C_D_r_min;
    wire [7:0] C_D_w_min;
    
    C_stage pipe_stage_C(clk_C_out, B_C_w_1, B_C_w_2, B_C_w_3, B_C_h_in, B_C_w_in, B_C_r_1, B_C_r_2, B_C_r_3, C_D_w_min, C_D_r_min);//, C_D_h_in, C_D_w_in);

    P1_Reg_5_bit C_D_height_reg(B_C_h_in, C_D_h_in, rst_i, clk_C_out);
    P1_Reg_5_bit C_D_width_reg(B_C_w_in, C_D_w_in, rst_i, clk_C_out);

    // D stage
    // Inputs: C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in
    // Outpus: D_E_r_win, D_E_w_win, D_E_str, D_E_h_in, D_E_w_in
    
    wire [4:0] D_E_h_in, D_E_w_in;
    wire [3:0] D_E_r_win, D_E_str;
    wire [7:0] D_E_w_win;
    
    D_stage pipe_stage_D(clk_in_D, rst_D, C_D_w_min, C_D_r_min, C_D_h_in, C_D_w_in, D_E_r_win, D_E_w_win, D_E_str);//, D_E_h_in, D_E_w_in);

    P1_Reg_5_bit D_E_height_reg(C_D_h_in, D_E_h_in, rst_D, clk_in_D);
    P1_Reg_5_bit D_E_width_reg(C_D_w_in, D_E_w_in, rst_D, clk_in_D);

    // E stage
    // Inputs: D_E_r_win, D_E_w_win, D_E_str, D_E_h_in, D_E_w_in
    // Outputs: E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in
    
    wire [4:0] E_F_h_in, E_F_w_in;
    wire [3:0] E_F_r_win, E_F_str;
    wire [7:0] E_F_w_win;

    always @(posedge clk_A_E)
    begin
        if(rst_E)
        begin
            for (k = 0; k < 14; k = k + 1) begin
                already_occupied[k] <= 8'b0;
            end
        end 
        else
        begin
            if(D_E_r_win != 0)
                already_occupied[D_E_r_win] <= D_E_w_win + D_E_w_in;
        end
    end

    P1_Reg_5_bit E_F_height_reg(D_E_h_in, E_F_h_in, rst_E, clk_A_E);
    P1_Reg_5_bit E_F_width_reg(D_E_w_in, E_F_w_in, rst_E, clk_A_E);
    P1_Reg_4_bit E_F_r_win_reg(D_E_r_win, E_F_r_win, rst_E, clk_A_E);
    P1_Reg_8_bit E_F_w_win_reg(D_E_w_win, E_F_w_win, rst_E, clk_A_E);
    P1_Reg_4_bit E_F_str_reg(D_E_str, E_F_str, rst_E, clk_A_E);

    // F stage
    // Inputs: E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in
    // Outputs: str, x_out, y_out 

    wire [3:0] str;
    wire [7:0] x_out, y_out;
    
    F_stage pipe_stage_F(clk_B_F, rst_F, E_F_r_win, E_F_w_win, E_F_str, E_F_h_in, E_F_w_in, str, x_out, y_out);

    // O stage
    // Inputs: str, x_out, y_out
    // Outputs: index_x_o, index_y_o, strike_o
    P1_Reg_8_bit index_x_output_reg (.DataIn(x_out), .DataOut(index_x_o), .rst(rst_i), .clk(clk_C_out));
    P1_Reg_8_bit index_y_output_reg (.DataIn(y_out), .DataOut(index_y_o), .rst(rst_i), .clk(clk_C_out));
    P1_Reg_4_bit strike_output_reg (.DataIn(str), .DataOut(strike_o), .rst(rst_i), .clk(clk_C_out));

endmodule
