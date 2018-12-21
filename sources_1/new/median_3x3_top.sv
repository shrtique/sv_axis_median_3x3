`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2018 17:30:04
// Design Name: 
// Module Name: median_3x3_top
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


module median_3x3_top #(

  parameter DATA_WIDTH  = 8,
  parameter IMG_WIDTH   = 1280,
  parameter IMG_HEIGHT  = 1024,
  parameter KERNEL_SIZE = 3

)(

  input  logic                    i_clk,
  input  logic                    i_aresetn,

  input  logic [DATA_WIDTH-1:0]   s_axis_data,
  input  logic                    s_axis_tvalid,
  input  logic                    s_axis_tuser,
  input  logic                    s_axis_tlast,
  output logic                    s_axis_tready,

  output logic [DATA_WIDTH-1:0]   m_axis_tdata,
  output logic                    m_axis_tvalid,
  output logic                    m_axis_tuser,
  output logic                    m_axis_tlast

);

//
//show that we're ready to receive pixels
always_ff @( posedge i_clk, negedge i_aresetn )
  begin 
    if ( ~i_aresetn ) begin
      s_axis_tready <= 1'b0;
    end else begin
      s_axis_tready <= 1'b1;
    end
end
//
//

///INST////

//1. RECEIVER

//signals
logic [DATA_WIDTH-1:0] kernel_image_buffer_from_receiver [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1];
logic                  data_valid_from_receiver;
logic                  sof_from_receiver;

AXIS_pixel_receiver #(

  .DATA_WIDTH  ( DATA_WIDTH  ),
  .KERNEL_SIZE ( KERNEL_SIZE ),
  .IMAGE_WIDTH ( IMG_WIDTH  )

) data_receiver (

  .i_clk                 ( i_clk                             ),
  .i_aresetn             ( i_aresetn                         ),

  .i_data                ( s_axis_data                       ),
  .i_data_valid          ( s_axis_tvalid                     ),
  .i_start_of_frame      ( s_axis_tuser                      ),

  .o_image_kernel_buffer ( kernel_image_buffer_from_receiver ),
  .o_data_valid          ( data_valid_from_receiver          ),
  .o_start_of_frame      ( sof_from_receiver                 )
  
);
//
//

//2. PROCESSING

//signals

logic [DATA_WIDTH-1:0] data_from_processing;
logic                  data_valid_from_processing;
logic                  sof_from_processing;


median_processing_3x3 #(

  .DATA_WIDTH  ( DATA_WIDTH  ),
  .KERNEL_SIZE ( KERNEL_SIZE )

) data_processing (

  .i_clk                  ( i_clk                             ),
  .i_aresetn              ( i_aresetn                         ),

  .i_image_kernel_buffer  ( kernel_image_buffer_from_receiver ),
  .i_image_data_valid     ( data_valid_from_receiver          ),
  .i_start_of_frame       ( sof_from_receiver                 ),

  .o_median_pixel         ( data_from_processing              ),
  .o_image_data_valid_reg ( data_valid_from_processing        ),
  .o_start_of_frame_reg   ( sof_from_processing               )  

);
//
//

//3. TRANSMITTER

//signals

median_M_AXIS_FSM #(
  .DATA_WIDTH  ( DATA_WIDTH  ),
  .IMG_WIDTH   ( IMG_WIDTH   ),
  .IMG_HEIGHT  ( IMG_HEIGHT  ),
  .KERNEL_SIZE ( KERNEL_SIZE )
) data_transmitter (	
  .i_clk              ( i_clk                      ),
  .i_aresetn          ( i_aresetn                  ),

  .i_median_pixel     ( data_from_processing       ),
  .i_image_data_valid ( data_valid_from_processing ),
  .i_start_of_frame   ( sof_from_processing        ),

  .m_axis_tdata       ( m_axis_tdata               ),
  .m_axis_tvalid      ( m_axis_tvalid              ),
  .m_axis_tuser       ( m_axis_tuser               ),
  .m_axis_tlast       ( m_axis_tlast               )

);


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
endmodule
