
/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2023/04/07
 * Author: Nikos Lefakis csd4804
 * Filename: vga_sync.sv
 * Description: Implements VGA HSYNC and VSYNC timings for 640 x 480 @ 60Hz
 *
 ******************************************************************************/

module vga_sync(
  input logic clk,
  input logic rst,

  output logic o_pix_valid,
  output logic [9:0] o_col,
  output logic [9:0] o_row,

  output logic o_hsync,
  output logic o_vsync
);


parameter int FRAME_HPIXELS     = 640;
parameter int FRAME_HFPORCH     = 16;
parameter int FRAME_HSPULSE     = 96;
parameter int FRAME_HBPORCH     = 48;
parameter int FRAME_MAX_HCOUNT  = 800;

parameter int FRAME_VLINES      = 480;
parameter int FRAME_VFPORCH     = 10;
parameter int FRAME_VSPULSE     = 2;
parameter int FRAME_VBPORCH     = 29;
parameter int FRAME_MAX_VCOUNT  = 521;


logic [9:0] hcnt ;  //horizontal counter
logic hcnt_clr ;    //horizontal clear counter
logic hs_set ;       //horizontal sync 
logic hs_clr ;     // horizontal sync clear 
logic hsync ;       //horizontal sync 
logic hsync_tmp ;  // second  horizontal sync

logic [9:0] vcnt ; //vertical counter
logic vcnt_clear ;    // vertical clear counter
logic vs_set ;       //vertical sync set 
logic vs_clr ;        // vertical sync clear  
logic vsync ;         // vertical sync 
 
always_ff @(posedge clk ) begin


// for hcnt counter (increment ++)
    if(rst) begin
        hcnt <= 0;
        hsync <= 0;
        hsync_tmp<= 0;
     end 
     else begin
        hsync <= ((~hs_clr)  & ( hsync | hs_set ));
        hsync_tmp <= hsync;
        if (~hcnt_clr) begin    
           hcnt <= hcnt + 1;
        end 
        else begin  
           hcnt <= 0;
         end
      end
      

    // for vcnt counter (increment ++)
    if(rst) begin
        vcnt <=0 ; 
        vsync<=0;
    end else begin
        vsync <= ~vs_clr & (vs_set | vsync);
        if(vcnt_clear) begin
            vcnt <= 0; 
        end else begin
            if(hcnt_clr) begin
                vcnt <= vcnt +1;
             end else begin
                vcnt <= vcnt;
             end
         end    
     end
     
  //end of always_ff  block (non-blocking assignments here)      
end 


always_comb begin

       // check if horizontal counter is MAX 
       hcnt_clr = (hcnt == (FRAME_MAX_HCOUNT - 1)) ; 
        
       //v counter for clear checking  
       vcnt_clear = (hcnt_clr  & (vcnt == (FRAME_MAX_VCOUNT -1)));
    
      //checking for horizontal sync   
        hs_clr = (hcnt == (FRAME_HPIXELS +  FRAME_HFPORCH + FRAME_HSPULSE - 1 ));  
    
        //checking  for horizontal sync setter 
        hs_set = (hcnt == (FRAME_HPIXELS + FRAME_HFPORCH -1));
         
        ////checking  for vertical sync setter 
        vs_set = ((vcnt == (FRAME_VLINES + FRAME_VFPORCH - 1)) & hcnt_clr);
        
        //checking for vertical sync clear 
        vs_clr = (vcnt == (FRAME_VLINES + FRAME_VFPORCH + FRAME_VSPULSE -1) & hcnt_clr);
        
        o_vsync = ~vsync ;     //output wire for o_sync to connect in frame (vertical)
        
        o_col = hcnt ;   //output wire for o_col  to connect in frame (i-st column)
        
        //output wire for o_pix_valid to connect in frame to check if row and column is valid!
        o_pix_valid = (hcnt  < FRAME_HPIXELS) & ( vcnt < FRAME_VLINES ) ;     
        
        
        o_row = vcnt; ////output wire for o_row to connect in frame (i-st row)
    
        o_hsync = ~hsync_tmp;  //output wire for o_hsync  to connect in frame (horizontal)
    
    //end of comb "block" (blocking assignments here)
end



endmodule