`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2018 16:54:30
// Design Name: 
// Module Name: median_processing_3x3
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


module median_processing_3x3 #(

  parameter DATA_WIDTH  = 8,
  parameter KERNEL_SIZE = 3

)(

  input  logic                  i_clk,
  input  logic                  i_aresetn,

  input  logic [DATA_WIDTH-1:0] i_image_kernel_buffer [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1],
  input  logic                  i_image_data_valid,
  input  logic                  i_start_of_frame,

  output logic [DATA_WIDTH-1:0] o_median_pixel,
  output logic                  o_image_data_valid_reg,
  output logic                  o_start_of_frame_reg

);

//INSTANTIATION
// sorting by lines -> sorting by columns -> sorting diagonal -> median
//////////////////////////////////////////////////////////////////////////////////


//SIGNALS
logic [DATA_WIDTH-1:0] kernel_buffer_from_line_sorting [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1];

//INSTANTIATION
ranging_kernel_for_3x3 #(
  .DATA_WIDTH     ( DATA_WIDTH  ),
  .KERNEL_SIZE    ( KERNEL_SIZE ),
  .SORT_BY_COLUMN ( 1'b0        )

) line_ranging (

  .i_clk                 ( i_clk                           ),
  .i_aresetn             ( i_aresetn                       ),

  .i_image_kernel_buffer ( i_image_kernel_buffer           ),

  .o_image_kernel_sorted ( kernel_buffer_from_line_sorting )

);
//
//

//SIGNALS
logic [DATA_WIDTH-1:0] kernel_buffer_from_col_sorting [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1];


//INSTANTIATION
ranging_kernel_for_3x3 #(
  .DATA_WIDTH     ( DATA_WIDTH  ),
  .KERNEL_SIZE    ( KERNEL_SIZE ),
  .SORT_BY_COLUMN ( 1'b1        ) 

) column_ranging (

  .i_clk                 ( i_clk                           ),
  .i_aresetn             ( i_aresetn                       ),

  .i_image_kernel_buffer ( kernel_buffer_from_line_sorting ),

  .o_image_kernel_sorted ( kernel_buffer_from_col_sorting  )

);
//
//

sorting_module_3inputs#(

  .DATA_WIDTH ( DATA_WIDTH )

) sort_diagonal (

  .i_clk     ( i_clk                       ),
  .i_aresetn ( i_aresetn                   ),
      
  .in_1      ( kernel_buffer_from_col_sorting[0][2] ),
  .in_2      ( kernel_buffer_from_col_sorting[1][1] ),
  .in_3      ( kernel_buffer_from_col_sorting[2][0] ),
                 
  .high      (  ),
  .med       ( o_median_pixel                       ),
  .low       (  ) 

);//sort_diagonal



//delay sof and valid to sync with next module (delay = 18 clk ticks, same as delay for median processing)
//
//SIGNALS
logic [0:16] delay_buffer_valid;
logic [0:16] delay_buffer_sof;

always_ff @( posedge i_clk, negedge i_aresetn )
  begin
   if   ( ~i_aresetn ) begin

     delay_buffer_valid     <= '{default:'b0};
     delay_buffer_sof       <= '{default:'b0};

     o_image_data_valid_reg <= 1'b0;
     o_start_of_frame_reg   <= 1'b0;

   end else begin

       delay_buffer_valid     <= { i_image_data_valid, delay_buffer_valid[0:15] };
       delay_buffer_sof       <= { i_start_of_frame, delay_buffer_sof[0:15] };
       
       o_image_data_valid_reg <= delay_buffer_valid[16];
       o_start_of_frame_reg   <= delay_buffer_sof[16];
   end             	
  end

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
endmodule
