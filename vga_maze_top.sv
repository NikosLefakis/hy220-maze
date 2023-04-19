/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2023/02/06
 * Author: CS220 Instructors
 * Filename: vga_maze_top.sv
 * Description: The top module that instantiates vga_sync and vga_frame 
 *
 ******************************************************************************/

module vga_maze_top(
  input logic clk,
  input logic rst,

  input  logic [7:0] i_dip,

  output logic o_hsync,
  output logic o_vsync,
  output logic [3:0] o_red,
  output logic [3:0] o_green,
  output logic [3:0] o_blue
);

logic pixel_valid;
logic [9:0] col;
logic [9:0] row;

vga_sync vs (
  .clk(clk),
  .rst(rst),
  .o_pix_valid(pixel_valid),
  .o_col(col),
  .o_row(row),
  .o_hsync(o_hsync),
  .o_vsync(o_vsync)
);

logic [5:0] p_bcol;
logic [5:0] p_brow;
logic [5:0] e_bcol;
logic [5:0] e_brow;

assign p_bcol = {2'b0,i_dip[3:0]};
assign p_brow = {2'b0,i_dip[7:4]};
assign e_bcol = 6'd37;
assign e_brow = 6'd22;

vga_frame vf (
  .clk(clk),
  .rst(rst),
  .i_pix_valid(pixel_valid),
  .i_col(col),
  .i_row(row),
  .i_player_bcol(p_bcol),
  .i_player_brow(p_brow),
  .i_exit_bcol(e_bcol),
  .i_exit_brow(e_brow),
  .o_red(o_red),
  .o_green(o_green),
  .o_blue(o_blue)
);

endmodule
