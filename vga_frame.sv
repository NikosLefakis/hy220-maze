/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2023/02/06
 * Author: Nikos Lefakis cs4804
 * Filename: vga_frame.sv
 * Description: Your description here
 *
 ******************************************************************************/

module vga_frame(
  input logic clk,
  input logic rst,

  input logic i_pix_valid,
  input logic [9:0] i_col,
  input logic [9:0] i_row,

  input logic [5:0] i_player_bcol,
  input logic [5:0] i_player_brow,

  input logic [5:0] i_exit_bcol,
  input logic [5:0] i_exit_brow,

  output logic [3:0] o_red,
  output logic [3:0] o_green,
  output logic [3:0] o_blue
);


//Declaration of variables 

// for pixels in VGA
logic [15:0] maze_pixel;
logic [15:0] player_pixel;
logic [15:0] exit_pixel;

//for addresses of maze , exit and player to get "data" from roms
logic [10:0] maze_addr;
assign maze_addr = (i_col >> 4) + ((i_row >> 4) << 6);

logic [7:0] player_addr ;
assign player_addr = (i_row & 4'b1111) + ((i_col & 4'b1111) << 4);

logic [7:0] exit_addr ;
assign exit_addr = (i_row & 4'b1111) + ((i_col & 4'b1111) << 4);

//for row and cols of player and exit and i-st row and i-st column of frame
logic [5:0] tmp_player_row,tmp_player_col,tmp_exit_row,tmp_exit_col;
logic [9:0] tmp_row,tmp_col;

//tmp for valid pixel!
logic tmp_pix_valid;
 
 
//checking for reset (initialize tmp variables) 
always_ff @(posedge clk)  begin
  if (rst) begin
    tmp_player_row <= 0;
    tmp_player_col <= 0;
    tmp_exit_row <= 0;
    tmp_exit_col <= 0;
    tmp_col <= 0;
    tmp_row <= 0;
    tmp_pix_valid <= 0;
   
  end
  else begin
    tmp_player_row <= i_player_brow;
    tmp_player_col <= i_player_bcol;
    tmp_exit_row <= i_exit_brow;
    tmp_exit_col <= i_exit_bcol;
    tmp_col <= i_col;
    tmp_row <= i_row;
    tmp_pix_valid <= i_pix_valid;
     
  end
end


// Keep the hierarchy of game ( player > exit > maze ) and display colours of pixels else display black colour 
always_comb begin
  if (tmp_pix_valid) begin
    if (tmp_player_col == (tmp_col >> 4) && tmp_player_row == (tmp_row >> 4)) begin
      o_red = player_pixel[11:8];
      o_green = player_pixel[7:4];
      o_blue = player_pixel[3:0];
    end
    else if (tmp_exit_col == (tmp_col >> 4) && tmp_exit_row == (tmp_row >> 4)) begin
      o_red = exit_pixel[11:8];
      o_green = exit_pixel[7:4];
      o_blue = exit_pixel[3:0];
    end
    else begin
      o_red = maze_pixel[11:8];
      o_green = maze_pixel[7:4];
      o_blue = maze_pixel[3:0];
    end
  end
  else begin
    o_red = 0;
    o_green = 0;
    o_blue = 0;
  end
end


// ROM Template Instantiation
rom #(
  .size(2048),
  .file("/home/n1ckos/Documents/lab2_code/roms/maze1.rom") 
)
maze_rom (
  .clk(clk),
  .en(i_pix_valid),
  .addr(maze_addr),
  .dout(maze_pixel)
);

rom #(
    .size(256),
    .file("/home/n1ckos/Documents/lab2_code/roms/player.rom")
)
player_rom (
  .clk(clk),
  .en(i_pix_valid),
  .addr(player_addr),
  .dout(player_pixel)
);


rom #(
    .size(256),
    .file("/home/n1ckos/Documents/lab2_code/roms/exit.rom")
)
exit_rom(
  .clk(clk),
  .en(i_pix_valid),
  .addr(exit_addr),
  .dout(exit_pixel)
);   

endmodule
