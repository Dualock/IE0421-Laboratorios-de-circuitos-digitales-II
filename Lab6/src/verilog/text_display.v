`include "bin_to_one_hot.v"
`include "bcd_to_7seg.v"
module text_display(
  input clk,
  input resetn,
  input [3:0] selector,
  input enable,
  output [7:0] an_out,
  output [7:0] c_out);

//Codificacion del alfabeto
    parameter[7:0] ZERO       = 8'h00;
    parameter[7:0] ONE        = 8'h01;
    parameter[7:0] TWO        = 8'h02;
    parameter[7:0] THREE      = 8'h03;
    parameter[7:0] FOUR       = 8'h04;
    parameter[7:0] FIVE       = 8'h05;
    parameter[7:0] SIX        = 8'h06;
    parameter[7:0] SEVEN      = 8'h07;
    parameter[7:0] EIGHT      = 8'h08;
    parameter[7:0] NINE       = 8'h09;
    parameter[7:0] A          = 8'h0A;
    parameter[7:0] B          = 8'h0B;
    parameter[7:0] C          = 8'h0C;
    parameter[7:0] D          = 8'h0D;
    parameter[7:0] E          = 8'h0E;
    parameter[7:0] F          = 8'h0F;
    parameter[7:0] G          = 8'h10;
    parameter[7:0] H          = 8'h11;
    parameter[7:0] I          = 8'h12;
    parameter[7:0] J          = 8'h13;
    parameter[7:0] K          = 8'h14;
    parameter[7:0] L          = 8'h15;
    parameter[7:0] M          = 8'h16;
    parameter[7:0] N          = 8'h17;
    parameter[7:0] O          = 8'h18;
    parameter[7:0] P          = 8'h19;
    parameter[7:0] Q          = 8'h1A;
    parameter[7:0] R          = 8'h1B;
    parameter[7:0] S          = 8'h1C;
    parameter[7:0] T          = 8'h1D;
    parameter[7:0] U          = 8'h1E;
    parameter[7:0] V          = 8'h1F;
    parameter[7:0] W          = 8'h20;
    parameter[7:0] EQUIS      = 8'h21;
    parameter[7:0] Y          = 8'h22;
    parameter[7:0] ZETA       = 8'h23;
    parameter[7:0] SPACE    = 8'h24;
    parameter[7:0] ARROBA     = 8'h25;
    //Codificacion del selector
    parameter [3:0] START     = 4'h00;
    parameter [3:0] SELECT    = 4'h01;
    parameter [3:0] PAPER     = 4'h02;
    parameter [3:0] SCISSORS  = 4'h03;
    parameter [3:0] ROCK      = 4'h04;
    parameter [3:0] RIVAL     = 4'h05;
    parameter [3:0] YOU_WON   = 4'h06;
    parameter [3:0] YOU_LOST  = 4'h07;
    parameter [3:0] TIE       = 4'h08;

    reg [63:0] output_word;
    reg [20:0] big_cnt;
    wire [2:0] cnt;
    reg [5:0] num_bcd;
    wire [7:0] an_outn;
    bin_to_one_hot u_bin_to_one_hot (
    .bin        (cnt),
    .one_hot    (an_outn)
    );

    bcd_to_7seg u_bcd_to_7seg (
    .resetn      (resetn),
    .num_bcd     (num_bcd),
    .num_7seg    (c_out)
    );
    always @(posedge clk) begin
        if(!resetn) begin
        output_word <= 0;
        end
        else begin
        if(enable) begin
            case (selector)
            START: begin
                  output_word[7:0] <= T;
                  output_word[15:8] <= R;
                  output_word[23:16] <= A;
                  output_word[31:24] <= T;
                  output_word[39:32] <= S;
                  output_word[47:40] <= SPACE;
                  output_word[55:48] <= SPACE;
                  output_word[63:56] <= SPACE;
            end
            SELECT: begin
                  output_word[7:0] <= T;
                  output_word[15:8] <= C;
                  output_word[23:16] <= E;
                  output_word[31:24] <= L;
                  output_word[39:32] <= E;
                  output_word[47:40]  <= S;
                  output_word[55:48] <= SPACE;
                  output_word[63:56] <= SPACE;
            end
            PAPER: begin
                  output_word[7:0] <= R;
                  output_word[15:8] <= E;
                  output_word[23:16] <= P;
                  output_word[31:24] <= A;
                  output_word[39:32] <= P;
                  output_word[47:40]  <= SPACE;
                  output_word[55:48] <= SPACE;
                  output_word[63:56] <= SPACE;
            end
            SCISSORS: begin
                  output_word[7:0] <= S;
                  output_word[15:8] <= R;
                  output_word[23:16] <= O;
                  output_word[31:24] <= S;
                  output_word[39:32] <= S;
                  output_word[47:40]  <= I;
                  output_word[55:48] <= C;
                  output_word[63:56] <= S;
            end
            ROCK: begin
                  output_word[7:0] <= K;
                  output_word[15:8] <= C;
                  output_word[23:16] <= O;
                  output_word[31:24] <= R;
                  output_word[39:32] <= SPACE;
                  output_word[47:40]  <= SPACE;
                  output_word[55:48] <= SPACE;
                  output_word[63:56] <= SPACE;
            end
            RIVAL: begin
                  output_word[7:0] <= L;
                  output_word[15:8] <= A;
                  output_word[23:16] <= V;
                  output_word[31:24] <= I;
                  output_word[39:32] <= R;
                  output_word[47:40]  <= SPACE;
                  output_word[55:48] <= SPACE;
                  output_word[63:56] <= SPACE;

            end
            YOU_WON: begin
                  output_word[7:0] <= N;
                  output_word[15:8] <= O;
                  output_word[23:16] <= W;
                  output_word[31:24] <= SPACE;
                  output_word[39:32] <= U;
                  output_word[47:40]  <= O;
                  output_word[55:48] <= Y;
                  output_word[63:56] <= SPACE;
            end
            YOU_LOST: begin
                  output_word[7:0] <= T;
                  output_word[15:8] <= S;
                  output_word[23:16] <= O;
                  output_word[31:24] <= L;
                  output_word[39:32] <= SPACE;
                  output_word[47:40]  <= U;
                  output_word[55:48] <= O;
                  output_word[63:56] <= Y;
              end
              endcase
              case (cnt)
                  0: num_bcd = output_word[7:0];
                  1: num_bcd = output_word[15:8];
                  2: num_bcd = output_word[23:16];
                  3: num_bcd = output_word[31:24];
                  4: num_bcd = output_word[39:32];
                  5: num_bcd = output_word[47:40];
                  6: num_bcd = output_word[55:48];
                  7: num_bcd = output_word[63:56];
                  endcase
          end // if(enable)
        end //else begin
      end //always
    always @(posedge clk) begin
            if (!resetn) begin
                    big_cnt <= 0;
            end
            else begin
                    big_cnt <= big_cnt + 1;
            end
    end

    assign an_out = ~an_outn;
    assign cnt = big_cnt[20:18];
  endmodule
