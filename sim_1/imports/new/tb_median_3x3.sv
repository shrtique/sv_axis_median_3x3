`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 17:52:58
// Design Name: 
// Module Name: tb_median_3x3
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


module tb_median_3x3();

localparam DATA_WIDTH  = 8;
localparam WIDTH       = 12;
localparam HEIGHT      = 12;
localparam KERNEL_SIZE = 3;
//
//

//signals
logic clk;
logic aresetn;

logic [DATA_WIDTH-1:0]   tdata;
logic                    tvalid;
logic                    tuser;
logic                    tlast;           
//
//
tb_video_stream #(
  .N                ( DATA_WIDTH ),
  .width            ( WIDTH ),
  .height           ( HEIGHT ) 

) data_generator (
  .sys_clk          ( clk ),
  .sys_aresetn      ( aresetn ),

  .reg_video_tdata  ( tdata ),
  .reg_video_tvalid ( tvalid ),
  .reg_video_tlast  ( tlast ),
  .reg_video_tuser  ( tuser )
);
//
//

//signals
logic [DATA_WIDTH-1:0] tdata_median;
logic                  tvalid_median;
logic                  tuser_median;
logic                  tlast_median; 
// 
median_3x3_top #(

  .DATA_WIDTH    ( DATA_WIDTH  ),
  .IMG_WIDTH     ( WIDTH       ),
  .IMG_HEIGHT    ( HEIGHT      ),
  .KERNEL_SIZE   ( KERNEL_SIZE )

) UUT (

  .i_clk         ( clk           ),
  .i_aresetn     ( aresetn       ),

  .s_axis_data   ( tdata         ),
  .s_axis_tvalid ( tvalid        ),
  .s_axis_tuser  ( tuser         ),
  .s_axis_tlast  ( tlast         ),
  .s_axis_tready (               ),

  .m_axis_tdata  ( tdata_median  ),
  .m_axis_tvalid ( tvalid_median ),
  .m_axis_tuser  ( tuser_median  ),
  .m_axis_tlast  ( tlast_median  )

);
//
//


tb_savefile_axis_data #(

  .N      ( DATA_WIDTH ),
  .height ( HEIGHT     ),
  .width  ( WIDTH      )

) save_image_to_file (
  .i_sys_clk          ( clk           ),
  .i_sys_aresetn      ( aresetn       ),

  .i_reg_video_tdata  ( tdata_median  ),
  .i_reg_video_tvalid ( tvalid_median ),
  .i_reg_video_tlast  ( tlast_median  ),
  .i_reg_video_tuser  ( tuser_median  )
  );



endmodule
